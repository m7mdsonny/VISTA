import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Quick Actions FAB - إجراءات سريعة محسّنة
class QuickActionsFAB extends StatefulWidget {
  final VoidCallback? onAddToWatchlist;
  final VoidCallback? onSetAlert;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;

  const QuickActionsFAB({
    super.key,
    this.onAddToWatchlist,
    this.onSetAlert,
    this.onShare,
    this.onFavorite,
  });

  @override
  State<QuickActionsFAB> createState() => _QuickActionsFABState();
}

class _QuickActionsFABState extends State<QuickActionsFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        HapticFeedback.mediumImpact();
      } else {
        _controller.reverse();
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      clipBehavior: Clip.none,
      children: [
        // Action buttons
        ..._buildActionButtons(context),

        // Main FAB
        FloatingActionButton(
          onPressed: _toggleExpanded,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(_isExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final actions = [
      if (widget.onFavorite != null)
        _ActionButton(
          icon: Icons.star,
          label: 'مفضلة',
          color: Colors.amber,
          onTap: widget.onFavorite!,
          animation: _expandAnimation,
          offset: 1,
        ),
      if (widget.onAddToWatchlist != null)
        _ActionButton(
          icon: Icons.bookmark_add,
          label: 'قائمة متابعة',
          color: Colors.blue,
          onTap: widget.onAddToWatchlist!,
          animation: _expandAnimation,
          offset: 2,
        ),
      if (widget.onSetAlert != null)
        _ActionButton(
          icon: Icons.notifications_active,
          label: 'تنبيه',
          color: Colors.orange,
          onTap: widget.onSetAlert!,
          animation: _expandAnimation,
          offset: 3,
        ),
      if (widget.onShare != null)
        _ActionButton(
          icon: Icons.share,
          label: 'مشاركة',
          color: Colors.green,
          onTap: widget.onShare!,
          animation: _expandAnimation,
          offset: 4,
        ),
    ];

    return actions;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Animation<double> animation;
  final int offset;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.animation,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Interval(
                (offset - 1) * 0.1,
                1.0,
                curve: Curves.easeOutBack,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: (offset * 72.0) + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: () {
                    onTap();
                    HapticFeedback.selectionClick();
                  },
                  backgroundColor: color,
                  child: Icon(icon, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
