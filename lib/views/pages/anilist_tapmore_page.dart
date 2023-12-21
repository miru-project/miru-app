import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/anilist_horizontal_list.dart';
import 'package:miru_app/views/pages/search/search_page.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/search_controller.dart';
import 'package:miru_app/views/widgets/grid_item_tile.dart';

class AnilistMorePage extends fluent.StatefulWidget {
  const AnilistMorePage(
      {super.key, required this.anilistType, required this.data});
  final AnilistType anilistType;
  final Map<String, dynamic> data;

  @override
  fluent.State<AnilistMorePage> createState() => _AnilistMorePageState();
}

class _AnilistMorePageState extends fluent.State<AnilistMorePage> {
  Widget _buildAndroid(BuildContext context) {
    final List<Tab> tabs = [
      if (widget.anilistType == AnilistType.manga)
        const Tab(text: "Reading")
      else
        const Tab(text: "Watching"),
      const Tab(text: "Completed"),
      const Tab(text: "Planning"),
    ];
    final data = widget.data;
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
                bottom: TabBar(
                  tabs: tabs,
                ),
                title: const Text(
                  "",
                )),
            body: TabBarView(
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Expanded(
              //   flex: 2,
              //   // child: Text(
              //   //   "${ExtensionUtils.typeToString(widget.type)}${"home.favorite".i18n}",
              //   //   style: fluent.FluentTheme.of(context).typography.subtitle,
              //   // ),
              // ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          // Expanded(
          //   child: FutureBuilder(
          //     future: DatabaseService.getFavoritesByType(type: widget.type),
          //     builder: ((context, snapshot) {
          //       if (snapshot.hasError) {
          //         return Center(
          //           child: Text(
          //             snapshot.error.toString(),
          //           ),
          //         );
          //       }

          //       if (!snapshot.hasData) {
          //         return const Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       }

          //       final data = snapshot.data;

          //       if (data == null) {
          //         return const Center(
          //           child: Text('No data'),
          //         );
          //       }

          //       return LayoutBuilder(
          //         builder: ((context, constraints) => GridView.builder(
          //               padding:
          //                   const EdgeInsets.only(right: 8, bottom: 8, top: 8),
          //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //                 crossAxisCount: constraints.maxWidth ~/ 160,
          //                 childAspectRatio: 0.6,
          //                 crossAxisSpacing: 16,
          //                 mainAxisSpacing: 16,
          //               ),
          //               itemCount: data.length,
          //               itemBuilder: (context, index) {
          //                 final item = data[index];
          //                 return ExtensionItemCard(
          //                   title: item.title,
          //                   url: item.url,
          //                   package: item.package,
          //                   cover: item.cover,
          //                 );
          //               },
          //             )),
          //       );
          //     }),
          //   ),
          // )
        ],
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
