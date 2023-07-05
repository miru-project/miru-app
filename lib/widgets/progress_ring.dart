import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: (context) => const CircularProgressIndicator(),
      desktopBuilder: (context) => const fluent.ProgressRing(),
    );
  }
}
