import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة الاستكشاف
class ExploreScreen extends StatefulWidget {
  final Function(String)? onStockTap;
  final Function(String)? onFundTap;

  const ExploreScreen({
    super.key,
    this.onStockTap,
    this.onFundTap,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _stocks = [
    {'symbol': 'COMI', 'name': 'البنك التجاري الدولي', 'price': 68.50, 'change': 2.35, 'sector': 'البنوك', 'chart': [65.0, 66.0, 67.0, 68.0, 68.5]},
    {'symbol': 'ETEL', 'name': 'المصرية للاتصالات', 'price': 24.80, 'change': -1.20, 'sector': 'الاتصالات', 'chart': [26.0, 25.5, 25.0, 24.9, 24.8]},
    {'symbol': 'TMGH', 'name': 'طلعت مصطفى القابضة', 'price': 45.20, 'change': 5.80, 'sector': 'العقارات', 'chart': [42.0, 43.0, 44.0, 44.5, 45.2]},
    {'symbol': 'ORHD', 'name': 'أوراسكوم للتنمية', 'price': 12.30, 'change': 4.20, 'sector': 'العقارات', 'chart': [11.5, 11.8, 12.0, 12.2, 12.3]},
    {'symbol': 'SWDY', 'name': 'السويدي إليكتريك', 'price': 18.90, 'change': -2.10, 'sector': 'الصناعة', 'chart': [20.0, 19.5, 19.2, 19.0, 18.9]},
    {'symbol': 'HRHO', 'name': 'هيرميس القابضة', 'price': 32.40, 'change': 1.50, 'sector': 'الخدمات المالية', 'chart': [31.0, 31.5, 32.0, 32.2, 32.4]},
    {'symbol': 'AMOC', 'name': 'الإسكندرية للزيوت', 'price': 8.75, 'change': 0.85, 'sector': 'الأغذية', 'chart': [8.2, 8.4, 8.5, 8.6, 8.75]},
  ];

  final List<Map<String, dynamic>> _funds = [
    {'id': 'F1', 'name': 'صندوق بنك مصر', 'nav': 125.50, 'change': 1.20, 'type': 'أسهم'},
    {'id': 'F2', 'name': 'صندوق CIB', 'nav': 98.30, 'change': 0.85, 'type': 'متوازن'},
    {'id': 'F3', 'name': 'صندوق الأهلي', 'nav': 156.80, 'change': -0.45, 'type': 'أسهم'},
    {'id': 'F4', 'name': 'صندوق QNB', 'nav': 112.40, 'change': 0.60, 'type': 'سندات'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredStocks {
    if (_searchQuery.isEmpty) return _stocks;
    return _stocks.where((stock) {
      final name = stock['name'] as String;
      final symbol = stock['symbol'] as String;
      return name.contains(_searchQuery) || symbol.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredFunds {
    if (_searchQuery.isEmpty) return _funds;
    return _funds.where((fund) {
      final name = fund['name'] as String;
      return name.contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppConstants.tabExplore,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // شريط البحث
                    AppSearchBar(
                      controller: _searchController,
                      hintText: 'ابحث عن سهم أو صندوق...',
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      onClear: () {
                        setState(() => _searchQuery = '');
                      },
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
                  tabs: [
                    Tab(text: AppConstants.stocks),
                    Tab(text: AppConstants.funds),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // المحتوى
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // الأسهم
                    _buildStocksTab(isDark),
                    // الصناديق
                    _buildFundsTab(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStocksTab(bool isDark) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonLoader.card(height: 80),
        ),
      );
    }

    if (_filteredStocks.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: AppConstants.noResults,
        description: 'جرب البحث بكلمات مختلفة',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        setState(() => _isLoading = true);
        await _loadData();
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredStocks.length,
        itemBuilder: (context, index) {
          final stock = _filteredStocks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StockCard(
              name: stock['name'],
              symbol: stock['symbol'],
              price: stock['price'],
              changePercent: stock['change'],
              chartData: (stock['chart'] as List?)?.cast<double>(),
              onTap: () => widget.onStockTap?.call(stock['symbol']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFundsTab(bool isDark) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonLoader.card(height: 80),
        ),
      );
    }

    if (_filteredFunds.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: AppConstants.noResults,
        description: 'جرب البحث بكلمات مختلفة',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        setState(() => _isLoading = true);
        await _loadData();
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredFunds.length,
        itemBuilder: (context, index) {
          final fund = _filteredFunds[index];
          final changeColor = (fund['change'] as double) >= 0 ? AppColors.positive : AppColors.negative;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              variant: AppCardVariant.defaultCard,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onFundTap?.call(fund['id']);
              },
              child: Row(
                children: [
                  // التغير
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (fund['change'] as double) >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: changeColor,
                          size: 18,
                        ),
                        Text(
                          '${(fund['change'] as double).abs()}%',
                          style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // السعر
                  Text(
                    '${fund['nav']} ${AppConstants.currency}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // معلومات الصندوق
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fund['name'],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          fund['type'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
