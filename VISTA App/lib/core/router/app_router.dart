import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/paywall/presentation/paywall_screen.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/signals/presentation/signals_screen.dart';
import '../../features/signals/presentation/signal_details_screen.dart';
import '../../features/watchlist/presentation/watchlist_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/explore/presentation/stock_details_screen.dart';
import '../../features/explore/presentation/fund_details_screen.dart';
import '../../features/account/presentation/account_screen.dart';
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/paper_portfolio/presentation/paper_portfolio_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../theme/app_colors.dart';

/// مفتاح التنقل العام
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// إعداد التنقل
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(
        onComplete: () => context.go('/auth'),
      ),
    ),

    // Auth
    GoRoute(
      path: '/auth',
      builder: (context, state) => AuthScreen(
        onLoginSuccess: () => context.go('/paywall'),
        onRegisterSuccess: () => context.go('/paywall'),
      ),
    ),

    // Paywall
    GoRoute(
      path: '/paywall',
      builder: (context, state) => PaywallScreen(
        onComplete: () => context.go('/'),
        onSkip: () => context.go('/'),
      ),
    ),

    // Shell Route للتبويبات
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // اليوم
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TodayScreen(),
          ),
        ),

        // الإشارات
        GoRoute(
          path: '/signals',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SignalsScreen(),
          ),
        ),

        // المتابعة
        GoRoute(
          path: '/watchlist',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WatchlistScreen(),
          ),
        ),

        // استكشاف
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExploreScreen(),
          ),
        ),

        // الحساب
        GoRoute(
          path: '/account',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AccountScreen(),
          ),
        ),
      ],
    ),

    // تفاصيل الإشارة
    GoRoute(
      path: '/signal/:id',
      builder: (context, state) => SignalDetailsScreen(
        signalId: state.pathParameters['id'] ?? '',
      ),
    ),

    // تفاصيل السهم
    GoRoute(
      path: '/stock/:symbol',
      builder: (context, state) => StockDetailsScreen(
        stockSymbol: state.pathParameters['symbol'] ?? '',
      ),
    ),

    // تفاصيل الصندوق
    GoRoute(
      path: '/fund/:id',
      builder: (context, state) => FundDetailsScreen(
        fundId: state.pathParameters['id'] ?? '',
      ),
    ),

    // التنبيهات
    GoRoute(
      path: '/alerts',
      builder: (context, state) => const AlertsScreen(),
    ),

    // التعليم
    GoRoute(
      path: '/education',
      builder: (context, state) => const EducationScreen(),
    ),

    // المحفظة التجريبية
    GoRoute(
      path: '/paper-portfolio',
      builder: (context, state) => const PaperPortfolioScreen(),
    ),

    // الإعدادات
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

/// Shell الرئيسي مع Bottom Navigation
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/',
    '/signals',
    '/watchlist',
    '/explore',
    '/account',
  ];

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.today, label: 'اليوم'),
    _NavItem(icon: Icons.show_chart, label: 'الإشارات'),
    _NavItem(icon: Icons.bookmark_border, label: 'المتابعة'),
    _NavItem(icon: Icons.explore, label: 'استكشاف'),
    _NavItem(icon: Icons.person_outline, label: 'الحساب'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndex();
  }

  void _updateIndex() {
    final location = GoRouterState.of(context).uri.path;
    final index = _routes.indexOf(location);
    if (index != -1 && index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == _currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (index != _currentIndex) {
                          setState(() => _currentIndex = index);
                          context.go(_routes[index]);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
