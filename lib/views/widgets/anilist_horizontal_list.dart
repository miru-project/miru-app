import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miru_app/views/pages/search/search_page.dart';
import 'package:miru_app/views/widgets/settings_tile.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/anilist.dart';
import 'package:miru_app/views/widgets/horizontal_list.dart';
import 'package:miru_app/views/widgets/grid_item_tile.dart';
import 'package:get/get.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:miru_app/controllers/search_controller.dart';
import 'package:miru_app/views/pages/anilist_tapmore_page.dart';

class AnilistHorizontalList extends StatefulWidget {
  const AnilistHorizontalList({
    super.key,
    required this.anilistType,
  });
  final AnilistType anilistType;
  @override
  State<AnilistHorizontalList> createState() => _AnilistHorizontalListState();
}

class _AnilistHorizontalListState extends State<AnilistHorizontalList> {
  Map<AnilistType, String> anilistTypeMap = {
    AnilistType.anime: "ANIME",
    AnilistType.manga: "MANGA"
  };
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AniList.getCollection(anilistTypeMap[widget.anilistType]!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            return HorizontalList(
              title: (widget.anilistType == AnilistType.anime)
                  ? "Anime".i18n
                  : "Manga".i18n,
              itemBuilder: (context, index) {
                return GridItemTile(
                  onTap: () {
                    if (Platform.isAndroid) {
                      Get.to(() => const SearchPage());
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SearchPage()));
                    }

                    final c = Get.put(SearchPageController());
                    c.search.value = (widget.anilistType == AnilistType.anime)
                        ? data["Watching"][index]["media"]["title"]
                            ["userPreferred"]
                        : data["Reading"][index]["media"]["title"]
                            ["userPreferred"];
                  },
                  title: (widget.anilistType == AnilistType.anime)
                      ? data!["Watching"][index]["media"]["title"]
                          ["userPreferred"]
                      : data!["Reading"][index]["media"]["title"]
                          ["userPreferred"],
                  cover: (widget.anilistType == AnilistType.anime)
                      ? data["Watching"][index]["media"]["coverImage"]["large"]
                      : data["Reading"][index]["media"]["coverImage"]["large"],
                );
              },
              itemCount: (widget.anilistType == AnilistType.anime)
                  ? snapshot.data!["Watching"].length
                  : snapshot.data!["Reading"].length,
              onClickMore: () {
                debugPrint("click more");
                if (Platform.isAndroid) {
                  Get.to(() => AnilistMorePage(
                      anilistType: AnilistType.anime, data: data!));
                } else {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => AnilistMorePage(
                  //             anilistType: AnilistType.anime, data: data!)));
                  Navigator.push(
                      context,
                      fluent.FluentPageRoute(
                          builder: (context) => AnilistMorePage(
                              anilistType: AnilistType.anime, data: data!)));
                }
              },
            );
          } else if ((snapshot.hasError)) {
            debugPrint("${snapshot.data}");
            debugPrint(" ${snapshot.error}");
            return SettingsTile(
              title: "Error".i18n,
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

enum AnilistType { anime, manga }
