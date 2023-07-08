import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/pages/settings/widgets/settings_tile.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class SettingsIntpuTile extends fluent.StatefulWidget {
  const SettingsIntpuTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onChanged,
    required this.text,
    required this.buildSubtitle,
  }) : super(key: key);
  final Widget icon;
  final String title;
  final String Function() buildSubtitle;
  final String text;
  final Function(String) onChanged;

  @override
  fluent.State<SettingsIntpuTile> createState() => _SettingsIntpuTileState();
}

class _SettingsIntpuTileState extends fluent.State<SettingsIntpuTile> {
  Widget _buildAndroid(BuildContext context) {
    return ListTile(
      leading: widget.icon,
      title: Text(widget.title),
      subtitle: Text(widget.buildSubtitle()),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(widget.title),
              content: TextField(
                controller: TextEditingController(text: widget.text),
                onChanged: (value) {
                  widget.onChanged(value);
                  setState(() {});
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('common.confirm'.i18n),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return SettingsTile(
      icon: widget.icon,
      title: widget.title,
      buildSubtitle: widget.buildSubtitle,
      trailing: Expanded(
          child: fluent.TextBox(
        controller: TextEditingController(text: widget.text),
        onChanged: (value) {
          widget.onChanged(value);
        },
      )),
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
