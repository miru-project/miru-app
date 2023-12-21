import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class SettingsTile extends StatefulWidget {
  const SettingsTile({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
    this.buildSubtitle,
    this.onTap,
  });
  final Widget? icon;
  final String title;
  final String Function()? buildSubtitle;
  final Function()? onTap;
  final Widget? trailing;

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
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
        padding: const EdgeInsets.all(2),
        child: fluent.ListTile(
          leading: widget.icon,
          title: Text(widget.title),
          subtitle: Text(widget.buildSubtitle?.call() ?? ""),
          trailing: widget.trailing,
          onPressed: widget.onTap,
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
