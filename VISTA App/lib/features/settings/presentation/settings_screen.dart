import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة الإعدادات
class SettingsScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const SettingsScreen({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _signalNotifications = true;
  bool _priceAlerts = true;
  bool _marketUpdates = false;
  bool _quietMode = false;
  String _selectedTheme = 'تلقائي';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_forward,
              color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            ),
          ),
          title: Text(
            AppConstants.screenSettings,
            style: TextStyle(
              color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // الإشعارات
              _buildSectionTitle(context, 'الإشعارات'),
              AppCard(
                variant: AppCardVariant.defaultCard,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      context,
                      isDark,
                      icon: Icons.notifications,
                      title: 'تفعيل الإشعارات',
                      subtitle: 'استقبال جميع الإشعارات',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                    if (_notificationsEnabled) ...[
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        context,
                        isDark,
                        icon: Icons.show_chart,
                        title: 'إشارات التداول',
                        subtitle: 'إشعارات الإشارات الجديدة',
                        value: _signalNotifications,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          setState(() => _signalNotifications = value);
                        },
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        context,
                        isDark,
                        icon: Icons.price_change,
                        title: 'تنبيهات الأسعار',
                        subtitle: 'إشعارات عند وصول السعر للمستهدف',
                        value: _priceAlerts,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          setState(() => _priceAlerts = value);
                        },
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        context,
                        isDark,
                        icon: Icons.trending_up,
                        title: 'تحديثات السوق',
                        subtitle: 'ملخص يومي لأداء السوق',
                        value: _marketUpdates,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          setState(() => _marketUpdates = value);
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // وضع الهدوء
              _buildSectionTitle(context, 'وضع الهدوء'),
              AppCard(
                variant: AppCardVariant.defaultCard,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      context,
                      isDark,
                      icon: Icons.do_not_disturb_on,
                      title: 'وضع الهدوء',
                      subtitle: 'إيقاف الإشعارات مؤقتاً',
                      value: _quietMode,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        setState(() => _quietMode = value);
                      },
                    ),
                    if (_quietMode) ...[
                      _buildDivider(isDark),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '9:00 م - 9:00 ص',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'الفترة الزمنية',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // المظهر
              _buildSectionTitle(context, 'المظهر'),
              AppCard(
                variant: AppCardVariant.defaultCard,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildOptionTile(
                      context,
                      isDark,
                      icon: Icons.brightness_6,
                      title: 'المظهر',
                      value: _selectedTheme,
                      onTap: () => _showThemeSheet(context, isDark),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // النصوص القانونية
              _buildSectionTitle(context, 'قانوني'),
              AppCard(
                variant: AppCardVariant.defaultCard,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildNavigationTile(
                      context,
                      isDark,
                      icon: Icons.description,
                      title: 'شروط الاستخدام',
                      onTap: () => _showLegalSheet(context, isDark, 'شروط الاستخدام'),
                    ),
                    _buildDivider(isDark),
                    _buildNavigationTile(
                      context,
                      isDark,
                      icon: Icons.privacy_tip,
                      title: 'سياسة الخصوصية',
                      onTap: () => _showLegalSheet(context, isDark, 'سياسة الخصوصية'),
                    ),
                    _buildDivider(isDark),
                    _buildNavigationTile(
                      context,
                      isDark,
                      icon: Icons.warning_amber,
                      title: 'إقرار المخاطر',
                      onTap: () => _showLegalSheet(context, isDark, 'إقرار المخاطر'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // معلومات التطبيق
              Center(
                child: Column(
                  children: [
                    Text(
                      '${AppConstants.appName} v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2024 جميع الحقوق محفوظة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.mutedDark
              : AppColors.mutedLight,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          const Spacer(),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
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
              const SizedBox(width: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
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
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context, bool isDark) {
    final themes = ['تلقائي', 'فاتح', 'داكن'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'اختر المظهر',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...themes.map((theme) => ListTile(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedTheme = theme);
                  widget.onThemeChanged?.call();
                  Navigator.pop(context);
                },
                leading: _selectedTheme == theme
                    ? Icon(Icons.check_circle, color: AppColors.primary)
                    : Icon(Icons.circle_outlined, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                title: Text(theme, textAlign: TextAlign.right),
              )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showLegalSheet(BuildContext context, bool isDark, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _getLegalText(title),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.8,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLegalText(String title) {
    switch (title) {
      case 'شروط الاستخدام':
        return '''
شروط الاستخدام

مرحباً بك في تطبيق مصرية ماركت. باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام.

1. استخدام التطبيق
يُقدم هذا التطبيق لأغراض إعلامية وتعليمية فقط. لا تُعتبر المعلومات المقدمة نصيحة استثمارية.

2. المسؤولية
لا يتحمل التطبيق أي مسؤولية عن القرارات الاستثمارية التي يتخذها المستخدم.

3. الملكية الفكرية
جميع المحتويات والعلامات التجارية محمية بموجب قوانين الملكية الفكرية.

4. التعديلات
نحتفظ بالحق في تعديل هذه الشروط في أي وقت.
''';
      case 'سياسة الخصوصية':
        return '''
سياسة الخصوصية

نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.

1. البيانات المجمعة
نجمع البيانات الضرورية لتقديم الخدمة مثل البريد الإلكتروني وتفضيلات الإشعارات.

2. استخدام البيانات
نستخدم بياناتك لتحسين تجربة المستخدم وتقديم محتوى مخصص.

3. حماية البيانات
نطبق إجراءات أمنية صارمة لحماية بياناتك.

4. مشاركة البيانات
لا نشارك بياناتك مع أطراف ثالثة دون موافقتك.
''';
      case 'إقرار المخاطر':
        return '''
إقرار المخاطر

تحذير هام: التداول في الأسواق المالية ينطوي على مخاطر عالية.

1. مخاطر السوق
قد تتعرض لخسائر مالية كبيرة نتيجة تقلبات السوق.

2. لا ضمانات
لا توجد ضمانات لتحقيق أرباح من التداول.

3. الإشارات
إشارات التداول المقدمة هي للأغراض التعليمية فقط ولا تُعتبر توصيات استثمارية.

4. المسؤولية الشخصية
أنت المسؤول الوحيد عن قراراتك الاستثمارية.

5. استشارة متخصص
ننصح باستشارة مستشار مالي مرخص قبل اتخاذ أي قرارات استثمارية.
''';
      default:
        return '';
    }
  }
}
