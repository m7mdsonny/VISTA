import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة الحساب
class AccountScreen extends StatelessWidget {
  final VoidCallback? onAlertsTap;
  final VoidCallback? onEducationTap;
  final VoidCallback? onPaperPortfolioTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogout;

  const AccountScreen({
    super.key,
    this.onAlertsTap,
    this.onEducationTap,
    this.onPaperPortfolioTap,
    this.onSettingsTap,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Text(
                  AppConstants.tabAccount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // بطاقة الملف الشخصي
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Row(
                    children: [
                      // زر التعديل
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // معلومات المستخدم
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'أحمد محمد',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ahmed@example.com',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.positive.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'مشترك نشط',
                                  style: TextStyle(
                                    color: AppColors.positive,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  color: AppColors.positive,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // الصورة الشخصية
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // القائمة الرئيسية
                _buildSection(
                  context,
                  isDark,
                  title: 'الأدوات',
                  items: [
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      title: AppConstants.screenAlerts,
                      subtitle: 'سجل الإشعارات والتنبيهات',
                      onTap: onAlertsTap,
                    ),
                    _MenuItem(
                      icon: Icons.school_outlined,
                      title: AppConstants.screenEducation,
                      subtitle: 'تعلم أساسيات التداول',
                      onTap: onEducationTap,
                    ),
                    _MenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: AppConstants.screenPaperPortfolio,
                      subtitle: 'تدرب على التداول بدون مخاطرة',
                      onTap: onPaperPortfolioTap,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // الإعدادات
                _buildSection(
                  context,
                  isDark,
                  title: 'الإعدادات',
                  items: [
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      title: AppConstants.screenSettings,
                      subtitle: 'الإشعارات والمظهر والخصوصية',
                      onTap: onSettingsTap,
                    ),
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'المساعدة والدعم',
                      subtitle: 'الأسئلة الشائعة والتواصل معنا',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // زر تسجيل الخروج
                AppButton(
                  text: AppConstants.logout,
                  variant: AppButtonVariant.outline,
                  icon: Icons.logout,
                  isFullWidth: true,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showLogoutDialog(context, isDark);
                  },
                ),

                const SizedBox(height: 24),

                // معلومات التطبيق
                Text(
                  '${AppConstants.appName} v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
            ),
          ),
        ),
        AppCard(
          variant: AppCardVariant.defaultCard,
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildMenuItem(context, isDark, item),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 56,
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, bool isDark, _MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          item.onTap?.call();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.chevron_left,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                size: 20,
              ),
              
              const Spacer(),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              
              const SizedBox(width: 12),
              
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'تسجيل الخروج',
            textAlign: TextAlign.right,
          ),
          content: Text(
            'هل أنت متأكد من تسجيل الخروج؟',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppConstants.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onLogout?.call();
              },
              child: Text(
                AppConstants.logout,
                style: TextStyle(color: AppColors.negative),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
}
