import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Search Bar محسّن مع debounce وanimations
class EnhancedSearchBar extends StatefulWidget {
  final String? hintText;
  final Function(String)? onSearch;
  final Function()? onClear;
  final bool showFilters;
  final List<String>? filterOptions;
  final String? selectedFilter;

  const EnhancedSearchBar({
    super.key,
    this.hintText,
    this.onSearch,
    this.onClear,
    this.showFilters = false,
    this.filterOptions,
    this.selectedFilter,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }

    // Debounce search
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch?.call(_controller.text);
    });
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    widget.onClear?.call();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? Theme.of(context).colorScheme.primary
                  : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'بحث...',
              prefixIcon: Icon(
                Icons.search,
                color: _isFocused
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              suffixIcon: _hasText
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 20),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onSubmitted: (value) {
              widget.onSearch?.call(value);
              _focusNode.unfocus();
            },
          ),
        ),

        // Filter Chips
        if (widget.showFilters && widget.filterOptions != null) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.filterOptions!.map((filter) {
                final isSelected = filter == widget.selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      // Handle filter selection
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
