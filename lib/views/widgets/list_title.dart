import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class ListTitle extends StatelessWidget {
  const ListTitle({super.key, required this.title});

  final String title;

  Widget _buildMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold),
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
