import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class SettingTile extends StatefulWidget {
  const SettingTile({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    this.buildSubtitle,
    this.onTap,
  }) : super(key: key);
  final Widget icon;
  final String title;
  final String Function()? buildSubtitle;
  final Function()? onTap;
  final Widget? trailing;

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  Widget _buildAndroid(BuildContext context) {
    return ListTile(
      leading: widget.icon,
      title: Text(widget.title),
      subtitle: Text(widget.buildSubtitle?.call() ?? ""),
      trailing: widget.trailing,
      onTap: widget.onTap,
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.Card(
        child: Row(
      children: [
        widget.icon,
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            Text(
              widget.buildSubtitle?.call() ?? "",
              style: const TextStyle(fontSize: 12),
            )
          ],
        ),
        const Spacer(),
        widget.trailing ?? const SizedBox(),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
