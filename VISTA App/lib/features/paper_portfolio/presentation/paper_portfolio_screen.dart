import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة المحفظة التجريبية
class PaperPortfolioScreen extends StatefulWidget {
  const PaperPortfolioScreen({super.key});

  @override
  State<PaperPortfolioScreen> createState() => _PaperPortfolioScreenState();
}

class _PaperPortfolioScreenState extends State<PaperPortfolioScreen> {
  bool _isLoading = true;

  // بيانات تجريبية
  final Map<String, dynamic> _portfolio = {
    'balance': 100000.0,
    'invested': 45000.0,
    'profit': 3250.0,
    'profitPercent': 7.22,
  };

  final List<Map<String, dynamic>> _positions = [
    {
      'symbol': 'COMI',
      'name': 'البنك التجاري الدولي',
      'shares': 100,
      'avgPrice': 65.00,
      'currentPrice': 68.50,
      'profit': 350.0,
      'profitPercent': 5.38,
    },
    {
      'symbol': 'TMGH',
      'name': 'طلعت مصطفى',
      'shares': 200,
      'avgPrice': 42.00,
      'currentPrice': 45.20,
      'profit': 640.0,
      'profitPercent': 7.62,
    },
    {
      'symbol': 'ETEL',
      'name': 'المصرية للاتصالات',
      'shares': 150,
      'avgPrice': 26.00,
      'currentPrice': 24.80,
      'profit': -180.0,
      'profitPercent': -4.62,
    },
  ];

  final List<Map<String, dynamic>> _transactions = [
    {'type': 'buy', 'symbol': 'COMI', 'shares': 100, 'price': 65.00, 'date': '2024-01-10'},
    {'type': 'buy', 'symbol': 'TMGH', 'shares': 200, 'price': 42.00, 'date': '2024-01-08'},
    {'type': 'buy', 'symbol': 'ETEL', 'shares': 150, 'price': 26.00, 'date': '2024-01-05'},
    {'type': 'sell', 'symbol': 'SWDY', 'shares': 50, 'price': 19.50, 'date': '2024-01-03'},
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profitColor = (_portfolio['profit'] as double) >= 0 ? AppColors.positive : AppColors.negative;

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
            AppConstants.screenPaperPortfolio,
            style: TextStyle(
              color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showResetDialog(context, isDark);
              },
              icon: Icon(
                Icons.refresh,
                color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ملخص المحفظة
                    AppCard(
                      variant: AppCardVariant.elevated,
                      child: Column(
                        children: [
                          // الرصيد الكلي
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: profitColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      (_portfolio['profit'] as double) >= 0
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color: profitColor,
                                    ),
                                    Text(
                                      '${(_portfolio['profitPercent'] as double).abs()}%',
                                      style: TextStyle(
                                        color: profitColor,
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
                                    'إجمالي المحفظة',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${_formatNumber(_portfolio['balance'] + _portfolio['profit'])} ${AppConstants.currency}',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // التفاصيل
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  context,
                                  isDark,
                                  'الربح/الخسارة',
                                  '${(_portfolio['profit'] as double) >= 0 ? '+' : ''}${_formatNumber(_portfolio['profit'])}',
                                  profitColor,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  context,
                                  isDark,
                                  'المستثمر',
                                  _formatNumber(_portfolio['invested']),
                                  null,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  context,
                                  isDark,
                                  'النقدي',
                                  _formatNumber(_portfolio['balance'] - _portfolio['invested']),
                                  null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // المراكز
                    SectionHeader(
                      title: 'المراكز المفتوحة',
                      actionText: '',
                    ),

                    if (_positions.isEmpty)
                      EmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'لا توجد مراكز',
                        description: 'ابدأ التداول التجريبي بشراء أسهم',
                      )
                    else
                      ...(_positions.map((position) {
                        final positionProfitColor = (position['profit'] as double) >= 0
                            ? AppColors.positive
                            : AppColors.negative;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            variant: AppCardVariant.defaultCard,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${position['currentPrice']} ${AppConstants.currency}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: positionProfitColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${(position['profitPercent'] as double) >= 0 ? '+' : ''}${position['profitPercent']}%',
                                            style: TextStyle(
                                              color: positionProfitColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          position['name'],
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${position['shares']} سهم @ ${position['avgPrice']}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        text: 'بيع',
                                        variant: AppButtonVariant.outline,
                                        size: AppButtonSize.small,
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: AppButton(
                                        text: 'شراء المزيد',
                                        size: AppButtonSize.small,
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      })),

                    const SizedBox(height: 24),

                    // سجل العمليات
                    SectionHeader(
                      title: 'سجل العمليات',
                      actionText: '',
                    ),

                    ...(_transactions.take(3).map((tx) {
                      final isBuy = tx['type'] == 'buy';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          variant: AppCardVariant.defaultCard,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tx['date'],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${tx['shares']} سهم @ ${tx['price']}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tx['symbol'],
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isBuy ? AppColors.positive : AppColors.negative).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isBuy ? 'شراء' : 'بيع',
                                      style: TextStyle(
                                        color: isBuy ? AppColors.positive : AppColors.negative,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    })),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showTradeSheet(context, isDark);
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('تداول جديد', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, bool isDark, String label, String value, Color? color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(2);
  }

  void _showResetDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إعادة تعيين المحفظة', textAlign: TextAlign.right),
          content: const Text(
            'سيتم حذف جميع المراكز والعمليات وإعادة الرصيد إلى 100,000 جنيه. هل أنت متأكد؟',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppConstants.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // إعادة التعيين
              },
              child: Text(
                'إعادة تعيين',
                style: TextStyle(color: AppColors.negative),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTradeSheet(BuildContext context, bool isDark) {
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
                  'تداول جديد',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'رمز السهم',
                    hintText: 'مثال: COMI',
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'عدد الأسهم',
                    hintText: 'مثال: 100',
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
                        text: 'بيع',
                        variant: AppButtonVariant.outline,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'شراء',
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
