import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة اليوم - ملخص السوق
class TodayScreen extends StatefulWidget {
  final Function(String)? onSignalTap;
  final Function(String)? onStockTap;
  final VoidCallback? onViewAllSignals;
  final VoidCallback? onViewAllStocks;

  const TodayScreen({
    super.key,
    this.onSignalTap,
    this.onStockTap,
    this.onViewAllSignals,
    this.onViewAllStocks,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await _loadData();
  }

  // بيانات تجريبية
  final _marketData = {
    'indexName': 'EGX30',
    'value': 28456.78,
    'change': 234.56,
    'changePercent': 0.83,
    'chartData': [28100.0, 28200.0, 28150.0, 28300.0, 28250.0, 28400.0, 28456.78],
    'lastUpdate': '14:30',
  };

  final List<Map<String, dynamic>> _todaySignals = [
    {
      'id': '1',
      'stockName': 'البنك التجاري الدولي',
      'stockSymbol': 'COMI',
      'price': 68.50,
      'changePercent': 2.35,
      'signalType': SignalType.buy,
      'confidence': 85,
      'riskLevel': RiskLevel.low,
    },
    {
      'id': '2',
      'stockName': 'المصرية للاتصالات',
      'stockSymbol': 'ETEL',
      'price': 24.80,
      'changePercent': -1.20,
      'signalType': SignalType.sell,
      'confidence': 72,
      'riskLevel': RiskLevel.medium,
    },
  ];

  final List<Map<String, dynamic>> _topGainers = [
    {'name': 'طلعت مصطفى', 'symbol': 'TMGH', 'price': 45.20, 'change': 5.8, 'chart': [42.0, 43.0, 44.0, 44.5, 45.2]},
    {'name': 'أوراسكوم للتنمية', 'symbol': 'ORHD', 'price': 12.30, 'change': 4.2, 'chart': [11.5, 11.8, 12.0, 12.2, 12.3]},
    {'name': 'السويدي إليكتريك', 'symbol': 'SWDY', 'price': 18.90, 'change': 3.5, 'chart': [18.0, 18.3, 18.5, 18.7, 18.9]},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الإشعارات
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
                          ),
                        ),
                        // العنوان والتاريخ
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppConstants.tabToday,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getArabicDate(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ملخص السوق
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _isLoading
                        ? const SignalCardSkeleton()
                        : MarketSummaryCard(
                            indexName: _marketData['indexName'] as String,
                            value: _marketData['value'] as double,
                            change: _marketData['change'] as double,
                            changePercent: _marketData['changePercent'] as double,
                            chartData: _marketData['chartData'] as List<double>,
                            lastUpdate: _marketData['lastUpdate'] as String,
                          ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // إشارات اليوم
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: AppConstants.todaySignals,
                    onAction: widget.onViewAllSignals,
                  ),
                ),

                if (_isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: const [
                          SignalCardSkeleton(),
                          SizedBox(height: 12),
                          SignalCardSkeleton(),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final signal = _todaySignals[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: SignalCard(
                            stockName: signal['stockName'],
                            stockSymbol: signal['stockSymbol'],
                            price: signal['price'],
                            changePercent: signal['changePercent'],
                            signalType: signal['signalType'],
                            confidence: signal['confidence'],
                            riskLevel: signal['riskLevel'],
                            onTap: () => widget.onSignalTap?.call(signal['id']),
                          ),
                        );
                      },
                      childCount: _todaySignals.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // الأكثر ارتفاعاً
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: AppConstants.topGainers,
                    onAction: widget.onViewAllStocks,
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: _isLoading
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: 3,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: SizedBox(
                                width: 140,
                                child: SkeletonLoader.card(height: 140),
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _topGainers.length,
                            itemBuilder: (context, index) {
                              final stock = _topGainers[index];
                              return Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: SizedBox(
                                  width: 140,
                                  child: StockCard(
                                    name: stock['name'],
                                    symbol: stock['symbol'],
                                    price: stock['price'],
                                    changePercent: stock['change'],
                                    chartData: (stock['chart'] as List).cast<double>(),
                                    isCompact: true,
                                    onTap: () => widget.onStockTap?.call(stock['symbol']),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getArabicDate() {
    final now = DateTime.now();
    final arabicDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    final arabicMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return '${arabicDays[now.weekday % 7]}، ${now.day} ${arabicMonths[now.month - 1]}';
  }
}
