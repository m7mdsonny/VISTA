import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة إقرار المخاطر والتنويه القانوني
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _accepted = false;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.warning_amber_rounded,
      title: AppConstants.riskDisclaimer,
      content: AppConstants.riskDisclaimerText,
      iconColor: AppColors.warning,
    ),
    _OnboardingPage(
      icon: Icons.gavel_rounded,
      title: AppConstants.legalDisclaimer,
      content: '''
هذا التطبيق مُقدم لأغراض المعلومات العامة فقط.

• المحتوى لا يُعد نصيحة استثمارية أو مالية
• لا نتحمل أي مسؤولية عن قرارات التداول
• يُرجى استشارة مستشار مالي مرخص
• الأداء السابق لا يضمن النتائج المستقبلية
• جميع البيانات قد تتأخر أو تكون غير دقيقة
''',
      iconColor: AppColors.primary,
    ),
  ];

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_accepted) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // مؤشر الصفحات
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // محتوى الصفحات
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          
                          // الأيقونة
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: page.iconColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              page.icon,
                              size: 50,
                              color: page.iconColor,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // العنوان
                          Text(
                            page.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // المحتوى
                          AppCard(
                            variant: AppCardVariant.elevated,
                            child: Text(
                              page.content,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.8,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // زر الموافقة
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // خانة الموافقة (في الصفحة الأخيرة فقط)
                    if (_currentPage == _pages.length - 1) ...[
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _accepted = !_accepted);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'أوافق على الشروط والأحكام',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _accepted ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _accepted
                                      ? AppColors.primary
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  width: 2,
                                ),
                              ),
                              child: _accepted
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    AppButton(
                      text: _currentPage < _pages.length - 1
                          ? 'التالي'
                          : AppConstants.acceptAndContinue,
                      onPressed: _currentPage < _pages.length - 1 || _accepted
                          ? _nextPage
                          : null,
                      isFullWidth: true,
                      size: AppButtonSize.large,
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

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String content;
  final Color iconColor;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.content,
    required this.iconColor,
  });
}
