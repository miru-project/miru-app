import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class PlatformBuildWidget extends StatelessWidget {
  const PlatformBuildWidget({
    super.key,
    required this.androidBuilder,
    required this.desktopBuilder,
  });

  final WidgetBuilder androidBuilder;
  final WidgetBuilder desktopBuilder;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return androidBuilder(context);
    }
    return desktopBuilder(context);
  }
}

class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    super.key,
    required this.androidWidget,
    required this.desktopWidget,
  });

  final Widget androidWidget;
  final Widget desktopWidget;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return androidWidget;
    }
    return desktopWidget;
  }
}
