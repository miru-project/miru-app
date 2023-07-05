import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/pages/settings/widgets/setting_tile.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class SettingSwitchTile extends fluent.StatefulWidget {
  const SettingSwitchTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.buildValue,
    required this.onChanged,
    this.buildSubtitle,
  }) : super(key: key);
  final Widget icon;
  final String title;
  final String Function()? buildSubtitle;
  final bool Function() buildValue;
  final Function(bool) onChanged;

  @override
  fluent.State<SettingSwitchTile> createState() => _SettingSwitchTileState();
}

class _SettingSwitchTileState extends fluent.State<SettingSwitchTile> {
  @override
  Widget build(BuildContext context) {
    return SettingTile(
      icon: widget.icon,
      title: widget.title,
      buildSubtitle: widget.buildSubtitle,
      trailing: PlatformWidget(
        androidWidget: Switch(
          value: widget.buildValue(),
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {});
          },
        ),
        desktopWidget: fluent.ToggleSwitch(
          checked: widget.buildValue(),
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {});
          },
        ),
      ),
    );
  }
}
