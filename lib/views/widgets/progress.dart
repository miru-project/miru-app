import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, this.value});
  final double? value;

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: (context) => CircularProgressIndicator(
        value: value,
      ),
      desktopBuilder: (context) => fluent.ProgressRing(
        value: value,
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, this.value});
  final double? value;

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: (context) => LinearProgressIndicator(
        value: value,
      ),
      desktopBuilder: (context) => fluent.ProgressBar(
        value: value != null ? value! * 100 : null,
      ),
    );
  }
}
