/// ثوابت التطبيق العربية
class AppConstants {
  AppConstants._();

  // اسم التطبيق
  static const String appName = 'مصرية ماركت';
  static const String appNameEn = 'Masria Market';
  static const String appTagline = 'منصة ذكية لتحليل السوق المصرية';

  // عناوين التبويبات
  static const String tabToday = 'اليوم';
  static const String tabSignals = 'الإشارات';
  static const String tabWatchlist = 'المتابعة';
  static const String tabExplore = 'استكشاف';
  static const String tabAccount = 'الحساب';

  // عناوين الشاشات
  static const String screenOnboarding = 'مرحباً بك';
  static const String screenAuth = 'تسجيل الدخول';
  static const String screenPaywall = 'الاشتراك';
  static const String screenSignalDetails = 'تفاصيل الإشارة';
  static const String screenStockDetails = 'تفاصيل السهم';
  static const String screenFundDetails = 'تفاصيل الصندوق';
  static const String screenAlerts = 'التنبيهات';
  static const String screenEducation = 'التعليم';
  static const String screenPaperPortfolio = 'المحفظة التجريبية';
  static const String screenSettings = 'الإعدادات';

  // نصوص الإشارات
  static const String signalBuy = 'شراء';
  static const String signalSell = 'بيع';
  static const String signalHold = 'احتفاظ';
  static const String confidenceLabel = 'نسبة الثقة';
  static const String riskLabel = 'مستوى المخاطرة';
  static const String whyThisSignal = 'لماذا هذه الإشارة؟';
  static const String importantNotes = 'ملاحظات مهمة';
  static const String risks = 'المخاطر';

  // مستويات المخاطرة
  static const String riskLow = 'منخفض';
  static const String riskMedium = 'متوسط';
  static const String riskHigh = 'عالي';

  // نصوص عامة
  static const String loading = 'جاري التحميل...';
  static const String error = 'حدث خطأ';
  static const String retry = 'إعادة المحاولة';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String save = 'حفظ';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String search = 'بحث';
  static const String filter = 'تصفية';
  static const String all = 'الكل';
  static const String viewAll = 'عرض الكل';
  static const String noResults = 'لا توجد نتائج';
  static const String noData = 'لا توجد بيانات';

  // نصوص الحالات الفارغة
  static const String emptySignals = 'لا توجد إشارات حالياً';
  static const String emptySignalsDesc = 'سنُعلمك فور ظهور إشارات جديدة';
  static const String emptyWatchlist = 'قائمة المتابعة فارغة';
  static const String emptyWatchlistDesc = 'أضف أسهماً لمتابعتها';
  static const String emptyAlerts = 'لا توجد تنبيهات';
  static const String emptyAlertsDesc = 'ستظهر التنبيهات هنا';

  // نصوص المصادقة
  static const String login = 'تسجيل الدخول';
  static const String register = 'إنشاء حساب';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String orContinueWith = 'أو المتابعة بـ';

  // نصوص Onboarding
  static const String riskDisclaimer = 'إقرار المخاطر';
  static const String legalDisclaimer = 'التنويه القانوني';
  static const String acceptAndContinue = 'موافق ومتابعة';
  static const String riskDisclaimerText = '''
التداول في الأسواق المالية ينطوي على مخاطر عالية قد تؤدي إلى خسارة رأس المال.

• هذا التطبيق يقدم تحليلات وإشارات استرشادية فقط
• لا نضمن أي أرباح أو نتائج محددة
• أنت المسؤول الوحيد عن قراراتك الاستثمارية
• استثمر فقط ما يمكنك تحمل خسارته
''';

  // نصوص Paywall
  static const String freeTrial = 'تجربة مجانية';
  static const String freeTrialDays = '14 يوم';
  static const String startFreeTrial = 'ابدأ التجربة المجانية';
  static const String subscriptionFeatures = 'مميزات الاشتراك';

  // نصوص السوق
  static const String marketSummary = 'ملخص السوق';
  static const String mainIndex = 'المؤشر الرئيسي';
  static const String lastUpdate = 'آخر تحديث';
  static const String topGainers = 'الأكثر ارتفاعاً';
  static const String topLosers = 'الأكثر انخفاضاً';
  static const String mostActive = 'الأكثر نشاطاً';
  static const String todaySignals = 'إشارات اليوم';

  // نصوص الأسهم
  static const String stocks = 'الأسهم';
  static const String funds = 'الصناديق';
  static const String overview = 'نظرة عامة';
  static const String chart = 'الرسم البياني';
  static const String stats = 'الإحصائيات';
  static const String alerts = 'التنبيهات';
  static const String price = 'السعر';
  static const String change = 'التغير';
  static const String volume = 'الحجم';
  static const String high = 'أعلى';
  static const String low = 'أدنى';
  static const String open = 'الافتتاح';
  static const String close = 'الإغلاق';

  // نصوص التعليم
  static const String educationBasics = 'أساسيات التداول';
  static const String educationTechnical = 'التحليل الفني';
  static const String educationRisk = 'إدارة المخاطر';
  static const String educationPsychology = 'سيكولوجية التداول';

  // نصوص الإعدادات
  static const String notifications = 'الإشعارات';
  static const String signalAlerts = 'تنبيهات الإشارات';
  static const String priceAlerts = 'تنبيهات الأسعار';
  static const String quietMode = 'وضع الهدوء';
  static const String darkMode = 'الوضع الداكن';
  static const String language = 'اللغة';
  static const String about = 'حول التطبيق';
  static const String privacyPolicy = 'سياسة الخصوصية';
  static const String termsOfService = 'شروط الاستخدام';
  static const String logout = 'تسجيل الخروج';

  // العملة
  static const String currency = 'ج.م';
  static const String currencyEn = 'EGP';
}
