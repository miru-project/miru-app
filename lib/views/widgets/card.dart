import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class PlatformCard extends StatelessWidget {
  const PlatformCard({
    super.key,
    required this.child,
  });
  final Widget child;

  Widget _buildMobile(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.Card(
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
