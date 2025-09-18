import 'package:flutter/material.dart';

class RepoSearchBar extends StatefulWidget {
  final String initialQuery;
  final Function(String) onSearchChanged;
  final Function()? onClearSearch;

  const RepoSearchBar({
    super.key,
    this.initialQuery = '',
    required this.onSearchChanged,
    this.onClearSearch,
  });

  @override
  State<RepoSearchBar> createState() => _RepoSearchBarState();
}

class _RepoSearchBarState extends State<RepoSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search repositories...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          suffixIcon:
              _controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    onPressed: _clearSearch,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {});
          widget.onSearchChanged(value);
        },
        onSubmitted: (value) {
          _focusNode.unfocus();
        },
      ),
    );
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {});
    widget.onSearchChanged('');
    widget.onClearSearch?.call();
    _focusNode.unfocus();
  }
}
