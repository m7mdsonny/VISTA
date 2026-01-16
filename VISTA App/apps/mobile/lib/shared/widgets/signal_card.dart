import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'app_card.dart';
import 'risk_badge.dart';
import 'confidence_meter.dart';

/// نوع الإشارة
enum SignalType { buy, sell, hold }

/// مكون بطاقة الإشارة
class SignalCard extends StatelessWidget {
  final String stockName;
  final String stockSymbol;
  final double price;
  final double changePercent;
  final SignalType signalType;
  final int confidence;
  final RiskLevel riskLevel;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const SignalCard({
    super.key,
    required this.stockName,
    required this.stockSymbol,
    required this.price,
    required this.changePercent,
    required this.signalType,
    required this.confidence,
    required this.riskLevel,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  Color get _signalColor {
    switch (signalType) {
      case SignalType.buy:
        return AppColors.signalBuy;
      case SignalType.sell:
        return AppColors.signalSell;
      case SignalType.hold:
        return AppColors.signalHold;
    }
  }

  String get _signalText {
    switch (signalType) {
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
    final changeColor = changePercent >= 0 ? AppColors.positive : AppColors.negative;

    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // الصف العلوي: المفضلة + اسم السهم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر المفضلة
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onFavorite?.call();
                },
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? AppColors.warning : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
                  size: 24,
                ),
              ),
              // اسم السهم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stockName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stockSymbol,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // السعر والتغير
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      changePercent >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: changeColor,
                      size: 18,
                    ),
                    Text(
                      '${changePercent.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // السعر
              Text(
                '${price.toStringAsFixed(2)} ${AppConstants.currency}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // نوع الإشارة + الثقة + المخاطرة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // مستوى المخاطرة
              RiskBadge(level: riskLevel),
              
              // نسبة الثقة
              Row(
                children: [
                  Text(
                    '${AppConstants.confidenceLabel}: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  ConfidenceMeter(
                    confidence: confidence,
                    size: 24,
                    showLabel: true,
                  ),
                ],
              ),
              
              // نوع الإشارة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _signalColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${AppConstants.signalBuy == _signalText ? 'الإشارة: ' : AppConstants.signalSell == _signalText ? 'الإشارة: ' : 'الإشارة: '}$_signalText',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
