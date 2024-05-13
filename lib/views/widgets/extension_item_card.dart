import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/views/pages/detail_page.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/views/widgets/grid_item_tile.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class ExtensionItemCard extends StatefulWidget {
  const ExtensionItemCard({
    super.key,
    required this.title,
    required this.url,
    required this.package,
    this.cover,
    this.update,
    this.headers,
  });
  final String title;
  final String? cover;
  final String? update;
  final String url;
  final String package;
  final Map<String, String>? headers;

  @override
  State<ExtensionItemCard> createState() => _ExtensionItemCardState();
}

class _ExtensionItemCardState extends State<ExtensionItemCard> {
  Widget _buildMobile(BuildContext context) {
    return Hero(
      tag: widget.url,
      child: GridItemTile(
        title: widget.title,
        cover: widget.cover,
        subtitle: widget.update,
        headers: widget.headers,
        onTap: () {
          Get.to(DetailPage(
            url: widget.url,
            package: widget.package,
            tag: widget.url,
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
      headers: widget.headers,
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
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
