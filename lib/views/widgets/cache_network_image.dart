import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/data/services/extension_service_api_2.dart';
import 'package:miru_app/models/extension.dart';
import 'dart:ui' as ui;
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/request.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class CacheNetWorkImagePic extends StatelessWidget {
  const CacheNetWorkImagePic(this.url,
      {super.key,
      this.fit = BoxFit.cover,
      this.width,
      this.height,
      this.fallback,
      this.headers,
      this.placeholder,
      this.canFullScreen = false,
      this.mode = ExtendedImageMode.none,
      this.runtime,
      this.imageIndex,
      this.needReconstruct = false});
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;
  final Map<String, String>? headers;
  final bool canFullScreen;
  final Widget? placeholder;
  final ExtendedImageMode mode;
  final int? imageIndex;
  final bool needReconstruct;
  static final _imageCache = <String, Uint8List>{};
  static final List<String> isProcessing = [];
  final ExtensionService? runtime;

  static void clearCache() {
    _imageCache.clear();
  }

  _errorBuild() {
    if (fallback != null) {
      return fallback!;
    }
    return const Center(child: Icon(fluent.FluentIcons.error));
  }

  // Future<Widget> processImage(String url) async {
  //   final completer = Completer<Uint8List>();
  //   final ImageStream stream =
  //       ExtendedNetworkImageProvider(cache: true, url, headers: headers)
  //           .resolve(ImageConfiguration.empty);
  //   final listener = ImageStreamListener((ImageInfo info, bool _) async {
  //     final out = await decodeImage(info);
  //     return completer.complete(out);
  //     // final reconstructList = await (runtime as ExtensionServiceApi2)
  //     //     .recompseImage(info.image.width, info.image.height, imageIndex!);
  //     // // 有線條
  //     // List<Rect> srcRect = [];
  //     // List<Rect> dstRect = [];
  //     // for (int i = 0; i < reconstructList.length; i++) {
  //     //   final element = reconstructList[i];
  //     //   srcRect.add(Rect.fromPoints(Offset(element.sx1, element.sy1),
  //     //       Offset(element.sx2, element.sy2)));
  //     //   dstRect.add(Rect.fromPoints(Offset(element.dx1, element.dy1 - i),
  //     //       Offset(element.dx2, element.dy2 - i)));
  //     //   // logger.info(element);
  //     // }
  //     // logger.info(reconstructList);
  //     // logger.info(info.image.width, info.image.height);
  //     // return completer.complete(Container(
  //     //     decoration: BoxDecoration(
  //     //         border: Border.all(color: Colors.green, width: 2)),
  //     //     width: info.image.width.toDouble(),
  //     //     height: info.image.height.toDouble(),
  //     //     child: CustomPaint(
  //     //       painter: ImagePainter(info.image, srcRect, dstRect),
  //     //     )));
  //   });
  //   stream.addListener(listener);
  //   return completer.future;
  // }

  @override
  Widget build(BuildContext context) {
    late final int imgHeight;
    late final int imgWidth;
    final cacheManager = DefaultCacheManager();
    if (_imageCache.containsKey(url)) {
      final imgData = _imageCache[url];
      return ExtendedImage.memory(imgData!);
    }
    Future<Uint8List?> imageIsolate(String url) async {
      final stream = ExtendedNetworkImageProvider(url, headers: headers)
          .resolve(ImageConfiguration.empty);
      final completer = Completer<Uint8List?>();
      final listener = ImageStreamListener((ImageInfo info, bool _) async {
        final imgRaw =
            await info.image.toByteData(format: ui.ImageByteFormat.png);
        final imgData = imgRaw!.buffer.asUint8List();
        imgHeight = info.image.height;
        imgWidth = info.image.width;

        if (isProcessing.contains(url)) {
          return completer.complete();
        }
        final fromCache = await cacheManager.getFileFromCache(url);
        if (fromCache != null) {
          final imgData = await fromCache.file.readAsBytes();
          _imageCache[url] = imgData;
          return completer.complete(imgData);
        }
        final reconstructList = await (runtime as ExtensionServiceApi2)
            .recompseImage(imgWidth, imgHeight, imageIndex!);

        final List<Map<String, double>> isolateList = [];
        for (int i = 0; i < reconstructList.length; i++) {
          final element = reconstructList[i];
          isolateList.add({
            'sx1': element.sx1,
            'sy1': element.sy1,
            'sx2': element.sx2,
            'sy2': element.sy2,
            'dx1': element.dx1,
            'dy1': element.dy1,
            'dx2': element.dx2,
            'dy2': element.dy2,
          });
        }
        final receivePort = ReceivePort();
        final arg = <String, dynamic>{
          'img': imgData,
          'reconstructList': isolateList,
          'width': imgWidth,
          'height': imgHeight,
          'sendPort': receivePort.sendPort,
        };
        isProcessing.add(url);
        //在isolates中處理圖片，不然ui會卡
        final isolate = await Isolate.spawn((arg) async {
          final List<Map<String, double>> reconstructList =
              arg['reconstructList'];
          final decodeImage = img.decodePng(arg['img'])!;
          final imgWidth = arg['width'];
          final imgHeight = arg['height'];
          final sendPort = arg['sendPort'];

          img.Image newImage = img.Image(width: imgWidth, height: imgHeight);

          for (int i = 0; i < reconstructList.length; i++) {
            final element = ReconstructPicVertex.fromJson(reconstructList[i]);
            final range = decodeImage.getRange(
                element.sx1.toInt(),
                element.sy1.toInt(),
                (element.sx2 - element.sx1).toInt(),
                (element.sy2 - element.sy1).toInt());
            final targetRange = newImage.getRange(
                element.dx1.toInt(),
                element.dy1.toInt(),
                (element.dx2 - element.dx1).toInt(),
                (element.dy2 - element.dy1).toInt());
            while (range.moveNext() && targetRange.moveNext()) {
              targetRange.current.r = range.current.r;
              targetRange.current.g = range.current.g;
              targetRange.current.b = range.current.b;
              targetRange.current.a = range.current.a;
            }
          }
          sendPort.send(img.encodePng(newImage));
        }, arg);
        final Uint8List out = await receivePort.first;
        isolate.kill();
        isProcessing.remove(url);
        _imageCache[url] = out;
        cacheManager.putFile(url, out);
        completer.complete(out);
      });
      stream.addListener(listener);

      return completer.future;
    }

    if (needReconstruct) {
      //image cache for reconstruct image

      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) =>
              FutureBuilder(
                  future: imageIsolate(url),
                  builder: (contex, snapshot) {
                    if ((snapshot.connectionState == ConnectionState.done) &&
                        snapshot.hasData) {
                      // final image = ExtendedMemoryImageProvider(snapshot.data!,
                      //     cacheRawData: true);
                      if (snapshot.data == null) {
                        return SizedBox(
                          width: imgWidth.toDouble(),
                          height: imgHeight.toDouble(),
                          child: const CircularProgressIndicator(),
                        );
                      }
                      final img = FittedBox(
                        fit: fit,
                        child: ExtendedImage.memory(
                          width: imgWidth.toDouble(),
                          height: imgHeight.toDouble(),
                          snapshot.data!,
                          enableMemoryCache: true,
                          imageCacheName: url,
                        ),
                      );
                      return img;
                    }

                    return placeholder ??
                        SizedBox(
                          width: constraint.maxWidth,
                          height: constraint.maxHeight,
                        );
                  }));
    }
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
    if (Platform.isAndroid) {
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

  Widget _buildAndroid(BuildContext context) {
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
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
// 在前端重建圖片(效果不好)
// class ImagePainter extends CustomPainter {
//   final ui.Image image;
//   final List<Rect> srcRects;
//   final List<Rect> dstRects;

//   ImagePainter(this.image, this.srcRects, this.dstRects);

//   @override
//   void paint(Canvas canvas, Size size) {
//     size = Size(image.width.toDouble(), image.height.toDouble());
//     for (int i = 0; i < srcRects.length; i++) {
//       canvas.drawImageRect(
//         image,
//         srcRects[i],
//         dstRects[i],
//         Paint(),
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
