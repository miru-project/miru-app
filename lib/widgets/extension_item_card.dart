import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/detail/view.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/widgets/grid_item_tile.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class ExtensionItemCard extends StatefulWidget {
  const ExtensionItemCard({
    Key? key,
    required this.title,
    required this.url,
    required this.package,
    required this.cover,
    this.update,
  }) : super(key: key);
  final String title;
  final String cover;
  final String? update;
  final String url;
  final String package;

  @override
  State<ExtensionItemCard> createState() => _ExtensionItemCardState();
}

class _ExtensionItemCardState extends State<ExtensionItemCard> {
  Widget _buildAndroid(BuildContext context) {
    return Hero(
      tag: widget.url,
      child: GridItemTile(
        title: widget.title,
        cover: widget.cover,
        subtitle: widget.update,
        onTap: () {
          Get.to(DetailPage(
            url: widget.url,
            package: widget.package,
            heroTag: widget.url,
          ));
        },
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return GridItemTile(
      title: widget.title,
      cover: widget.cover,
      subtitle: widget.update,
      onTap: () {
        router.push(
          Uri(
            path: '/detail',
            queryParameters: {
              "url": widget.url,
              "package": widget.package,
            },
          ).toString(),
        );
      },
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
