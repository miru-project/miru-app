import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/layout.dart';
import 'package:miru_app/views/pages/search/search_page.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/search_controller.dart';
import 'package:miru_app/views/widgets/grid_item_tile.dart';
import 'package:miru_app/views/widgets/progress.dart';

class AnilistMorePage extends StatefulWidget {
  const AnilistMorePage({super.key, required this.anilistType});
  final AnilistType anilistType;

  @override
  State<AnilistMorePage> createState() => _AnilistMorePageState();
}

class _AnilistMorePageState extends State<AnilistMorePage> {
  late final anilistStatusMap = {
    for (final child in AnilistMediaListStatus.values)
      AniListProvider.mediaListStatusToTranslate(
        child,
        widget.anilistType,
      ): child,
  };

  String currentStatus = "CURRENT";

  dynamic data;

  Future<Map<String, dynamic>> getData() {
    data ??= AniListProvider.getCollection(widget.anilistType);
    return data;
  }

  Widget _buildMobile(BuildContext context) {
    final List<Tab> tabs = [
      for (final child in anilistStatusMap.keys) Tab(text: child),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs,
            indicatorSize: TabBarIndicatorSize.label,
          ),
          title: Text(
            "AniList ${'common.${widget.anilistType.toString().split(".")[1]}'.i18n}",
          ),
        ),
        body: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: ProgressRing(),
                );
              }

              if (data == null) {
                return const Center(
                  child: Text("No data"),
                );
              }

              return TabBarView(
                  children: anilistStatusMap.values.map(((e) {
                final status = AniListProvider.mediaListStatusToQuery(
                  e,
                  firstLetterUpperCase: true,
                );
                final count = data[status]?.length ?? 0;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: LayoutUtils.width ~/ 120,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: count,
                  itemBuilder: (context, index) {
                    final item = data[status][index]["media"];
                    final title = (widget.anilistType == AnilistType.anime)
                        ? item["title"]["userPreferred"]
                        : item["title"]["userPreferred"];
                    final cover = (widget.anilistType == AnilistType.anime)
                        ? item["coverImage"]["large"]
                        : item["coverImage"]["large"];
                    return GridItemTile(
                      onTap: () {
                        if (Platform.isAndroid || Platform.isIOS) {
                          Get.to(() => const SearchPage());
                        } else {
                          router.push("/search");
                        }
                        final c = Get.put(SearchPageController());
                        c.search.value = title;
                      },
                      title: title,
                      cover: cover,
                    );
                  },
                );
              })).toList());
            }),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: ProgressRing(),
          );
        }

        if (data == null) {
          return const Center(
            child: Text("No data"),
          );
        }

        final count = data[currentStatus]?.length ?? 0;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          children: [
            Text(
              "AniList ${'common.${widget.anilistType.toString().split(".")[1]}'.i18n}",
              style: fluent.FluentTheme.of(context).typography.subtitle,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final child in anilistStatusMap.entries) ...[
                  fluent.ToggleButton(
                    checked: currentStatus ==
                        AniListProvider.mediaListStatusToQuery(child.value),
                    onChanged: (value) {
                      setState(() {
                        currentStatus = AniListProvider.mediaListStatusToQuery(
                          child.value,
                        );
                      });
                    },
                    child: Text(child.key),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth ~/ 160,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: count,
                itemBuilder: (context, index) {
                  final item = data[currentStatus][index]["media"];
                  final title = (widget.anilistType == AnilistType.anime)
                      ? item["title"]["userPreferred"]
                      : item["title"]["userPreferred"];
                  final cover = (widget.anilistType == AnilistType.anime)
                      ? item["coverImage"]["large"]
                      : item["coverImage"]["large"];
                  return GridItemTile(
                    onTap: () {
                      if (Platform.isAndroid || Platform.isIOS) {
                        Get.to(() => const SearchPage());
                      } else {
                        router.push("/search");
                      }
                      final c = Get.put(SearchPageController());
                      c.search.value = title;
                    },
                    title: title,
                    cover: cover,
                  );
                },
              );
            }),
          ],
        );
      },
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
