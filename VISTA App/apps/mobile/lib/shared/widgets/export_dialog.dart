import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

/// Export Dialog - تصدير البيانات (CSV/JSON)
class ExportDialog extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final String? fileName;

  const ExportDialog({
    super.key,
    required this.title,
    required this.data,
    this.fileName,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> data,
    String? fileName,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportDialog(
        title: title,
        data: data,
        fileName: fileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            'تصدير البيانات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            '${data.length} عنصر',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ExportButton(
                  icon: Icons.table_chart,
                  label: 'CSV',
                  color: Colors.green,
                  onTap: () => _exportCSV(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExportButton(
                  icon: Icons.code,
                  label: 'JSON',
                  color: Colors.blue,
                  onTap: () => _exportJSON(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _exportCSV(BuildContext context) {
    if (data.isEmpty) return;

    final buffer = StringBuffer();
    
    // Headers
    final headers = data.first.keys.join(',');
    buffer.writeln(headers);

    // Data rows
    for (final row in data) {
      final values = row.values.map((v) => _escapeCSV(v.toString())).join(',');
      buffer.writeln(values);
    }

    final csv = buffer.toString();
    final fileName = '${this.fileName ?? 'export'}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

    Share.share(csv, subject: fileName);
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  void _exportJSON(BuildContext context) {
    final json = JsonEncoder.withIndent('  ').convert(data);
    final fileName = '${this.fileName ?? 'export'}_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';

    Share.share(json, subject: fileName);
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
