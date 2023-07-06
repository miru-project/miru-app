import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

showPlatformSnackbar({
  required BuildContext context,
  required String title,
  required String content,
  dynamic action,
}) {
  if (Platform.isAndroid) {
    return material.ScaffoldMessenger.of(context).showSnackBar(
      material.SnackBar(
        content: Text(title + content),
        action: action,
      ),
    );
  }
  return fluent.displayInfoBar(context, builder: (context, close) {
    return fluent.InfoBar(
      title: Text(title),
      content: Text(content),
      action: action,
    );
  });
}

showPlatformDialog({
  required BuildContext context,
  required String title,
  required Widget? content,
  required List<Widget>? actions,
}) {
  if (Platform.isAndroid) {
    return material.showDialog(
      context: context,
      builder: (context) {
        return material.AlertDialog(
          scrollable: true,
          title: Text(title),
          content: content,
          actions: actions,
        );
      },
    );
  }
  return fluent.showDialog(
    context: context,
    builder: (context) => fluent.ContentDialog(
      title: Text(title),
      content: content,
      actions: actions,
    ),
  );
}
