<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminSetting;
use App\Models\AuditLog;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    public function edit()
    {
        $settings = AdminSetting::pluck('value_json', 'key');

        return view('admin.settings.edit', [
            'settings' => $settings,
        ]);
    }

    public function update(Request $request)
    {
        $data = $request->validate([
            'trial_days' => ['required', 'integer', 'min:1'],
            'feature_flags' => ['required', 'string'],
            'analysis_thresholds' => ['required', 'string'],
            'analysis_weights' => ['required', 'string'],
            'notification_rules' => ['required', 'string'],
            'legal_texts' => ['required', 'string'],
            'banners' => ['nullable', 'string'],
            'maintenance' => ['required', 'string'],
        ]);

        $payloads = [
            'trial_days' => ['days' => (int) $data['trial_days']],
            'feature_flags' => json_decode($data['feature_flags'], true),
            'analysis_thresholds' => json_decode($data['analysis_thresholds'], true),
            'analysis_weights' => json_decode($data['analysis_weights'], true),
            'notification_rules' => json_decode($data['notification_rules'], true),
            'legal_texts' => json_decode($data['legal_texts'], true),
            'banners' => $data['banners'] ? json_decode($data['banners'], true) : [],
            'maintenance' => json_decode($data['maintenance'], true),
        ];

        foreach ($payloads as $key => $value) {
            AdminSetting::updateOrCreate(['key' => $key], ['value_json' => $value]);
        }

        $this->logAudit('update', 'admin_settings', 'global', $payloads);

        return redirect()->route('admin.settings.edit')->with('status', 'تم تحديث الإعدادات');
    }

    private function logAudit(string $action, string $entity, string $entityId, array $diff): void
    {
        AuditLog::create([
            'actor_user_id' => request()->user()?->id,
            'action' => $action,
            'entity' => $entity,
            'entity_id' => $entityId,
            'diff_json' => $diff,
            'ip' => request()->ip(),
            'ua' => request()->userAgent(),
        ]);
    }
}
