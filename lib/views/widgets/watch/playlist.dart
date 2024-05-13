import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayList extends fluent.StatelessWidget {
  const PlayList({
    super.key,
    required this.title,
    required this.list,
    required this.selectIndex,
    required this.onChange,
  });
  final String title;
  final List<String> list;
  final int selectIndex;
  final Function(int) onChange;

  Widget _buildMobile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.background,
      child: ScrollablePositionedList.builder(
        itemCount: list.length,
        initialScrollIndex: selectIndex,
        itemBuilder: (context, index) {
          final contact = list[index];
          return PlaylistAndroidTile(
            title: contact,
            selected: list[selectIndex] == contact,
            onTap: () {
              onChange(index);
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: list.length,
      initialScrollIndex: selectIndex,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final contact = list[index];
        return fluent.ListTile.selectable(
          title: Text(contact),
          onPressed: () {
            onChange(index);
          },
          selected: list[selectIndex] == contact,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
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
