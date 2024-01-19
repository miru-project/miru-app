import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  SearchAppBar({
    super.key,
    required this.title,
    required this.textEditingController,
    this.actions,
    this.bottom,
    this.flexibleSpace,
    this.toolbarHeight,
    this.onSubmitted,
    this.onChanged,
    this.hintText,
  }) : preferredSize =
            _PreferredAppBarSize(toolbarHeight, bottom?.preferredSize.height);
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final double? toolbarHeight;
  final TextEditingController textEditingController;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final String? hintText;

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  final Size preferredSize;
}

class _SearchAppBarState extends State<SearchAppBar> {
  late bool _showSearch = widget.textEditingController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: _showSearch
          ? IconButton(
              onPressed: () {
                setState(() {
                  widget.textEditingController.clear();
                  widget.onSubmitted?.call('');
                  _showSearch = false;
                });
              },
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      title: _showSearch
          ? PopScope(
              canPop: false,
              onPopInvoked: (_) async {
                if (_showSearch) {
                  setState(() {
                    widget.textEditingController.clear();
                    widget.onSubmitted?.call('');
                    _showSearch = false;
                  });
                  return;
                }
              },
              child: TextField(
                controller: widget.textEditingController,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? widget.title,
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              ),
            )
          : Text(widget.title),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (_showSearch) {
                widget.textEditingController.clear();
                widget.onSubmitted?.call('');
                return;
              }
              _showSearch = !_showSearch;
            });
          },
          icon: Icon(_showSearch ? Icons.close : Icons.search),
        ),
        ...widget.actions ?? [],
      ],
      bottom: widget.bottom,
      flexibleSpace: widget.flexibleSpace,
    );
  }
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
      : super.fromHeight(
            (toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}
