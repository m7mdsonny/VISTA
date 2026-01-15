import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة الاشتراك والتجربة المجانية
class PaywallScreen extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const PaywallScreen({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final features = [
      _Feature(
        icon: Icons.show_chart,
        title: 'إشارات تداول ذكية',
        description: 'احصل على إشارات شراء وبيع مدعومة بالذكاء الاصطناعي',
      ),
      _Feature(
        icon: Icons.notifications_active,
        title: 'تنبيهات فورية',
        description: 'لا تفوت أي فرصة مع التنبيهات اللحظية',
      ),
      _Feature(
        icon: Icons.analytics,
        title: 'تحليلات متقدمة',
        description: 'رسوم بيانية وإحصائيات تفصيلية للسوق',
      ),
      _Feature(
        icon: Icons.school,
        title: 'محتوى تعليمي',
        description: 'تعلم أساسيات التداول والتحليل الفني',
      ),
      _Feature(
        icon: Icons.account_balance_wallet,
        title: 'محفظة تجريبية',
        description: 'تدرب على التداول بدون مخاطرة',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // زر التخطي
              if (onSkip != null)
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onSkip?.call();
                    },
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // الأيقونة
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // العنوان
                      Text(
                        'ابدأ تجربتك المجانية',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // شارة التجربة المجانية
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.positive.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppConstants.freeTrialDays,
                              style: TextStyle(
                                color: AppColors.positive,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppConstants.freeTrial,
                              style: TextStyle(
                                color: AppColors.positive,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // قائمة المميزات
                      ...features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FeatureItem(feature: feature, isDark: isDark),
                      )),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // زر البدء
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AppButton(
                      text: AppConstants.startFreeTrial,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        onComplete();
                      },
                      isFullWidth: true,
                      size: AppButtonSize.large,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لن يتم خصم أي مبلغ خلال فترة التجربة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;

  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureItem extends StatelessWidget {
  final _Feature feature;
  final bool isDark;

  const _FeatureItem({
    required this.feature,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 4),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            feature.icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ],
    );
  }
}
