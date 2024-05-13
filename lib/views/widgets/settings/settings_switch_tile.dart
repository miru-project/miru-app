import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/settings/settings_tile.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class SettingsSwitchTile extends StatefulWidget {
  const SettingsSwitchTile({
    super.key,
    this.icon,
    required this.title,
    required this.buildValue,
    required this.onChanged,
    this.buildSubtitle,
    this.isCard = false,
  });
  final Widget? icon;
  final String title;
  final String Function()? buildSubtitle;
  final bool Function() buildValue;
  final Function(bool) onChanged;
  final bool isCard;

  @override
  State<SettingsSwitchTile> createState() => _SettingsSwitchTileState();
}

class _SettingsSwitchTileState extends State<SettingsSwitchTile> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      isCard: widget.isCard,
      icon: widget.icon,
      title: widget.title,
      buildSubtitle: widget.buildSubtitle,
      trailing: PlatformWidget(
        mobileWidget: Switch(
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
