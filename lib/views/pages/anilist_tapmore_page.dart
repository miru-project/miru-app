import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/anilist_horizontal_list.dart';
import 'package:miru_app/views/pages/search/search_page.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/search_controller.dart';
import 'package:miru_app/views/widgets/grid_item_tile.dart';

class AnilistMorePage extends StatefulWidget {
  const AnilistMorePage(
      {super.key, required this.anilistType, required this.data});
  final AnilistType anilistType;
  final Map<String, dynamic> data;

  @override
  State<AnilistMorePage> createState() => _AnilistMorePageState();
}

class _AnilistMorePageState extends State<AnilistMorePage> {
  Widget _buildAndroid(BuildContext context) {
    final List<Tab> tabs = [
      if (widget.anilistType == AnilistType.manga)
        const Tab(text: "Reading")
      else
        const Tab(text: "Watching"),
      const Tab(text: "Completed"),
      const Tab(text: "Planning"),
      const Tab(text: "Dropped"),
      const Tab(text: "Paused"),
      const Tab(text: "Rewatching"),
    ];
    final data = widget.data;
    return DefaultTabController(
        length: 6,
        child: Scaffold(
            appBar: AppBar(
                bottom: TabBar(
                  isScrollable: true,
                  tabs: tabs,
                ),
                title: const Text(
                  "",
                )),
            body: TabBarView(
                clipBehavior: Clip.none,
                children: tabs.map((Tab tab) {
                  final status = tab.text;
                  if (data[status] == null) {
                    return Center(
                      child: Text("Not found".i18n),
                    );
                  }
                  return LayoutBuilder(
                      builder: (context, constraints) => GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: constraints.maxWidth ~/ 120,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: (widget.anilistType == AnilistType.anime)
                                ? data[status].length
                                : data[status].length,
                            itemBuilder: (context, index) {
                              return GridItemTile(
                                onTap: () {
                                  Get.to(() => const SearchPage());
                                  final c = Get.put(SearchPageController());
                                  c.search.value =
                                      (widget.anilistType == AnilistType.anime)
                                          ? data[status][index]["media"]
                                              ["title"]["userPreferred"]
                                          : data[status][index]["media"]
                                              ["title"]["userPreferred"];
                                },
                                title: (widget.anilistType == AnilistType.anime)
                                    ? data[status][index]["media"]["title"]
                                        ["userPreferred"]
                                    : data[status][index]["media"]["title"]
                                        ["userPreferred"],
                                cover: (widget.anilistType == AnilistType.anime)
                                    ? data[status][index]["media"]["coverImage"]
                                        ["large"]
                                    : data[status][index]["media"]["coverImage"]
                                        ["large"],
                              );
                            },
                          ));
                }).toList())));
  }

  Widget _buildDesktop(BuildContext context) {
    final data = widget.data;
    final index = 0.obs;

    return Obx(
      () => (fluent.TabView(
          closeButtonVisibility: fluent.CloseButtonVisibilityMode.never,
          currentIndex: index.value,
          showScrollButtons: true,
          tabWidthBehavior: fluent.TabWidthBehavior.equal,
          onChanged: (ind) {
            index.value = ind;
          },
          tabs: [
            // if (widget.anilistType == AnilistType.manga)
            // fluent.Tab(text: fluent.Text("Reading"), body: Container())
            //   _desktopTab(context, data, "Reading")
            // else
            _desktopTab(context, data, "Watching"),
            _desktopTab(context, data, "Completed"),
            _desktopTab(context, data, "Planning"),
            _desktopTab(context, data, "Dropped"),
            _desktopTab(context, data, "Paused"),
            _desktopTab(context, data, "Rewatching"),
          ])),
    );
  }

  fluent.Tab _desktopTab(BuildContext context, data, String status) {
    if (data[status] == null) {
      return fluent.Tab(
          text: fluent.Text(status),
          body: Center(
            child: Text("Not found".i18n),
          ));
    }
    return fluent.Tab(
        text: fluent.Text(status),
        body: fluent.LayoutBuilder(
            builder: (context, constraints) => GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth ~/ 160,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: (widget.anilistType == AnilistType.anime)
                      ? data[status].length
                      : data[status].length,
                  itemBuilder: (context, index) {
                    return GridItemTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            fluent.FluentPageRoute(
                                builder: (context) => const SearchPage()));
                        final c = Get.put(SearchPageController());
                        c.search.value =
                            (widget.anilistType == AnilistType.anime)
                                ? data[status][index]["media"]["title"]
                                    ["userPreferred"]
                                : data[status][index]["media"]["title"]
                                    ["userPreferred"];
                      },
                      title: (widget.anilistType == AnilistType.anime)
                          ? data[status][index]["media"]["title"]
                              ["userPreferred"]
                          : data[status][index]["media"]["title"]
                              ["userPreferred"],
                      cover: (widget.anilistType == AnilistType.anime)
                          ? data[status][index]["media"]["coverImage"]["large"]
                          : data[status][index]["media"]["coverImage"]["large"],
                    );
                  },
                )));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
