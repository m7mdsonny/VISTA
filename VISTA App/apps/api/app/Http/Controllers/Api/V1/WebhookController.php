<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\SubscriptionService;
use App\Models\User;
use App\Models\Subscription;
use App\Models\Invoice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class WebhookController extends Controller
{
    public function __construct(
        private SubscriptionService $subscriptionService
    ) {
    }

    /**
     * Handle Apple App Store Server-to-Server Notifications
     */
    public function apple(Request $request)
    {
        // Verify signature (stub - implement actual Apple signature verification)
        if (!$this->verifyAppleSignature($request)) {
            Log::warning('Invalid Apple webhook signature', [
                'ip' => $request->ip(),
                'headers' => $request->headers->all(),
            ]);
            return response()->json(['message' => 'Invalid signature'], 401);
        }

        $notification = $request->input('notification_type');
        $unifiedReceipt = $request->input('unified_receipt', []);
        $latestReceiptInfo = $unifiedReceipt['latest_receipt_info'] ?? [];

        foreach ($latestReceiptInfo as $receiptInfo) {
            $originalTransactionId = $receiptInfo['original_transaction_id'] ?? null;
            if (!$originalTransactionId) {
                continue;
            }

            // Find subscription by transaction ID
            $subscription = Subscription::where('platform_transaction_id', $originalTransactionId)
                ->first();

            if (!$subscription) {
                Log::warning('Subscription not found for Apple webhook', [
                    'transaction_id' => $originalTransactionId,
                ]);
                continue;
            }

            // Handle different notification types
            switch ($notification) {
                case 'INITIAL_BUY':
                    // First purchase - activate subscription automatically
                    $this->handleSubscriptionActivation($subscription, $receiptInfo);
                    break;

                case 'DID_RENEW':
                    // Renewal - update subscription
                    $this->handleSubscriptionRenewal($subscription, $receiptInfo);
                    break;

                case 'DID_FAIL_TO_RENEW':
                    $this->handleSubscriptionFailure($subscription);
                    break;

                case 'CANCEL':
                    $this->handleSubscriptionCancellation($subscription);
                    break;

                case 'REFUND':
                    $this->handleSubscriptionRefund($subscription);
                    break;

                default:
                    Log::info('Unhandled Apple webhook notification', [
                        'notification' => $notification,
                        'subscription_id' => $subscription->id,
                    ]);
            }
        }

        return response()->json(['status' => 'ok']);
    }

    /**
     * Handle Google Play Real-time Developer Notifications
     */
    public function google(Request $request)
    {
        // Verify signature (stub - implement actual Google Pub/Sub signature verification)
        if (!$this->verifyGoogleSignature($request)) {
            Log::warning('Invalid Google webhook signature', [
                'ip' => $request->ip(),
            ]);
            return response()->json(['message' => 'Invalid signature'], 401);
        }

        $message = $request->input('message', []);
        $data = json_decode(base64_decode($message['data'] ?? ''), true) ?? [];

        $subscriptionNotification = $data['subscriptionNotification'] ?? [];
        $notificationType = $subscriptionNotification['notificationType'] ?? null;
        $purchaseToken = $subscriptionNotification['purchaseToken'] ?? null;
        $subscriptionId = $subscriptionNotification['subscriptionId'] ?? null;

        if (!$purchaseToken || !$subscriptionId) {
            return response()->json(['message' => 'Invalid notification data'], 400);
        }

        // Find subscription by purchase token or subscription ID
        $subscription = Subscription::where('platform_transaction_id', $purchaseToken)
            ->orWhere('product_id', $subscriptionId)
            ->first();

        if (!$subscription) {
            Log::warning('Subscription not found for Google webhook', [
                'purchase_token' => $purchaseToken,
                'subscription_id' => $subscriptionId,
            ]);
            return response()->json(['message' => 'Subscription not found'], 404);
        }

        // Handle different notification types (1=SUBSCRIPTION_RECOVERED, 2=SUBSCRIPTION_RENEWED, etc.)
        switch ($notificationType) {
            case 1: // SUBSCRIPTION_RECOVERED
            case 2: // SUBSCRIPTION_RENEWED
                $this->handleGoogleSubscriptionRenewal($subscription, $purchaseToken, $subscriptionId);
                break;

            case 3: // SUBSCRIPTION_CANCELED
                $this->handleSubscriptionCancellation($subscription);
                break;

            case 4: // SUBSCRIPTION_PURCHASED
                // First purchase - activate subscription automatically
                $this->handleGoogleSubscriptionPurchase($subscription, $purchaseToken, $subscriptionId);
                break;

            case 12: // SUBSCRIPTION_EXPIRED
                $this->handleSubscriptionExpiry($subscription);
                break;

            default:
                Log::info('Unhandled Google webhook notification', [
                    'notification_type' => $notificationType,
                    'subscription_id' => $subscription->id,
                ]);
        }

        return response()->json(['status' => 'ok']);
    }

    /**
     * Handle initial subscription activation (Apple)
     * AUTOMATIC ACTIVATION when payment is received
     */
    private function handleSubscriptionActivation(Subscription $subscription, array $receiptInfo): void
    {
        $expiresAt = isset($receiptInfo['expires_date_ms'])
            ? \Carbon\Carbon::createFromTimestampMs($receiptInfo['expires_date_ms'])
            : null;

        // AUTOMATIC ACTIVATION: Update subscription status to active
        $subscription->update([
            'status' => $expiresAt && $expiresAt->isFuture() ? 'active' : 'expired',
            'expires_at' => $expiresAt,
            'started_at' => now(),
            'last_verified_at' => now(),
            'verification_failures' => 0,
        ]);

        // AUTOMATIC ACTIVATION: Update entitlements immediately
        $this->subscriptionService->updateEntitlements($subscription->user, $subscription->plan);

        // Create invoice
        $this->createInvoice($subscription, 'paid');

        Log::info('Subscription activated automatically via Apple webhook', [
            'subscription_id' => $subscription->id,
            'user_id' => $subscription->user_id,
            'status' => $subscription->status,
        ]);
    }

    /**
     * Handle subscription renewal (Apple)
     */
    private function handleSubscriptionRenewal(Subscription $subscription, array $receiptInfo): void
    {
        $expiresAt = isset($receiptInfo['expires_date_ms'])
            ? \Carbon\Carbon::createFromTimestampMs($receiptInfo['expires_date_ms'])
            : null;

        $subscription->update([
            'status' => $expiresAt && $expiresAt->isFuture() ? 'active' : 'expired',
            'expires_at' => $expiresAt,
            'last_verified_at' => now(),
            'verification_failures' => 0,
        ]);

        // Update entitlements
        $this->subscriptionService->updateEntitlements($subscription->user, $subscription->plan);

        // Create invoice
        $this->createInvoice($subscription, 'paid');

        Log::info('Subscription renewed via Apple webhook', [
            'subscription_id' => $subscription->id,
            'user_id' => $subscription->user_id,
        ]);
    }

    /**
     * Handle subscription renewal (Google)
     */
    private function handleGoogleSubscriptionRenewal(Subscription $subscription, string $purchaseToken, string $subscriptionId): void
    {
        // Re-verify purchase with Google API to get latest expiry
        $verifiedSubscription = $this->subscriptionService->verifyGooglePurchase(
            $subscription->user,
            $purchaseToken,
            $subscriptionId,
            $subscription->platform_transaction_id
        );

        if ($verifiedSubscription) {
            $this->createInvoice($verifiedSubscription, 'paid');
        }

        Log::info('Subscription renewed via Google webhook', [
            'subscription_id' => $subscription->id,
            'user_id' => $subscription->user_id,
        ]);
    }

    /**
     * Handle Google subscription purchase
     * AUTOMATIC ACTIVATION when payment is received
     */
    private function handleGoogleSubscriptionPurchase(Subscription $subscription, string $purchaseToken, string $subscriptionId): void
    {
        $verifiedSubscription = $this->subscriptionService->verifyGooglePurchase(
            $subscription->user,
            $purchaseToken,
            $subscriptionId,
            $subscription->platform_transaction_id
        );

        if ($verifiedSubscription) {
            // AUTOMATIC ACTIVATION: Update entitlements (already done in verifyGooglePurchase)
            // Just ensure status is active
            if ($verifiedSubscription->status !== 'active') {
                $verifiedSubscription->update(['status' => 'active']);
                $this->subscriptionService->updateEntitlements($verifiedSubscription->user, $verifiedSubscription->plan);
            }

            $this->createInvoice($verifiedSubscription, 'paid');

            Log::info('Subscription activated automatically via Google webhook', [
                'subscription_id' => $verifiedSubscription->id,
                'user_id' => $verifiedSubscription->user_id,
                'status' => $verifiedSubscription->status,
            ]);
        }
    }

    /**
     * Handle subscription failure
     */
    private function handleSubscriptionFailure(Subscription $subscription): void
    {
        $subscription->update([
            'status' => 'expired',
            'last_verified_at' => now(),
        ]);

        Log::warning('Subscription failed to renew', [
            'subscription_id' => $subscription->id,
            'user_id' => $subscription->user_id,
        ]);
    }

    /**
     * Handle subscription cancellation
     */
    private function handleSubscriptionCancellation(Subscription $subscription): void
    {
        $subscription->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
        ]);

        Log::info('Subscription cancelled via webhook', [
            'subscription_id' => $subscription->id,
            'user_id' => $subscription->user_id,
        ]);
    }

    /**
     * Handle subscription refund
     */
    private function handleSubscriptionRefund(Subscription $subscription): void
    {
        $subscription->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
        ]);

        // Mark latest invoice as refunded
        $latestInvoice = Invoice::where('subscription_id', $subscription->id)
            ->latest()
            ->first();

        if ($latestInvoice) {
            $latestInvoice->update(['status' => 'refunded']);
        }

        Log::info('Subscription refunded via webhook', [
            'subscription_id' => $subscription->id,
            'user_id' => $subscription->user_id,
        ]);
    }

    /**
     * Handle subscription expiry
     */
    private function handleSubscriptionExpiry(Subscription $subscription): void
    {
        $subscription->update([
            'status' => 'expired',
            'expires_at' => now(),
        ]);

        Log::info('Subscription expired via webhook', [
            'subscription_id' => $subscription->id,
            'user_id' => $subscription->user_id,
        ]);
    }

    /**
     * Create invoice for subscription
     */
    private function createInvoice(Subscription $subscription, string $status = 'paid'): Invoice
    {
        $plan = $subscription->plan;
        $invoiceNumber = 'INV-' . now()->format('Ymd') . '-' . str_pad($subscription->id, 6, '0', STR_PAD_LEFT);

        return Invoice::create([
            'user_id' => $subscription->user_id,
            'subscription_id' => $subscription->id,
            'invoice_number' => $invoiceNumber,
            'plan_code' => $plan->code,
            'amount' => $plan->price_monthly ?? 0,
            'currency' => 'EGP',
            'platform' => $subscription->platform,
            'platform_transaction_id' => $subscription->platform_transaction_id,
            'status' => $status,
            'paid_at' => $status === 'paid' ? now() : null,
        ]);
    }

    /**
     * Verify Apple webhook signature
     * TODO: Implement actual Apple certificate chain verification
     */
    private function verifyAppleSignature(Request $request): bool
    {
        // Stub implementation - implement actual Apple signature verification
        // Check X-Apple-Request-UUID header and certificate chain
        $signature = $request->header('X-Apple-Request-UUID');
        $certificateUrl = $request->header('X-Apple-Certificate-URL');

        // For now, just check if signature exists (implement proper verification in production)
        return !empty($signature) && !empty($certificateUrl);
    }

    /**
     * Verify Google Pub/Sub message signature
     * TODO: Implement actual Google Pub/Sub signature verification
     */
    private function verifyGoogleSignature(Request $request): bool
    {
        // Stub implementation - implement actual Google Pub/Sub signature verification
        $signature = $request->header('X-Goog-Signature');

        // For now, just check if signature exists (implement proper verification in production)
        return !empty($signature);
    }
}
