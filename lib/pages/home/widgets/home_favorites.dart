import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miru_app/models/favorite.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/extension_item_card.dart';

class HomeFavorites extends StatefulWidget {
  const HomeFavorites({
    Key? key,
    required this.data,
  }) : super(key: key);
  final List<Favorite> data;

  @override
  State<HomeFavorites> createState() => _HomeFavoritesState();
}

class _HomeFavoritesState extends State<HomeFavorites> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "home.favorite".i18n,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // IconButton(
            //     icon: const Icon(FluentIcons.filter),
            //     onPressed: () {
            //       // _filterDialog(context);
            //     })
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount =
                constraints.maxWidth ~/ (Platform.isAndroid ? 120 : 160);
            final childAspectRatio = Platform.isAndroid ? 0.7 : 0.6;
            return GridView.builder(
              // 取消滚动
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
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
            );
          },
        )
      ],
    );
  }
}
