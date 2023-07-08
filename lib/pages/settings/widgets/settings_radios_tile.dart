import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/pages/settings/widgets/settings_tile.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class SettingsRadiosTile<T> extends fluent.StatefulWidget {
  const SettingsRadiosTile({
    Key? key,
    required this.icon,
    required this.title,
    this.buildSubtitle,
    required this.itemNameValue,
    required this.applyValue,
    required this.buildGroupValue,
  }) : super(key: key);
  final Widget icon;
  final String title;
  final String Function()? buildSubtitle;
  final Function(T value) applyValue;
  final Map<String, T> itemNameValue;
  final T Function() buildGroupValue;

  @override
  fluent.State<SettingsRadiosTile<T>> createState() =>
      _SettingsRadiosTileState<T>();
}

class _SettingsRadiosTileState<T> extends fluent.State<SettingsRadiosTile<T>> {
  Widget _buildAndroid(BuildContext context) {
    return SettingsTile(
      icon: widget.icon,
      title: widget.title,
      buildSubtitle: widget.buildSubtitle,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(widget.title),
            scrollable: true,
            content: Column(
              children: [
                for (final item in widget.itemNameValue.entries)
                  RadioListTile<T>(
                    title: Text(item.key),
                    value: item.value,
                    groupValue: widget.buildGroupValue(),
                    onChanged: (value) {
                      Navigator.pop(context);
                      widget.applyValue(value as T);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return SettingsTile(
      icon: widget.icon,
      title: widget.title,
      buildSubtitle: widget.buildSubtitle,
      trailing: fluent.ComboBox<T>(
        items: [
          for (final item in widget.itemNameValue.entries)
            fluent.ComboBoxItem<T>(
              value: item.value,
              child: Text(item.key),
            )
        ],
        value: widget.buildGroupValue(),
        onChanged: (value) {
          widget.applyValue(value as T);
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
