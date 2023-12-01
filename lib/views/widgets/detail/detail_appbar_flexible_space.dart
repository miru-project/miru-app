import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:miru_app/views/widgets/detail/detail_continue_play.dart';
import 'package:miru_app/views/widgets/detail/detail_extension_tile.dart';
import 'package:miru_app/views/widgets/detail/detail_favorite_button.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/cover.dart';

class DetailAppbarflexibleSpace extends StatefulWidget {
  const DetailAppbarflexibleSpace({
    Key? key,
    this.tag,
  }) : super(key: key);

  final String? tag;

  @override
  State<DetailAppbarflexibleSpace> createState() =>
      _DetailAppbarflexibleSpaceState();
}

class _DetailAppbarflexibleSpaceState extends State<DetailAppbarflexibleSpace> {
  late DetailPageController c = Get.find(tag: widget.tag);

  double _offset = 1;

  @override
  void initState() {
    c.scrollController.addListener(() {
      setState(() {
        _offset = c.scrollController.offset;
      });
    });
    super.initState();
  }

  double _scrollListener() {
    if (_offset <= 0) {
      return 1;
    } else if (_offset >= 300) {
      return 0;
    } else {
      return (_offset - 300) / (0 - 300);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool needShowCover() {
      if (c.isLoading.value) {
        return true;
      }
      if (c.data.value?.cover != null) {
        return true;
      }
      return false;
    }

    return Obx(
      () => Opacity(
        opacity: _scrollListener(),
        child: Stack(
          children: [
            SizedBox(
              height: 400,
              width: double.infinity,
              child: c.isLoading.value
                  ? const SizedBox.shrink()
                  : Cover(
                      alt: c.data.value?.title ?? '',
                      url: c.backgorund,
                      noText: true,
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // 主题背景色
                      Theme.of(context).colorScheme.background.withOpacity(0.3),
                      Theme.of(context).colorScheme.background.withOpacity(0.9),
                      Theme.of(context).colorScheme.background,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 105,
              right: 20,
              child: Row(
                children: [
                  if (needShowCover())
                    Hero(
                      tag: c.heroTag ?? '',
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 150,
                          width: 100,
                          child: c.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : CacheNetWorkImagePic(
                                  c.data.value?.cover ?? '',
                                  fit: BoxFit.cover,
                                  headers: c.detail?.headers,
                                ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.isLoading.value ? "" : c.data.value!.title,
                            softWrap: true,
                            style: Get.theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          DetailExtensionTile(
                            tag: widget.tag,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: null,
              left: 20,
              right: 20,
              bottom: 40,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: DetailContinuePlay(
                      tag: widget.tag,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: DetailFavoriteButton(
                      tag: widget.tag,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
