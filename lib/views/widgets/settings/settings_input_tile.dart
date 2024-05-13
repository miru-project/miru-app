import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/settings/settings_tile.dart';

class SettingsIntpuTile extends fluent.StatefulWidget {
  const SettingsIntpuTile({
    super.key,
    this.icon,
    required this.title,
    required this.onChanged,
    required this.buildText,
    required this.buildSubtitle,
    this.trailing = const Icon(Icons.chevron_right),
    this.isCard = false,
  });
  final Widget? icon;
  final String title;
  final String Function() buildSubtitle;
  final String Function() buildText;
  final Widget trailing;
  final Function(String) onChanged;
  final bool isCard;

  @override
  fluent.State<SettingsIntpuTile> createState() => _SettingsIntpuTileState();
}

class _SettingsIntpuTileState extends fluent.State<SettingsIntpuTile> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.buildText());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildMobile(BuildContext context) {
    return ListTile(
      leading: widget.icon,
      title: Text(widget.title),
      subtitle: Text(widget.buildSubtitle()),
      trailing: widget.trailing,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(widget.title),
              content: TextField(
                controller: _controller,
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
      isCard: widget.isCard,
      icon: widget.icon,
      title: widget.title,
      buildSubtitle: widget.buildSubtitle,
      trailing: Expanded(
          child: fluent.TextBox(
        controller: _controller,
        onChanged: (value) {
          widget.onChanged(value);
        },
      )),
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
