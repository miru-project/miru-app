import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class PlatformButton extends StatelessWidget {
  const PlatformButton({
    Key? key,
    required this.child,
    this.onPressed,
  }) : super(key: key);
  final Widget child;
  final VoidCallback? onPressed;

  Widget _builaAndroidButton(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: child);
  }

  Widget _builaDesktopButton(BuildContext context) {
    return fluent.Button(onPressed: onPressed, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _builaAndroidButton,
      desktopBuilder: _builaDesktopButton,
    );
  }
}

class PlatformFilledButton extends StatelessWidget {
  const PlatformFilledButton({
    Key? key,
    required this.child,
    this.onPressed,
  }) : super(key: key);
  final Widget child;
  final VoidCallback? onPressed;

  Widget _builaAndroidButton(BuildContext context) {
    return FilledButton(onPressed: onPressed, child: child);
  }

  Widget _builaDesktopButton(BuildContext context) {
    return fluent.FilledButton(onPressed: onPressed, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _builaAndroidButton,
      desktopBuilder: _builaDesktopButton,
    );
  }
}

class PlatformTextButton extends StatelessWidget {
  const PlatformTextButton({
    Key? key,
    required this.child,
    this.onPressed,
  }) : super(key: key);
  final Widget child;
  final VoidCallback? onPressed;

  Widget _builaAndroidButton(BuildContext context) {
    return TextButton(onPressed: onPressed, child: child);
  }

  Widget _builaDesktopButton(BuildContext context) {
    return fluent.HyperlinkButton(onPressed: onPressed, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _builaAndroidButton,
      desktopBuilder: _builaDesktopButton,
    );
  }
}
