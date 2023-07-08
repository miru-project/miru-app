import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/pages/settings/widgets/settings_tile.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class SettingsSwitchTile extends fluent.StatefulWidget {
  const SettingsSwitchTile({
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
  fluent.State<SettingsSwitchTile> createState() => _SettingsSwitchTileState();
}

class _SettingsSwitchTileState extends fluent.State<SettingsSwitchTile> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
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
