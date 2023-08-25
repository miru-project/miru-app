import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/pages/home/pages/favorites_page.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/widgets/extension_item_card.dart';
import 'package:miru_app/widgets/horizontal_list.dart';

class HomeFavorites extends StatefulWidget {
  const HomeFavorites({
    Key? key,
    required this.type,
    required this.data,
  }) : super(key: key);
  final ExtensionType type;
  final List<Favorite> data;

  @override
  State<HomeFavorites> createState() => _HomeFavoritesState();
}

class _HomeFavoritesState extends State<HomeFavorites> {
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      child: HorizontalList(
        title: ExtensionUtils.typeToString(widget.type),
        onClickMore: () {
          if (Platform.isAndroid) {
            Get.to(FavoritesPage(type: widget.type));
          } else {
            router.push(
              Uri(
                path: '/favorites',
                queryParameters: {'type': widget.type.index.toString()},
              ).toString(),
            );
          }
        },
        itemCount: widget.data.length,
        itemBuilder: (context, index) {
          return ExtensionItemCard(
            key: ValueKey(widget.data[index].cover),
            title: widget.data[index].title,
            url: widget.data[index].url,
            package: widget.data[index].package,
            cover: widget.data[index].cover,
          );
        },
      ),
    );
  }
}
