import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/settings/settings_tile.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class SettingsSliderTile extends StatefulWidget {
  const SettingsSliderTile({
    super.key,
    this.icon,
    required this.title,
    required this.buildValue,
    required this.onChanged,
    this.buildSubtitle,
    this.isCard = false,
    this.max = 100,
    this.min = 0,
    this.division,
    this.label,
    this.frontWidget,
  });
  final Widget? icon;
  final List<Widget>? frontWidget;
  final String title;
  final String? label;
  final double max;
  final double min;
  final int? division;
  final String Function()? buildSubtitle;
  final double Function() buildValue;
  final Function(double) onChanged;
  final bool isCard;

  @override
  State<SettingsSliderTile> createState() => _SettingsSliderTileState();
}

class _SettingsSliderTileState extends State<SettingsSliderTile> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      isCard: widget.isCard,
      icon: widget.icon,
      title: widget.title,
      buildSubtitle: widget.buildSubtitle,
      trailing: PlatformWidget(
        androidWidget: Slider(
          max: widget.max,
          min: widget.min,
          value: widget.buildValue(),
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {});
          },
        ),
        desktopWidget: Row(children: [
          if (widget.frontWidget != null) ...widget.frontWidget!,
          fluent.Slider(
            label: widget.label,
            divisions: widget.division,
            max: widget.max,
            min: widget.min,
            value: widget.buildValue(),
            onChanged: (value) {
              widget.onChanged(value);
              setState(() {});
            },
          )
        ]),
      ),
    );
  }
}
