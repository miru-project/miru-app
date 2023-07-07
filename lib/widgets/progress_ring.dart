import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({Key? key, this.value}) : super(key: key);
  final double? value;

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: (context) => CircularProgressIndicator(
        value: value,
      ),
      desktopBuilder: (context) => fluent.ProgressRing(
        value: value,
      ),
    );
  }
}
