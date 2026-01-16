import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog محسّن لإنشاء تنبيهات سعر
class CreateAlertDialog extends StatefulWidget {
  final String stockSymbol;
  final String stockName;
  final double currentPrice;
  final Function(String type, double? threshold) onCreate;

  const CreateAlertDialog({
    super.key,
    required this.stockSymbol,
    required this.stockName,
    required this.currentPrice,
    required this.onCreate,
  });

  static Future<void> show(
    BuildContext context, {
    required String stockSymbol,
    required String stockName,
    required double currentPrice,
    required Function(String type, double? threshold) onCreate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAlertDialog(
        stockSymbol: stockSymbol,
        stockName: stockName,
        currentPrice: currentPrice,
        onCreate: onCreate,
      ),
    );
  }

  @override
  State<CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends State<CreateAlertDialog> {
  String _selectedType = 'price_above';
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default threshold (5% above current price)
    _priceController.text = (widget.currentPrice * 1.05).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _createAlert() {
    final threshold = double.tryParse(_priceController.text);
    if (threshold == null || threshold <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال سعر صحيح')),
      );
      return;
    }

    widget.onCreate(_selectedType, threshold);
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('تم إنشاء التنبيه بنجاح'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'إنشاء تنبيه سعر',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.stockName} (${widget.stockSymbol})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 24),

          // Alert type selection
          Text(
            'نوع التنبيه',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'price_above',
                label: Text('أعلى من'),
                icon: Icon(Icons.trending_up),
              ),
              ButtonSegment(
                value: 'price_below',
                label: Text('أقل من'),
                icon: Icon(Icons.trending_down),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (Set<String> selected) {
              setState(() {
                _selectedType = selected.first;
                HapticFeedback.selectionClick();
              });
            },
          ),

          const SizedBox(height: 24),

          // Price input
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'السعر المستهدف',
              hintText: 'مثال: ${widget.currentPrice.toStringAsFixed(2)}',
              prefixIcon: Icon(Icons.attach_money),
              suffixText: 'ج.م',
            ),
          ),

          const SizedBox(height: 8),
          Text(
            'السعر الحالي: ${widget.currentPrice.toStringAsFixed(2)} ج.م',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),

          const SizedBox(height: 24),

          // Create button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createAlert,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'إنشاء التنبيه',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
