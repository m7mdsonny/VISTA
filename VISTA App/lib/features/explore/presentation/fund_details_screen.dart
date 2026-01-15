import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة تفاصيل الصندوق
class FundDetailsScreen extends StatefulWidget {
  final String fundId;

  const FundDetailsScreen({
    super.key,
    required this.fundId,
  });

  @override
  State<FundDetailsScreen> createState() => _FundDetailsScreenState();
}

class _FundDetailsScreenState extends State<FundDetailsScreen> {
  bool _isLoading = true;

  // بيانات تجريبية
  final Map<String, dynamic> _fund = {
    'name': 'صندوق بنك مصر للأسهم',
    'type': 'أسهم',
    'nav': 125.50,
    'change': 1.20,
    'aum': 2500000000,
    'inception': '2015-01-15',
    'manager': 'بنك مصر',
    'minInvestment': 1000,
    'managementFee': 1.5,
    'performanceFee': 10,
    'ytd': 15.8,
    'oneYear': 22.5,
    'threeYear': 45.2,
    'fiveYear': 85.6,
    'chartData': [100.0, 105.0, 110.0, 108.0, 115.0, 120.0, 125.5],
    'holdings': [
      {'name': 'البنك التجاري الدولي', 'weight': 15.5},
      {'name': 'طلعت مصطفى', 'weight': 12.3},
      {'name': 'المصرية للاتصالات', 'weight': 10.8},
      {'name': 'هيرميس القابضة', 'weight': 8.5},
      {'name': 'أخرى', 'weight': 52.9},
    ],
  };

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final changeColor = (_fund['change'] as double) >= 0 ? AppColors.positive : AppColors.negative;

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
            'تفاصيل الصندوق',
            style: TextStyle(
              color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // معلومات الصندوق الرئيسية
                    AppCard(
                      variant: AppCardVariant.elevated,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _fund['type'],
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                _fund['name'],
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: changeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      (_fund['change'] as double) >= 0
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color: changeColor,
                                    ),
                                    Text(
                                      '${(_fund['change'] as double).abs()}%',
                                      style: TextStyle(
                                        color: changeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'صافي قيمة الأصول',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${_fund['nav']} ${AppConstants.currency}',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // الرسم البياني
                    AppCard(
                      variant: AppCardVariant.defaultCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'الأداء',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 150,
                            child: SparklineChart(
                              data: (_fund['chartData'] as List).cast<double>(),
                              color: changeColor,
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // العوائد
                    AppCard(
                      variant: AppCardVariant.defaultCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'العوائد',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildReturnCard(context, isDark, 'منذ بداية العام', _fund['ytd']),
                              const SizedBox(width: 8),
                              _buildReturnCard(context, isDark, 'سنة', _fund['oneYear']),
                              const SizedBox(width: 8),
                              _buildReturnCard(context, isDark, '3 سنوات', _fund['threeYear']),
                              const SizedBox(width: 8),
                              _buildReturnCard(context, isDark, '5 سنوات', _fund['fiveYear']),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // معلومات الصندوق
                    AppCard(
                      variant: AppCardVariant.defaultCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'معلومات الصندوق',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(context, isDark, 'مدير الصندوق', _fund['manager']),
                          const Divider(height: 24),
                          _buildInfoRow(context, isDark, 'حجم الأصول', _formatNumber(_fund['aum'])),
                          const Divider(height: 24),
                          _buildInfoRow(context, isDark, 'الحد الأدنى للاستثمار', '${_fund['minInvestment']} ${AppConstants.currency}'),
                          const Divider(height: 24),
                          _buildInfoRow(context, isDark, 'رسوم الإدارة', '${_fund['managementFee']}%'),
                          const Divider(height: 24),
                          _buildInfoRow(context, isDark, 'رسوم الأداء', '${_fund['performanceFee']}%'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // أكبر الحيازات
                    AppCard(
                      variant: AppCardVariant.defaultCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'أكبر الحيازات',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...(_fund['holdings'] as List).map((holding) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${holding['weight']}%',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          holding['name'],
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: (holding['weight'] as double) / 100,
                                            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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

  Widget _buildReturnCard(BuildContext context, bool isDark, String period, double value) {
    final color = value >= 0 ? AppColors.positive : AppColors.negative;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              period,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${value >= 0 ? '+' : ''}$value%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, bool isDark, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
          ),
        ),
      ],
    );
  }

  String _formatNumber(num number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)} مليار';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)} مليون';
    }
    return number.toString();
  }
}
