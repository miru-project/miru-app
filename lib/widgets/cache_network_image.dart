import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:miru_app/widgets/progress_ring.dart';
import 'package:path/path.dart' as path;

class CacheNetWorkImage extends StatefulWidget {
  const CacheNetWorkImage(
    this.url, {
    Key? key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallback,
  }) : super(key: key);
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;

  @override
  State<CacheNetWorkImage> createState() => _CacheNetWorkImageState();
}

class _CacheNetWorkImageState extends State<CacheNetWorkImage> {
  bool isloading = true;
  bool isError = false;
  String fileName = '';

  final Dio _dio = Dio();

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    final filePath =
        path.join(await MiruDirectory.getCacheDirectory, 'image_cache');
    Directory(filePath).createSync(recursive: true);
    fileName =
        path.join(filePath, widget.url.replaceAll(RegExp(r'[\\/:*?"<>|]'), ''));
    if (File(fileName).existsSync()) {
      setState(() {
        isloading = false;
      });
      return;
    }
    try {
      await _dio.download(widget.url, fileName);
      isloading = false;
    } catch (e) {
      debugPrint(e.toString());
      isError = true;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  _errorBuild() {
    if (widget.fallback != null) {
      return widget.fallback!;
    }
    return const Center(child: Icon(fluent.FluentIcons.error));
  }

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return _errorBuild();
    }
    if (isloading) {
      return const Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: ProgressRing(),
        ),
      );
    }
    return Image.file(
      File(fileName),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) => _errorBuild(),
    );
  }
}
