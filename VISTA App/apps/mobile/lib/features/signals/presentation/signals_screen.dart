import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة الإشارات
class SignalsScreen extends StatefulWidget {
  final Function(String)? onSignalTap;

  const SignalsScreen({
    super.key,
    this.onSignalTap,
  });

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  bool _isLoading = true;
  String _selectedFilter = AppConstants.all;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = [
    AppConstants.all,
    AppConstants.signalBuy,
    AppConstants.signalSell,
    AppConstants.signalHold,
  ];

  final List<Map<String, dynamic>> _signals = [
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
    {
      'id': '3',
      'stockName': 'طلعت مصطفى القابضة',
      'stockSymbol': 'TMGH',
      'price': 45.20,
      'changePercent': 5.80,
      'signalType': SignalType.buy,
      'confidence': 91,
      'riskLevel': RiskLevel.low,
    },
    {
      'id': '4',
      'stockName': 'أوراسكوم للتنمية',
      'stockSymbol': 'ORHD',
      'price': 12.30,
      'changePercent': 4.20,
      'signalType': SignalType.hold,
      'confidence': 65,
      'riskLevel': RiskLevel.medium,
    },
    {
      'id': '5',
      'stockName': 'السويدي إليكتريك',
      'stockSymbol': 'SWDY',
      'price': 18.90,
      'changePercent': -2.10,
      'signalType': SignalType.sell,
      'confidence': 78,
      'riskLevel': RiskLevel.high,
    },
  ];

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

  List<Map<String, dynamic>> get _filteredSignals {
    return _signals.where((signal) {
      // فلترة حسب النوع
      if (_selectedFilter != AppConstants.all) {
        final signalType = signal['signalType'] as SignalType;
        if (_selectedFilter == AppConstants.signalBuy && signalType != SignalType.buy) return false;
        if (_selectedFilter == AppConstants.signalSell && signalType != SignalType.sell) return false;
        if (_selectedFilter == AppConstants.signalHold && signalType != SignalType.hold) return false;
      }

      // فلترة حسب البحث
      if (_searchQuery.isNotEmpty) {
        final name = signal['stockName'] as String;
        final symbol = signal['stockSymbol'] as String;
        if (!name.contains(_searchQuery) && !symbol.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
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
                      AppConstants.tabSignals,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // شريط البحث
                    AppSearchBar(
                      controller: _searchController,
                      hintText: 'ابحث عن سهم...',
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      onClear: () {
                        setState(() => _searchQuery = '');
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // شرائح الفلترة
                    FilterChips(
                      options: _filters,
                      selectedOption: _selectedFilter,
                      onSelected: (option) {
                        setState(() => _selectedFilter = option);
                      },
                    ),
                  ],
                ),
              ),

              // قائمة الإشارات
              Expanded(
                child: _isLoading
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 5,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: SignalCardSkeleton(),
                        ),
                      )
                    : _filteredSignals.isEmpty
                        ? EmptyState(
                            icon: Icons.show_chart,
                            title: AppConstants.emptySignals,
                            description: AppConstants.emptySignalsDesc,
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              HapticFeedback.mediumImpact();
                              setState(() => _isLoading = true);
                              await _loadData();
                            },
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredSignals.length,
                              itemBuilder: (context, index) {
                                final signal = _filteredSignals[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
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
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
