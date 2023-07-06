import 'package:flutter/material.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class ListTitle extends StatelessWidget {
  const ListTitle({Key? key, required this.title}) : super(key: key);

  final String title;

  Widget _buildAndroid(BuildContext context) {
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
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
