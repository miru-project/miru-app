import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miru_app/views/pages/search/search_page.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
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
    required this.data,
  });
  final AnilistType anilistType;
  final Map<dynamic, dynamic> data;

  @override
  State<AnilistHorizontalList> createState() => _AnilistHorizontalListState();
}

class _AnilistHorizontalListState extends State<AnilistHorizontalList> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final count = ((widget.anilistType == AnilistType.anime)
            ? data["Watching"]?.length
            : data["Reading"]?.length) ??
        0;

    return HorizontalList(
      title: (widget.anilistType == AnilistType.anime)
          ? "Anime".i18n
          : "Manga".i18n,
      itemBuilder: (context, index) {
        final itemData = (widget.anilistType == AnilistType.anime)
            ? data["Watching"][index]
            : data["Reading"][index];

        final title = itemData["media"]["title"]["userPreferred"];
        final cover = itemData["media"]["coverImage"]["large"];

        return GridItemTile(
          onTap: () {
            if (Platform.isAndroid) {
              Get.to(() => const SearchPage());
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            }
            final c = Get.put(SearchPageController());
            c.search.value = title;
          },
          title: title,
          cover: cover,
        );
      },
      itemCount: count,
      onClickMore: () {
        if (Platform.isAndroid) {
          Get.to(
            () => AnilistMorePage(
              anilistType: AnilistType.anime,
              data: data,
            ),
          );
        } else {
          Navigator.push(
            context,
            fluent.FluentPageRoute(
              builder: (context) => AnilistMorePage(
                anilistType: AnilistType.anime,
                data: data,
              ),
            ),
          );
        }
      },
    );
  }
}
