import 'package:flutter/material.dart';

class DesktopCommandBar extends StatelessWidget {
  const DesktopCommandBar(
      {super.key, required this.text, this.icon, required this.onPressed});
  final Widget text;
  final Widget? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [],
        ));
  }
}
