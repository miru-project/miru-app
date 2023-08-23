import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/pages/detail/view.dart';
import 'package:miru_app/pages/home/controller.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/platform_widget.dart';
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
  final contextController = fluent.FlyoutController();
  final contextAttachKey = GlobalKey();
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

  _delete() async {
    await DatabaseUtils.deleteHistoryByPackageAndUrl(
      widget.history.package,
      widget.history.url,
    );
    Get.find<HomePageController>().refreshHistory();
  }

  _delectAll() async {
    await DatabaseUtils.deleteAllHistory();
    Get.find<HomePageController>().refreshHistory();
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
                            FlutterI18n.translate(
                              context,
                              "home.watched",
                              translationParams: {
                                "ep": widget.history.episodeTitle,
                              },
                            ),
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
                    FlutterI18n.translate(
                      context,
                      "home.watched",
                      translationParams: {
                        "ep": widget.history.episodeTitle,
                      },
                    ),
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

  Widget _buildWidget() {
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

  Widget _buildAndroid(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('common.delete'.i18n),
                  onTap: () {
                    _delete();
                    Get.back();
                  },
                ),
                ListTile(
                  title: Text('common.delete-all'.i18n),
                  onTap: () {
                    _delectAll();
                    Get.back();
                  },
                ),
              ],
            );
          },
        );
      },
      child: _buildWidget(),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (d) {
        final targetContext = contextAttachKey.currentContext;
        if (targetContext == null) return;
        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          d.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );
        contextController.showFlyout(
          barrierColor: Colors.black.withOpacity(0.1),
          position: position,
          builder: (context) {
            return fluent.FlyoutContent(
              child: SizedBox(
                width: 200,
                child: fluent.CommandBar(
                  primaryItems: [
                    fluent.CommandBarButton(
                      label: Text('common.delete'.i18n),
                      onPressed: () {
                        _delete();
                        router.pop();
                      },
                    ),
                    fluent.CommandBarButton(
                      label: Text('common.delete-all'.i18n),
                      onPressed: () {
                        _delectAll();
                        router.pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: fluent.FlyoutTarget(
        key: contextAttachKey,
        controller: contextController,
        child: _buildWidget(),
      ),
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
