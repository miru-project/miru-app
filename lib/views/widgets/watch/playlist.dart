import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayList extends StatefulWidget {
  const PlayList({
    super.key,
    this.scrollController,
    required this.title,
    required this.list,
    required this.selectIndex,
    required this.onChange,
  });
  final String title;
  final List<String> list;
  final int selectIndex;
  final Function(int) onChange;
  final ScrollController? scrollController;
  @override
  State<PlayList> createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  late final list = widget.list;
  late final selectIndex = widget.selectIndex;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController == null) {
        return;
      }
      widget.scrollController!.jumpTo(widget.selectIndex * 60);
    });
    super.initState();
  }

  Widget _buildAndroid(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.background,
      ),
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: ListView.builder(
        itemCount: list.length,
        controller: widget.scrollController,
        itemBuilder: (context, index) {
          final contact = list[index];
          return PlaylistAndroidTile(
            title: contact,
            selected: list[selectIndex] == contact,
            onTap: () {
              widget.onChange(index);
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: fluent.FluentTheme.of(context).micaBackgroundColor,
      child: ScrollablePositionedList.builder(
        itemCount: list.length,
        initialScrollIndex: selectIndex,
        itemBuilder: (context, index) {
          final contact = list[index];
          return fluent.ListTile.selectable(
            title: Text(contact),
            selected: list[selectIndex] == contact,
            onSelectionChange: (value) {
              widget.onChange(index);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}

class PlaylistAndroidTile extends StatelessWidget {
  const PlaylistAndroidTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.selected,
  });
  final String title;
  final Function() onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.background,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
      ),
    );
  }
}
