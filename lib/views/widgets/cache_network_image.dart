import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class CacheNetWorkImagePic extends StatelessWidget {
  const CacheNetWorkImagePic(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallback,
    this.headers,
    this.canFullScreen = false,
  });
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;
  final Map<String, String>? headers;
  final bool canFullScreen;

  _errorBuild() {
    if (fallback != null) {
      return fallback!;
    }
    return const Center(child: Icon(fluent.FluentIcons.error));
  }

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      httpHeaders: headers,
      fit: fit,
      width: width,
      height: height,
      errorWidget: (context, url, error) => _errorBuild(),
    );

    if (canFullScreen) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            final thumnailPage = _ThumnailPage(
              image: CachedNetworkImageProvider(
                url,
                headers: headers,
              ),
            );
            if (Platform.isAndroid) {
              Get.to(thumnailPage);
              return;
            }
            fluent.showDialog(
              context: context,
              builder: (_) => thumnailPage,
            );
          },
          child: image,
        ),
      );
    }

    return image;
  }
}

class _ThumnailPage extends StatefulWidget {
  const _ThumnailPage({
    required this.image,
  });
  final ImageProvider<Object> image;

  @override
  State<_ThumnailPage> createState() => _ThumnailPageState();
}

class _ThumnailPageState extends State<_ThumnailPage> {
  Widget _buildContent(BuildContext context) {
    return Center(
      child: ExtendedImageSlidePage(
        slideAxis: SlideAxis.both,
        slideType: SlideType.onlyImage,
        slidePageBackgroundHandler: (offset, pageSize) {
          final color = Platform.isAndroid
              ? Theme.of(context).scaffoldBackgroundColor
              : fluent.FluentTheme.of(context).scaffoldBackgroundColor;
          return color.withOpacity(0);
        },
        child: ExtendedImage(
          image: widget.image,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) {
            return GestureConfig(
              minScale: 0.9,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: true,
              reverseMousePointerScrollDirection: true,
              initialAlignment: InitialAlignment.center,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _buildContent(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Stack(
      children: [
        _buildContent(context),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
        )
      ],
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
