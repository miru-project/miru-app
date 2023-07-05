import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miru_app/models/favorite.dart';
import 'package:miru_app/widgets/bangumi_card.dart';

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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("收藏",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                constraints.maxWidth ~/ (Platform.isAndroid ? 120 : 170);
            return GridView(
              // 取消滚动
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              children: widget.data
                  .map((e) => BangumiCard(
                        key: ValueKey(e.cover),
                        title: e.title,
                        url: e.url,
                        package: e.package,
                        cover: e.cover,
                      ))
                  .toList(),
            );
          },
        )
      ],
    );
  }
}
