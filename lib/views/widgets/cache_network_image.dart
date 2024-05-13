import 'dart:io';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/request.dart';
import 'package:miru_app/views/widgets/messenger.dart';
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
    this.placeholder,
    this.canFullScreen = false,
    this.mode = ExtendedImageMode.none,
  });
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;
  final Map<String, String>? headers;
  final bool canFullScreen;
  final Widget? placeholder;
  final ExtendedImageMode mode;

  _errorBuild() {
    if (fallback != null) {
      return fallback!;
    }
    return const Center(child: Icon(fluent.FluentIcons.error));
  }

  @override
  Widget build(BuildContext context) {
    final image = ExtendedImage.network(
      url,
      headers: headers,
      fit: fit,
      width: width,
      height: height,
      cache: true,
      mode: mode,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return placeholder ?? const SizedBox();
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return _errorBuild();
        }
      },
    );

    if (canFullScreen) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            final thumnailPage = _ThumnailPage(
              url: url,
              headers: headers,
            );
            if (Platform.isAndroid || Platform.isIOS) {
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
    required this.url,
    required this.headers,
  });
  final String url;
  final Map<String, String>? headers;

  @override
  State<_ThumnailPage> createState() => _ThumnailPageState();
}

class _ThumnailPageState extends State<_ThumnailPage> {
  final menuController = fluent.FlyoutController();
  final contextAttachKey = GlobalKey();

  @override
  dispose() {
    menuController.dispose();
    super.dispose();
  }

  _saveImage() async {
    final url = widget.url;
    final fileName = url.split('/').last;
    final res = await dio.get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: widget.headers,
      ),
    );
    if (Platform.isAndroid || Platform.isIOS) {
      final result = await ImageGallerySaver.saveImage(
        res.data,
        name: fileName,
      );
      if (mounted) {
        final msg = result['isSuccess'] == true
            ? 'common.save-success'.i18n
            : result['errorMessage'];
        showPlatformSnackbar(
          context: context,
          content: msg,
        );
      }
      return;
    }
    // 打开目录选择对话框file_picker

    final path = await FilePicker.platform.saveFile(
      type: FileType.image,
      fileName: fileName,
    );
    if (path == null) {
      return;
    }
    // 保存
    File(path).writeAsBytesSync(res.data);
  }

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
        child: ExtendedImage.network(
          widget.url,
          headers: widget.headers,
          cache: true,
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

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        child: _buildContent(context),
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            useSafeArea: true,
            builder: (_) => SizedBox(
              height: 100,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.save),
                    title: Text('common.save'.i18n),
                    onTap: () {
                      Navigator.of(context).pop();
                      _saveImage();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (d) {
        final targetContext = contextAttachKey.currentContext;
        if (targetContext == null) return;
        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          d.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );
        menuController.showFlyout(
          position: position,
          builder: (context) {
            return fluent.MenuFlyout(items: [
              fluent.MenuFlyoutItem(
                leading: const Icon(fluent.FluentIcons.save),
                text: Text('common.save'.i18n),
                onPressed: () {
                  fluent.Flyout.of(context).close();
                  _saveImage();
                },
              ),
            ]);
          },
        );
      },
      child: fluent.FlyoutTarget(
        key: contextAttachKey,
        controller: menuController,
        child: _buildContent(context),
      ),
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
