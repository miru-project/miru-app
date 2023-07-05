import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class PlayList extends StatelessWidget {
  const PlayList({
    Key? key,
    required this.title,
    required this.list,
    required this.selectIndex,
    required this.onChange,
  }) : super(key: key);
  final String title;
  final List<String> list;
  final int selectIndex;
  final Function(int) onChange;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
        androidWidget: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final contact = list[index];
            return ListTile(
              title: Text(contact),
              selected: list[selectIndex] == contact,
              onTap: () {
                onChange(index);
              },
            );
          },
        ),
        desktopWidget: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final contact = list[index];
            return fluent.ListTile.selectable(
              title: Text(contact),
              selected: list[selectIndex] == contact,
              onSelectionChange: (value) {
                onChange(index);
              },
            );
          },
        ));
  }
}
