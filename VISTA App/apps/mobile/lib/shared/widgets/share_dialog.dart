import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Share Dialog محسّن لمشاركة الإشارات والبيانات
class ShareDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? stockSymbol;
  final String? stockName;
  final Map<String, dynamic>? additionalData;

  const ShareDialog({
    super.key,
    required this.title,
    required this.content,
    this.stockSymbol,
    this.stockName,
    this.additionalData,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String content,
    String? stockSymbol,
    String? stockName,
    Map<String, dynamic>? additionalData,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareDialog(
        title: title,
        content: content,
        stockSymbol: stockSymbol,
        stockName: stockName,
        additionalData: additionalData,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'مشاركة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Share options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                icon: Icons.share,
                label: 'مشاركة',
                color: Colors.blue,
                onTap: () => _share(context),
              ),
              _ShareOption(
                icon: Icons.copy,
                label: 'نسخ',
                color: Colors.green,
                onTap: () => _copyToClipboard(context),
              ),
              _ShareOption(
                icon: Icons.image_outlined,
                label: 'صورة',
                color: Colors.purple,
                onTap: () => _shareAsImage(context),
              ),
              _ShareOption(
                icon: Icons.link,
                label: 'رابط',
                color: Colors.orange,
                onTap: () => _shareLink(context),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _share(BuildContext context) {
    final shareText = _buildShareText();
    Share.share(
      shareText,
      subject: title,
    );
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  void _copyToClipboard(BuildContext context) {
    final shareText = _buildShareText();
    Clipboard.setData(ClipboardData(text: shareText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('تم النسخ إلى الحافظة'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  void _shareAsImage(BuildContext context) {
    // TODO: Implement image generation (screenshot or custom widget)
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  void _shareLink(BuildContext context) {
    final link = 'https://vista.app/signal/${stockSymbol ?? ''}';
    Share.share(link, subject: title);
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  String _buildShareText() {
    final buffer = StringBuffer();
    buffer.writeln(title);
    buffer.writeln();
    if (stockName != null) {
      buffer.writeln('السهم: $stockName ${stockSymbol != null ? '($stockSymbol)' : ''}');
    }
    buffer.writeln(content);
    buffer.writeln();
    buffer.writeln('📱 تطبيق Vista - تحليل ذكي للسوق المصرية');
    return buffer.toString();
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
