import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'app_card.dart';
import 'sparkline_chart.dart';

/// مكون بطاقة السهم
class StockCard extends StatelessWidget {
  final String name;
  final String symbol;
  final double price;
  final double changePercent;
  final List<double>? chartData;
  final VoidCallback? onTap;
  final bool isCompact;

  const StockCard({
    super.key,
    required this.name,
    required this.symbol,
    required this.price,
    required this.changePercent,
    this.chartData,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final changeColor = changePercent >= 0 ? AppColors.positive : AppColors.negative;

    if (isCompact) {
      return _buildCompactCard(context, isDark, changeColor);
    }

    return AppCard(
      variant: AppCardVariant.defaultCard,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Row(
        children: [
          // الرسم البياني
          if (chartData != null && chartData!.isNotEmpty)
            SizedBox(
              width: 60,
              height: 30,
              child: SparklineChart(
                data: chartData!,
                color: changeColor,
              ),
            ),
          
          const SizedBox(width: 12),
          
          // السعر والتغير
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${price.toStringAsFixed(2)} ${AppConstants.currency}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      changePercent >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: changeColor,
                      size: 16,
                    ),
                    Text(
                      '${changePercent.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // اسم السهم
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 2),
              Text(
                symbol,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, bool isDark, Color changeColor) {
    return AppCard(
      variant: AppCardVariant.defaultCard,
      padding: const EdgeInsets.all(12),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // اسم السهم
          Text(
            name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            symbol,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.right,
          ),
          
          const SizedBox(height: 8),
          
          // الرسم البياني
          if (chartData != null && chartData!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 30,
              child: SparklineChart(
                data: chartData!,
                color: changeColor,
              ),
            ),
          
          const SizedBox(height: 8),
          
          // السعر والتغير
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                '${price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
