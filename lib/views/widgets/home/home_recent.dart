import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/views/widgets/home/home_resent_card.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class HomeRecent extends StatefulWidget {
  const HomeRecent({
    super.key,
    required this.data,
  });
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

  Widget _buildMobileHomeRecent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: horizontalController,
            itemCount: widget.data.length,
            itemBuilder: (context, index) {
              return HomeRecentCard(history: widget.data[index]);
            },
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
            Text(
              "home.continue-watching".i18n,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: horizontalController,
            itemCount: widget.data.length,
            itemBuilder: (context, index) {
              return HomeRecentCard(history: widget.data[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobileHomeRecent,
      desktopBuilder: _buildDesktopHomeRecent,
    );
  }
}
