import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swipeable Card - سحب لليمين/اليسار
class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final String? leftActionLabel;
  final String? rightActionLabel;
  final Color? leftActionColor;
  final Color? rightActionColor;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftActionLabel,
    this.rightActionLabel,
    this.leftActionColor,
    this.rightActionColor,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSwipeLeft() {
    if (widget.onSwipeLeft != null) {
      _controller.forward().then((_) {
        widget.onSwipeLeft!();
        HapticFeedback.mediumImpact();
      });
    }
  }

  void _handleSwipeRight() {
    if (widget.onSwipeRight != null) {
      // Swipe right animation
      widget.onSwipeRight!();
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swipe right
          _handleSwipeRight();
        } else if (details.primaryVelocity! < 0) {
          // Swipe left
          _handleSwipeLeft();
        }
      },
      child: Stack(
        children: [
          // Background actions
          if (widget.onSwipeLeft != null || widget.onSwipeRight != null)
            _buildActionBackground(context),

          // Card content
          SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBackground(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.onSwipeRight != null)
          Container(
            width: 80,
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: widget.rightActionColor ?? Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.white),
                if (widget.rightActionLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.rightActionLabel!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        const Spacer(),
        if (widget.onSwipeLeft != null)
          Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: widget.leftActionColor ?? Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, color: Colors.white),
                if (widget.leftActionLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.leftActionLabel!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
