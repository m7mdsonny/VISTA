import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة المتابعة
class WatchlistScreen extends StatefulWidget {
  final Function(String)? onStockTap;

  const WatchlistScreen({
    super.key,
    this.onStockTap,
  });

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _favorites = [
    {
      'symbol': 'COMI',
      'name': 'البنك التجاري الدولي',
      'price': 68.50,
      'change': 2.35,
      'chart': [65.0, 66.0, 67.0, 68.0, 68.5],
    },
    {
      'symbol': 'TMGH',
      'name': 'طلعت مصطفى القابضة',
      'price': 45.20,
      'change': 5.80,
      'chart': [42.0, 43.0, 44.0, 44.5, 45.2],
    },
  ];

  final List<Map<String, dynamic>> _watchlists = [
    {
      'id': '1',
      'name': 'البنوك',
      'stocks': [
        {'symbol': 'COMI', 'name': 'البنك التجاري الدولي', 'price': 68.50, 'change': 2.35},
        {'symbol': 'CIEB', 'name': 'بنك CIB', 'price': 42.30, 'change': 1.20},
      ],
    },
    {
      'id': '2',
      'name': 'العقارات',
      'stocks': [
        {'symbol': 'TMGH', 'name': 'طلعت مصطفى', 'price': 45.20, 'change': 5.80},
        {'symbol': 'ORHD', 'name': 'أوراسكوم للتنمية', 'price': 12.30, 'change': 4.20},
      ],
    },
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

  @override
  void dispose() {
    _tabController.dispose();
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر إضافة قائمة
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _showAddWatchlistDialog();
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      AppConstants.tabWatchlist,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                  tabs: const [
                    Tab(text: 'المفضلة ⭐'),
                    Tab(text: 'القوائم'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // المحتوى
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // المفضلة
                    _buildFavoritesTab(isDark),
                    // القوائم
                    _buildWatchlistsTab(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesTab(bool isDark) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonLoader.card(height: 80),
        ),
      );
    }

    if (_favorites.isEmpty) {
      return EmptyState(
        icon: Icons.star_border,
        title: AppConstants.emptyWatchlist,
        description: AppConstants.emptyWatchlistDesc,
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
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final stock = _favorites[index];
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

  Widget _buildWatchlistsTab(bool isDark) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 2,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonLoader.card(height: 120),
        ),
      );
    }

    if (_watchlists.isEmpty) {
      return EmptyState(
        icon: Icons.list_alt,
        title: 'لا توجد قوائم',
        description: 'أنشئ قائمة جديدة لتنظيم أسهمك',
        actionText: 'إنشاء قائمة',
        onAction: _showAddWatchlistDialog,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _watchlists.length,
      itemBuilder: (context, index) {
        final watchlist = _watchlists[index];
        final stocks = watchlist['stocks'] as List;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppCard(
            variant: AppCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // عنوان القائمة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.more_horiz,
                            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${stocks.length} سهم',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          watchlist['name'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // الأسهم
                ...stocks.take(3).map((stock) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => widget.onStockTap?.call(stock['symbol']),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (stock['change'] as double) >= 0
                                ? AppColors.positive.withOpacity(0.1)
                                : AppColors.negative.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(stock['change'] as double) >= 0 ? '+' : ''}${stock['change']}%',
                            style: TextStyle(
                              color: (stock['change'] as double) >= 0
                                  ? AppColors.positive
                                  : AppColors.negative,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              stock['symbol'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              stock['name'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddWatchlistDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddWatchlistSheet(),
    );
  }
}

class _AddWatchlistSheet extends StatelessWidget {
  final _nameController = TextEditingController();

  _AddWatchlistSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
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
              // المقبض
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
                'إنشاء قائمة جديدة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: _nameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'اسم القائمة',
                  hintText: 'مثال: البنوك',
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
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
    );
  }
}
