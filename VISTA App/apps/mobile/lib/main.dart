import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تعيين اتجاه الشاشة للوضع العمودي فقط
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تعيين ألوان شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: MasriaMarketApp(),
    ),
  );
}

/// تطبيق مصرية ماركت
class MasriaMarketApp extends ConsumerStatefulWidget {
  const MasriaMarketApp({super.key});

  @override
  ConsumerState<MasriaMarketApp> createState() => _MasriaMarketAppState();
}

class _MasriaMarketAppState extends ConsumerState<MasriaMarketApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        _themeMode = ThemeMode.light;
      } else if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'مصرية ماركت',
      debugShowCheckedModeBanner: false,

      // الثيم
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.alexandriaTextTheme(
          AppTheme.lightTheme.textTheme,
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.alexandriaTextTheme(
          AppTheme.darkTheme.textTheme,
        ),
      ),
      themeMode: _themeMode,

      // التوطين
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('ar'),
      ],

      // التنقل
      routerConfig: appRouter,

      // Builder للـ RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
