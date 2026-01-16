import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dark Mode Toggle محسّن مع animation
class DarkModeToggle extends StatefulWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onChanged;

  const DarkModeToggle({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  State<DarkModeToggle> createState() => _DarkModeToggleState();
}

class _DarkModeToggleState extends State<DarkModeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.currentMode == ThemeMode.dark) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    final newMode = widget.currentMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    if (newMode == ThemeMode.dark) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    HapticFeedback.mediumImpact();
    widget.onChanged(newMode);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 64,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: widget.currentMode == ThemeMode.dark
              ? Colors.blue
              : Colors.grey[300],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: widget.currentMode == ThemeMode.dark ? 28 : 4,
              top: 4,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    widget.currentMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    key: ValueKey(widget.currentMode),
                    size: 18,
                    color: widget.currentMode == ThemeMode.dark
                        ? Colors.blue
                        : Colors.amber,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
