import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'app_card.dart';
import 'sparkline_chart.dart';

/// مكون بطاقة ملخص السوق
class MarketSummaryCard extends StatelessWidget {
  final String indexName;
  final double value;
  final double change;
  final double changePercent;
  final List<double>? chartData;
  final String? lastUpdate;

  const MarketSummaryCard({
    super.key,
    required this.indexName,
    required this.value,
    required this.change,
    required this.changePercent,
    this.chartData,
    this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final changeColor = changePercent >= 0 ? AppColors.positive : AppColors.negative;

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // عنوان المؤشر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الرسم البياني
              if (chartData != null && chartData!.isNotEmpty)
                SizedBox(
                  width: 80,
                  height: 40,
                  child: SparklineChart(
                    data: chartData!,
                    color: changeColor,
                  ),
                ),
              
              // اسم المؤشر
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppConstants.mainIndex,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    indexName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // القيمة والتغير
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // التغير
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 4),
                  Text(
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              // القيمة
              Text(
                value.toStringAsFixed(2).replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                ),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // آخر تحديث
          if (lastUpdate != null) ...[
            const SizedBox(height: 12),
            Text(
              '${AppConstants.lastUpdate}: $lastUpdate',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
