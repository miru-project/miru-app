import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/pages/home/widgets/home_resent_card.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class HomeRecent extends StatefulWidget {
  const HomeRecent({
    Key? key,
    required this.data,
  }) : super(key: key);
  final List<History> data;

  @override
  State<HomeRecent> createState() => _HomeRecentState();
}

class _HomeRecentState extends State<HomeRecent> {
  ScrollController horizontalController = ScrollController();

  _horzontalMove(bool left) {
    horizontalController.animateTo(
        horizontalController.offset + (left ? -350 : 350),
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease);
  }

  Widget _buildAndroidHomeRecent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            controller: horizontalController,
            children:
                widget.data.map((e) => HomeRecentCard(history: e)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHomeRecent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "继续观看",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                fluent.IconButton(
                    icon: const Icon(fluent.FluentIcons.chevron_left),
                    onPressed: () {
                      _horzontalMove(true);
                    }),
                const SizedBox(width: 8),
                fluent.IconButton(
                    icon: const Icon(fluent.FluentIcons.chevron_right),
                    onPressed: () {
                      _horzontalMove(false);
                    })
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            controller: horizontalController,
            children:
                widget.data.map((e) => HomeRecentCard(history: e)).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroidHomeRecent,
      desktopBuilder: _buildDesktopHomeRecent,
    );
  }
}
