import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/pages/detail/view.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:palette_generator/palette_generator.dart';

class HomeRecentCard extends StatefulWidget {
  const HomeRecentCard({
    Key? key,
    required this.history,
  }) : super(key: key);
  final History history;

  @override
  State<HomeRecentCard> createState() => _HomeRecentCardState();
}

class _HomeRecentCardState extends State<HomeRecentCard> {
  late ExtensionRuntime? _runtime;
  String _update = "";

  // 主要颜色
  Color? primaryColor;

  @override
  void initState() {
    _getUpdate();

    if (widget.history.type != ExtensionType.bangumi) {
      _genColor();
    }

    super.initState();
  }

  _getUpdate() async {
    _runtime = ExtensionUtils.runtimes[widget.history.package];
    if (_runtime == null) {
      return;
    }
    _update = await _runtime!.checkUpdate(widget.history.url);
    if (mounted) {
      setState(() {});
    }
  }

  _genColor() async {
    if (widget.history.type == ExtensionType.bangumi) {
      return;
    }
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      CachedNetworkImageProvider(widget.history.cover),
      maximumColorCount: 2,
    );

    primaryColor = paletteGenerator.colors.firstOrNull;

    if (mounted) {
      setState(() {});
    }
  }

  Widget _bangumiCard() {
    return Container(
      width: 350,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.file(
            File(widget.history.cover),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 350,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.history.title,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "看到 ${widget.history.episodeTitle}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_update.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        _update,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverCard() {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        // color:
        //     _paletteGenerator != null ? _paletteGenerator!.colors.first : null,
        image: DecorationImage(
          image: CachedNetworkImageProvider(widget.history.cover),
          fit: BoxFit.cover,
          colorFilter: primaryColor != null
              ? ColorFilter.mode(
                  primaryColor!.withOpacity(0.9),
                  BlendMode.srcOver,
                )
              : null,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: widget.history.cover,
                width: 130,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.history.title,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "看到 ${widget.history.episodeTitle}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  if (_update.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _update,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (Platform.isAndroid) {
              Get.to(
                DetailPage(
                  url: widget.history.url,
                  package: widget.history.package,
                ),
              );
              return;
            }
            router.push(
              Uri(
                path: '/detail',
                queryParameters: {
                  "url": widget.history.url,
                  "package": widget.history.package,
                },
              ).toString(),
            );
          },
          child: widget.history.type == ExtensionType.bangumi
              ? _bangumiCard()
              : _coverCard(),
        ),
      ),
    );
  }
}
