import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/pages/search/widgets/search_all_tile_title.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/widgets/bangumi_card.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';

class SearchAllTile extends StatefulWidget {
  const SearchAllTile({
    Key? key,
    required this.runtime,
    required this.onClickMore,
    required this.kw,
  }) : super(key: key);

  final String kw;
  final ExtensionRuntime runtime;
  final Function() onClickMore;

  @override
  State<SearchAllTile> createState() => _SearchAllTileState();
}

class _SearchAllTileState extends State<SearchAllTile> {
  final ScrollController _controller = ScrollController();
  bool hoverTitle = false;

  _horzontalMove(bool left) {
    _controller.animateTo(
      _controller.offset + (left ? -500 : 500),
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              widget.runtime.extension.name,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: widget.onClickMore,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 186,
          child: Center(
              child: FutureBuilder(
            key: ValueKey(widget.kw),
            future: widget.kw.isNotEmpty
                ? widget.runtime.search(widget.kw, 1)
                : widget.runtime.latest(1),
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (!snapshot.hasData) {
                return const ProgressRing();
              }

              final data = snapshot.data;

              if (snapshot.data != null && snapshot.data!.isEmpty) {
                return const Text("无结果");
              }

              return ListView(
                scrollDirection: Axis.horizontal,
                controller: _controller,
                children: [
                  for (var item in data!)
                    Container(
                      width: 128,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: BangumiCard(
                        title: item.title,
                        url: item.url,
                        package: widget.runtime.extension.package,
                        cover: item.cover,
                        update: item.update,
                      ),
                    ),
                ],
              );
            }),
          )),
        ),
        const SizedBox(height: 16)
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SearchAllTileTitle(
              widget.runtime.extension.name,
              onClick: widget.onClickMore,
            ),
            const Spacer(),
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
                  },
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: Center(
              child: FutureBuilder(
            key: ValueKey(widget.kw),
            future: widget.kw.isNotEmpty
                ? widget.runtime.search(widget.kw, 1)
                : widget.runtime.latest(1),
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (!snapshot.hasData) {
                return const ProgressRing();
              }

              final data = snapshot.data;

              if (snapshot.data != null && snapshot.data!.isEmpty) {
                return const Text("无结果");
              }

              return ListView(
                scrollDirection: Axis.horizontal,
                controller: _controller,
                children: [
                  for (var item in data!)
                    Container(
                      width: 170,
                      margin: const EdgeInsets.all(8),
                      child: BangumiCard(
                        title: item.title,
                        url: item.url,
                        package: widget.runtime.extension.package,
                        cover: item.cover,
                        update: item.update,
                      ),
                    ),
                ],
              );
            }),
          )),
        ),
        const SizedBox(height: 16)
      ],
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
