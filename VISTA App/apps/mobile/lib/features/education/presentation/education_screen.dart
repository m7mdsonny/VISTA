import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة التعليم
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  bool _isLoading = true;
  String _selectedCategory = 'الكل';

  final List<String> _categories = ['الكل', 'أساسيات', 'تحليل فني', 'إدارة مخاطر', 'استراتيجيات'];

  final List<Map<String, dynamic>> _lessons = [
    {
      'id': '1',
      'title': 'مقدمة في سوق الأسهم',
      'description': 'تعرف على أساسيات سوق الأسهم وكيفية عمله',
      'category': 'أساسيات',
      'duration': '5 دقائق',
      'icon': Icons.school,
      'color': AppColors.primary,
      'isCompleted': true,
    },
    {
      'id': '2',
      'title': 'فهم المؤشرات',
      'description': 'ما هي مؤشرات السوق وكيف تقرأها',
      'category': 'أساسيات',
      'duration': '7 دقائق',
      'icon': Icons.analytics,
      'color': AppColors.positive,
      'isCompleted': true,
    },
    {
      'id': '3',
      'title': 'قراءة الرسوم البيانية',
      'description': 'أنواع الرسوم البيانية وكيفية تفسيرها',
      'category': 'تحليل فني',
      'duration': '10 دقائق',
      'icon': Icons.show_chart,
      'color': AppColors.warning,
      'isCompleted': false,
    },
    {
      'id': '4',
      'title': 'مؤشر RSI',
      'description': 'فهم مؤشر القوة النسبية واستخدامه',
      'category': 'تحليل فني',
      'duration': '8 دقائق',
      'icon': Icons.trending_up,
      'color': AppColors.primary,
      'isCompleted': false,
    },
    {
      'id': '5',
      'title': 'إدارة المخاطر',
      'description': 'كيف تحمي رأس مالك من الخسائر',
      'category': 'إدارة مخاطر',
      'duration': '12 دقائق',
      'icon': Icons.shield,
      'color': AppColors.negative,
      'isCompleted': false,
    },
    {
      'id': '6',
      'title': 'وقف الخسارة',
      'description': 'متى وكيف تستخدم أوامر وقف الخسارة',
      'category': 'إدارة مخاطر',
      'duration': '6 دقائق',
      'icon': Icons.security,
      'color': AppColors.warning,
      'isCompleted': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredLessons {
    if (_selectedCategory == 'الكل') return _lessons;
    return _lessons.where((l) => l['category'] == _selectedCategory).toList();
  }

  int get _completedCount => _lessons.where((l) => l['isCompleted'] == true).length;

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
            AppConstants.screenEducation,
            style: TextStyle(
              color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            ),
          ),
        ),
        body: _isLoading
            ? ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SkeletonLoader.card(height: 100),
                ),
              )
            : Column(
                children: [
                  // التقدم
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppCard(
                      variant: AppCardVariant.elevated,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.positive.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_completedCount/${_lessons.length}',
                                  style: TextStyle(
                                    color: AppColors.positive,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'تقدمك في التعلم',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.emoji_events, color: AppColors.warning),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _completedCount / _lessons.length,
                              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              valueColor: AlwaysStoppedAnimation(AppColors.positive),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // الفئات
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FilterChips(
                      options: _categories,
                      selectedOption: _selectedCategory,
                      onSelected: (option) {
                        setState(() => _selectedCategory = option);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // الدروس
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredLessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _filteredLessons[index];
                        final isCompleted = lesson['isCompleted'] as bool;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            variant: AppCardVariant.defaultCard,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showLessonSheet(context, isDark, lesson);
                            },
                            child: Row(
                              children: [
                                // علامة الإكمال
                                if (isCompleted)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.positive,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.chevron_left,
                                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                                  ),
                                
                                const Spacer(),
                                
                                // المحتوى
                                Expanded(
                                  flex: 10,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        lesson['title'],
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lesson['description'],
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            lesson['duration'],
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (lesson['color'] as Color).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              lesson['category'],
                                              style: TextStyle(
                                                color: lesson['color'],
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(width: 12),
                                
                                // الأيقونة
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: (lesson['color'] as Color).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    lesson['icon'],
                                    color: lesson['color'],
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showLessonSheet(BuildContext context, bool isDark, Map<String, dynamic> lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // المقبض
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
              
              // العنوان
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                    Text(
                      lesson['title'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // المحتوى
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        lesson['description'],
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'محتوى الدرس سيظهر هنا...\n\n'
                        'هذا نص تجريبي يمثل محتوى الدرس التعليمي. '
                        'في التطبيق الفعلي، سيتم عرض المحتوى التعليمي الكامل '
                        'مع الصور والرسوم التوضيحية والأمثلة العملية.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),
              
              // زر الإكمال
              Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(
                  text: lesson['isCompleted'] ? 'مكتمل ✓' : 'إكمال الدرس',
                  isFullWidth: true,
                  variant: lesson['isCompleted'] ? AppButtonVariant.secondary : AppButtonVariant.primary,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      lesson['isCompleted'] = true;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
