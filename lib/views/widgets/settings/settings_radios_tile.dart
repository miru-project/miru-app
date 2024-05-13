import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/settings/settings_tile.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class SettingsRadiosTile<T> extends StatefulWidget {
  const SettingsRadiosTile({
    super.key,
    this.icon,
    required this.title,
    this.buildSubtitle,
    required this.itemNameValue,
    required this.applyValue,
    required this.buildGroupValue,
    this.trailing = const Icon(Icons.chevron_right),
    this.isCard = false,
  });
  final Widget? icon;
  final String title;
  final String Function()? buildSubtitle;
  final Function(T value) applyValue;
  final Map<String, T> itemNameValue;
  final T Function() buildGroupValue;
  final Widget trailing;
  final bool isCard;

  @override
  State<SettingsRadiosTile<T>> createState() => _SettingsRadiosTileState<T>();
}

class _SettingsRadiosTileState<T> extends State<SettingsRadiosTile<T>> {
  Widget _buildMobile(BuildContext context) {
    return SettingsTile(
      isCard: widget.isCard,
      icon: widget.icon,
      title: widget.title,
      buildSubtitle: widget.buildSubtitle,
      trailing: widget.trailing,
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
                      setState(() {});
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
      isCard: widget.isCard,
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
          setState(() {});
        },
      ),
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
