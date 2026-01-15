import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة مركز التنبيهات
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _isLoading = true;

  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'type': 'signal',
      'title': 'إشارة شراء جديدة',
      'message': 'إشارة شراء على سهم البنك التجاري الدولي (COMI)',
      'time': 'منذ 5 دقائق',
      'isRead': false,
    },
    {
      'id': '2',
      'type': 'price',
      'title': 'تنبيه سعر',
      'message': 'وصل سهم طلعت مصطفى (TMGH) إلى السعر المستهدف 45.00',
      'time': 'منذ ساعة',
      'isRead': false,
    },
    {
      'id': '3',
      'type': 'market',
      'title': 'تحديث السوق',
      'message': 'ارتفاع مؤشر EGX30 بنسبة 2% في جلسة اليوم',
      'time': 'منذ 3 ساعات',
      'isRead': true,
    },
    {
      'id': '4',
      'type': 'signal',
      'title': 'إشارة بيع',
      'message': 'إشارة بيع على سهم المصرية للاتصالات (ETEL)',
      'time': 'أمس',
      'isRead': true,
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

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'signal':
        return Icons.show_chart;
      case 'price':
        return Icons.notifications_active;
      case 'market':
        return Icons.trending_up;
      default:
        return Icons.info_outline;
    }
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'signal':
        return AppColors.primary;
      case 'price':
        return AppColors.warning;
      case 'market':
        return AppColors.positive;
      default:
        return AppColors.primary;
    }
  }

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
            AppConstants.screenAlerts,
            style: TextStyle(
              color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  for (var alert in _alerts) {
                    alert['isRead'] = true;
                  }
                });
              },
              child: Text(
                'قراءة الكل',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SkeletonLoader.card(height: 80),
                ),
              )
            : _alerts.isEmpty
                ? EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: 'لا توجد تنبيهات',
                    description: 'ستظهر هنا جميع التنبيهات والإشعارات',
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      HapticFeedback.mediumImpact();
                      setState(() => _isLoading = true);
                      await _loadData();
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        final alert = _alerts[index];
                        final isRead = alert['isRead'] as bool;
                        final alertColor = _getAlertColor(alert['type']);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key(alert['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: AppColors.negative,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              setState(() {
                                _alerts.removeAt(index);
                              });
                            },
                            child: AppCard(
                              variant: AppCardVariant.defaultCard,
                              backgroundColor: isRead
                                  ? null
                                  : (isDark ? AppColors.surfaceDark : AppColors.primary.withOpacity(0.05)),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  alert['isRead'] = true;
                                });
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // النقطة غير المقروءة
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  
                                  const Spacer(),
                                  
                                  // المحتوى
                                  Expanded(
                                    flex: 10,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              alert['time'],
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                            Text(
                                              alert['title'],
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          alert['message'],
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 12),
                                  
                                  // الأيقونة
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: alertColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getAlertIcon(alert['type']),
                                      color: alertColor,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
