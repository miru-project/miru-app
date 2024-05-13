import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class PlatformBuildWidget extends StatelessWidget {
  const PlatformBuildWidget({
    super.key,
    required this.mobileBuilder,
    required this.desktopBuilder,
  });

  final WidgetBuilder mobileBuilder;
  final WidgetBuilder desktopBuilder;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return mobileBuilder(context);
    }
    return desktopBuilder(context);
  }
}

class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    super.key,
    required this.mobileWidget,
    required this.desktopWidget,
  });

  final Widget mobileWidget;
  final Widget desktopWidget;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return mobileWidget;
    }
    return desktopWidget;
  }
}
