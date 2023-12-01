import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';

class CacheNetWorkImagePic extends StatelessWidget {
  const CacheNetWorkImagePic(
    this.url, {
    Key? key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallback,
    this.headers,
  }) : super(key: key);
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;
  final Map<String, String>? headers;

  _errorBuild() {
    if (fallback != null) {
      return fallback!;
    }
    return const Center(child: Icon(fluent.FluentIcons.error));
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: headers,
      fit: fit,
      width: width,
      height: height,
      errorWidget: (context, url, error) => _errorBuild(),
    );
  }
}

class CacheNetWorkImageComic extends StatelessWidget {
  const CacheNetWorkImageComic(
    this.url, {
    Key? key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallback,
    this.headers,
  }) : super(key: key);
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;
  final Map<String, String>? headers;

  _errorBuild() {
    if (fallback != null) {
      return fallback!;
    }
    return const Center(child: Icon(fluent.FluentIcons.error));
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: headers,
      fit: fit,
      width: width,
      height: height,
      errorWidget: (context, url, error) => _errorBuild(),
    );
  }
}
