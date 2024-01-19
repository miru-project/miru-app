import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
// import 'package:miru_app/views/widgets/platform_widget.dart';

class SettingNumboxButton extends fluent.StatefulWidget {
  const SettingNumboxButton({
    super.key,
    this.icon,
    required this.title,
    required this.onChanged,
    required this.button1text,
    required this.button2text,
    required this.numberBoxvalue,
  });
  final Widget? icon;
  final String title;
  final String button1text;
  final String button2text;
  final void Function(double?)? onChanged;
  final double numberBoxvalue;
  @override
  fluent.State<SettingNumboxButton> createState() => _SettingsIntpuTileState();
}

class _SettingsIntpuTileState extends fluent.State<SettingNumboxButton> {
  bool buttonSwitch = false;
  Widget _buildDesktop(BuildContext context) {
    return fluent.Tooltip(
        message: widget.title,
        child: fluent.Card(
            child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 24,
              child: widget.icon ?? Text(widget.title),
            ),
            Expanded(
                child: SizedBox(
              child: fluent.NumberBox(
                value: widget.numberBoxvalue,
                onChanged: widget.onChanged,
                smallChange: buttonSwitch ? 0.1 : 1.0,
                mode: fluent.SpinButtonPlacementMode.inline,
              ),
            )),
            const SizedBox(width: 8),
            if (!buttonSwitch)
              fluent.Button(
                child: Text(widget.button1text),
                onPressed: () {
                  setState(() {
                    buttonSwitch = true;
                  });
                },
              )
            else
              fluent.FilledButton(
                child: Text(widget.button2text),
                onPressed: () {
                  setState(() {
                    buttonSwitch = false;
                  });
                },
              )
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return _buildDesktop(context);
  }
}
