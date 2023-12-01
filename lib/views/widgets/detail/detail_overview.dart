import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/providers/tmdb_provider.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';

class DetailOverView extends StatelessWidget {
  const DetailOverView({
    Key? key,
    this.tag,
  }) : super(key: key);

  final String? tag;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DetailPageController>(tag: tag);
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (c.tmdbDetail == null || c.tmdbDetail!.backdrop == null) {
                return const SizedBox();
              }
              final images = [c.tmdbDetail!.backdrop!, ...c.tmdbDetail!.images];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tmdb.backdrops'.i18n,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final image = images[index];
                        final url = TmdbApi.getImageUrl(image);
                        if (url == null) {
                          return const SizedBox();
                        }
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.only(right: 8),
                          child: CacheNetWorkImagePic(
                            url,
                            height: 160,
                          ),
                        );
                      },
                      itemCount: images.length,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
            Obx(
              () => SelectableText(
                c.tmdbDetail?.overview ?? c.detail?.desc ?? '',
                style: const TextStyle(
                  height: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () {
                if (c.tmdbDetail == null) {
                  return const SizedBox();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'detail.additional-info'.i18n,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${'tmdb.status'.i18n}: ${c.tmdbDetail!.status}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${'tmdb.genres'.i18n}: ${c.tmdbDetail!.genres.join(', ')}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${'tmdb.languages'.i18n}: ${c.tmdbDetail!.languages.join(', ')}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${'tmdb.release-date'.i18n}: ${c.tmdbDetail!.releaseDate}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${'tmdb.original-title'.i18n}: ${c.tmdbDetail!.originalTitle}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${'tmdb.runtime'.i18n}: ${c.tmdbDetail!.runtime}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
