import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة تفاصيل السهم
class StockDetailsScreen extends StatefulWidget {
  final String stockSymbol;

  const StockDetailsScreen({
    super.key,
    required this.stockSymbol,
  });

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isFavorite = false;

  // بيانات تجريبية
  final Map<String, dynamic> _stock = {
    'name': 'البنك التجاري الدولي',
    'symbol': 'COMI',
    'price': 68.50,
    'change': 1.58,
    'changePercent': 2.35,
    'open': 67.20,
    'high': 69.10,
    'low': 66.80,
    'close': 66.92,
    'volume': 2450000,
    'marketCap': 125000000000,
    'pe': 12.5,
    'eps': 5.48,
    'dividend': 2.5,
    'sector': 'البنوك',
    'chartData': [65.0, 66.0, 67.0, 68.0, 67.5, 68.2, 68.5],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final changeColor = (_stock['changePercent'] as double) >= 0 ? AppColors.positive : AppColors.negative;

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
            widget.stockSymbol,
            style: TextStyle(
              color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isFavorite = !_isFavorite);
              },
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? AppColors.warning : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // معلومات السهم الرئيسية
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _stock['name'],
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _stock['sector'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                          ),
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
                                    (_stock['changePercent'] as double) >= 0
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: changeColor,
                                  ),
                                  Text(
                                    '${(_stock['changePercent'] as double).abs()}%',
                                    style: TextStyle(
                                      color: changeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${(_stock['change'] as double) >= 0 ? '+' : ''}${_stock['change']})',
                                    style: TextStyle(
                                      color: changeColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_stock['price']} ${AppConstants.currency}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // التبويبات
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(fontSize: 13),
                      tabs: [
                        Tab(text: AppConstants.overview),
                        Tab(text: AppConstants.chart),
                        Tab(text: AppConstants.stats),
                        Tab(text: AppConstants.alerts),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // محتوى التبويبات
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(isDark, changeColor),
                        _buildChartTab(isDark, changeColor),
                        _buildStatsTab(isDark),
                        _buildAlertsTab(isDark),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark, Color changeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // الرسم البياني المصغر
          AppCard(
            variant: AppCardVariant.elevated,
            child: SizedBox(
              height: 150,
              child: SparklineChart(
                data: (_stock['chartData'] as List).cast<double>(),
                color: changeColor,
                strokeWidth: 3,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // بيانات اليوم
          AppCard(
            variant: AppCardVariant.defaultCard,
            child: Column(
              children: [
                _buildDataRow(context, isDark, AppConstants.open, '${_stock['open']} ${AppConstants.currency}'),
                const Divider(height: 24),
                _buildDataRow(context, isDark, AppConstants.high, '${_stock['high']} ${AppConstants.currency}', valueColor: AppColors.positive),
                const Divider(height: 24),
                _buildDataRow(context, isDark, AppConstants.low, '${_stock['low']} ${AppConstants.currency}', valueColor: AppColors.negative),
                const Divider(height: 24),
                _buildDataRow(context, isDark, AppConstants.close, '${_stock['close']} ${AppConstants.currency}'),
                const Divider(height: 24),
                _buildDataRow(context, isDark, AppConstants.volume, _formatNumber(_stock['volume'])),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildChartTab(bool isDark, Color changeColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // فترات الرسم البياني
          FilterChips(
            options: const ['يوم', 'أسبوع', 'شهر', '3 أشهر', 'سنة'],
            selectedOption: 'شهر',
            onSelected: (option) {},
          ),
          
          const SizedBox(height: 24),
          
          // الرسم البياني
          Expanded(
            child: AppCard(
              variant: AppCardVariant.elevated,
              child: SparklineChart(
                data: (_stock['chartData'] as List).cast<double>(),
                color: changeColor,
                strokeWidth: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          AppCard(
            variant: AppCardVariant.defaultCard,
            child: Column(
              children: [
                _buildDataRow(context, isDark, 'القيمة السوقية', _formatNumber(_stock['marketCap']) + ' ${AppConstants.currency}'),
                const Divider(height: 24),
                _buildDataRow(context, isDark, 'مضاعف الربحية (P/E)', '${_stock['pe']}'),
                const Divider(height: 24),
                _buildDataRow(context, isDark, 'ربحية السهم (EPS)', '${_stock['eps']} ${AppConstants.currency}'),
                const Divider(height: 24),
                _buildDataRow(context, isDark, 'عائد التوزيعات', '${_stock['dividend']}%'),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          EmptyState(
            icon: Icons.notifications_outlined,
            title: 'لا توجد تنبيهات',
            description: 'أنشئ تنبيهاً للحصول على إشعار عند وصول السعر لمستوى معين',
            actionText: 'إنشاء تنبيه',
            onAction: () {
              HapticFeedback.lightImpact();
              _showCreateAlertSheet(context, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, bool isDark, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
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
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)} ألف';
    }
    return number.toString();
  }

  void _showCreateAlertSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'إنشاء تنبيه سعر',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'السعر المستهدف',
                    hintText: 'مثال: 70.00',
                    suffixText: AppConstants.currency,
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: AppConstants.cancel,
                        variant: AppButtonVariant.outline,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'إنشاء',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
