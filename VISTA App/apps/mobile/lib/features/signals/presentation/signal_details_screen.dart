import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة تفاصيل الإشارة
class SignalDetailsScreen extends StatefulWidget {
  final String signalId;
  final VoidCallback? onBack;

  const SignalDetailsScreen({
    super.key,
    required this.signalId,
    this.onBack,
  });

  @override
  State<SignalDetailsScreen> createState() => _SignalDetailsScreenState();
}

class _SignalDetailsScreenState extends State<SignalDetailsScreen> {
  bool _isLoading = true;
  bool _isFavorite = false;

  // بيانات تجريبية
  final Map<String, dynamic> _signal = {
    'stockName': 'البنك التجاري الدولي',
    'stockSymbol': 'COMI',
    'price': 68.50,
    'changePercent': 2.35,
    'signalType': SignalType.buy,
    'confidence': 85,
    'riskLevel': RiskLevel.low,
    'targetPrice': 75.00,
    'stopLoss': 64.00,
    'reasons': [
      'زيادة في حجم التداول بنسبة 40% عن المتوسط',
      'اختراق مستوى مقاومة رئيسي عند 67.50',
      'مؤشرات فنية إيجابية (RSI, MACD)',
    ],
    'risks': [
      'تقلبات السوق العامة قد تؤثر على السعر',
      'نتائج الربع القادم قد تختلف عن التوقعات',
    ],
    'createdAt': '2024-01-15 10:30',
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

  Color get _signalColor {
    final type = _signal['signalType'] as SignalType;
    switch (type) {
      case SignalType.buy:
        return AppColors.signalBuy;
      case SignalType.sell:
        return AppColors.signalSell;
      case SignalType.hold:
        return AppColors.signalHold;
    }
  }

  String get _signalText {
    final type = _signal['signalType'] as SignalType;
    switch (type) {
      case SignalType.buy:
        return AppConstants.signalBuy;
      case SignalType.sell:
        return AppConstants.signalSell;
      case SignalType.hold:
        return AppConstants.signalHold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final changeColor = (_signal['changePercent'] as double) >= 0 ? AppColors.positive : AppColors.negative;

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
              widget.onBack?.call();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_forward,
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
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // مشاركة
              },
              icon: Icon(
                Icons.share_outlined,
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // معلومات السهم
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // نوع الإشارة
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _signalColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'إشارة $_signalText',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // اسم السهم
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _signal['stockName'],
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _signal['stockSymbol'],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // السعر والتغير
                    AppCard(
                      variant: AppCardVariant.elevated,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // التغير
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: changeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  (_signal['changePercent'] as double) >= 0
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: changeColor,
                                ),
                                Text(
                                  '${(_signal['changePercent'] as double).abs()}%',
                                  style: TextStyle(
                                    color: changeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // السعر
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppConstants.price,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${_signal['price']} ${AppConstants.currency}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // نسبة الثقة ومستوى المخاطرة
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            variant: AppCardVariant.defaultCard,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  AppConstants.riskLabel,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                RiskBadge(level: _signal['riskLevel']),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            variant: AppCardVariant.defaultCard,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  AppConstants.confidenceLabel,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${_signal['confidence']}%',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.positive,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ConfidenceMeter(
                                      confidence: _signal['confidence'],
                                      size: 32,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // السعر المستهدف ووقف الخسارة
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            variant: AppCardVariant.defaultCard,
                            backgroundColor: AppColors.negative.withOpacity(0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'وقف الخسارة',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.shield_outlined, size: 16, color: AppColors.negative),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_signal['stopLoss']} ${AppConstants.currency}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.negative,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            variant: AppCardVariant.defaultCard,
                            backgroundColor: AppColors.positive.withOpacity(0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'السعر المستهدف',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.flag_outlined, size: 16, color: AppColors.positive),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_signal['targetPrice']} ${AppConstants.currency}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.positive,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // لماذا هذه الإشارة؟
                    _buildSection(
                      context,
                      isDark,
                      icon: Icons.lightbulb_outline,
                      iconColor: AppColors.warning,
                      title: AppConstants.whyThisSignal,
                      items: _signal['reasons'] as List<String>,
                    ),

                    const SizedBox(height: 16),

                    // المخاطر
                    _buildSection(
                      context,
                      isDark,
                      icon: Icons.warning_amber_outlined,
                      iconColor: AppColors.negative,
                      title: AppConstants.risks,
                      items: _signal['risks'] as List<String>,
                    ),

                    const SizedBox(height: 24),

                    // وقت الإنشاء
                    Center(
                      child: Text(
                        'تم إنشاء الإشارة: ${_signal['createdAt']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
  }) {
    return AppCard(
      variant: AppCardVariant.defaultCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // العنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // النقاط
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
