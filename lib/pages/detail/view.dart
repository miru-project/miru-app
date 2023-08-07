import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/api/tmdb.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/detail/controller.dart';
import 'package:miru_app/pages/detail/widgets/detail_appbar_flexible_space.dart';
import 'package:miru_app/pages/detail/widgets/detail_appbar_title.dart';
import 'package:miru_app/pages/detail/widgets/detail_background_color.dart';
import 'package:miru_app/pages/detail/widgets/detail_episodes.dart';
import 'package:miru_app/pages/detail/widgets/detail_favorite_button.dart';
import 'package:miru_app/pages/detail/widgets/detail_overview.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/cache_network_image.dart';
import 'package:miru_app/widgets/card_tile.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    Key? key,
    required this.url,
    required this.package,
    this.heroTag,
  }) : super(key: key);
  final String url;
  final String package;
  final String? heroTag;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late DetailPageController c;

  @override
  void initState() {
    c = Get.put(
      DetailPageController(
        package: widget.package,
        url: widget.url,
        heroTag: widget.heroTag,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<DetailPageController>();
    super.dispose();
  }

  Widget _buildAndroidDetail(BuildContext context) {
    if (!ExtensionUtils.extensions.containsKey(widget.package)) {
      return Scaffold(
        body: Center(
          child: Text(FlutterI18n.translate(
            context,
            'common.extension-missing',
            translationParams: {
              'package': widget.package,
            },
          )),
        ),
      );
    }
    return Scaffold(
      body: Obx(() {
        late String episodesString;
        if (c.type.value == ExtensionType.bangumi) {
          episodesString = 'video.episodes'.i18n;
        } else {
          episodesString = 'reader.chapters'.i18n;
        }

        if (c.error.value.isNotEmpty) {
          return Center(
            child: Text(c.error.value),
          );
        }
        return DefaultTabController(
          length: 3,
          child: NestedScrollView(
            controller: c.scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  snap: false,
                  primary: true,
                  title: DetailAppbarTitle(
                    c.detail?.title ?? '',
                    controller: c.scrollController,
                  ),
                  flexibleSpace: const DetailAppbarflexibleSpace(),
                  bottom: TabBar(
                    tabs: [
                      Tab(text: episodesString),
                      Tab(text: 'detail.overview'.i18n),
                      if (c.type.value == ExtensionType.bangumi)
                        Tab(text: 'detail.cast'.i18n),
                    ],
                  ),
                  expandedHeight: 400,
                ),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: TabBarView(
                children: [
                  const DetailEpisodes(),
                  const DetailOverView(),
                  Obx(() {
                    if (c.tmdbDetail == null || c.tmdbDetail!.casts.isEmpty) {
                      return const SizedBox();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        final cast = c.tmdbDetail!.casts[index];
                        late String url = '';
                        if (cast.profilePath != null) {
                          url = TmdbApi.getImageUrl(cast.profilePath!) ?? '';
                        }

                        return ListTile(
                          leading: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CacheNetWorkImage(
                              url,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: Text(cast.name),
                          subtitle: Text(cast.character),
                          onTap: () {
                            launchUrl(
                              Uri.parse(
                                "https://www.themoviedb.org/person/${cast.id}}",
                              ),
                            );
                          },
                        );
                      },
                      itemCount: c.tmdbDetail!.casts.length,
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDesktopDetail(BuildContext context) {
    if (!ExtensionUtils.extensions.containsKey(widget.package)) {
      return Center(
        child: Text(
          FlutterI18n.translate(
            context,
            'common.extension-missing',
            translationParams: {
              'package': widget.package,
            },
          ),
        ),
      );
    }
    return Obx(() {
      if (c.error.value.isNotEmpty) {
        return Center(
          child: Text(c.error.value),
        );
      }

      if (c.isLoading.value) {
        return const Center(
          child: ProgressRing(),
        );
      }

      return Stack(
        children: [
          Animate(
            child: CacheNetWorkImage(
              c.backgorund,
              width: double.infinity,
              height: double.infinity,
            ),
          ).blur(
            begin: const Offset(10, 10),
            end: const Offset(0, 0),
          ),
          Positioned.fill(
            child: DetailBackgroundColor(controller: c.scrollController),
          ),
          Positioned.fill(child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: c.scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 1200 ? 150 : 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 300),
                    SizedBox(
                      height: 330,
                      child: Row(
                        children: [
                          if (constraints.maxWidth > 600) ...[
                            Container(
                              width: 230,
                              height: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CacheNetWorkImage(
                                c.detail!.cover,
                              ),
                            ),
                            const SizedBox(width: 30),
                          ],
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SelectableText(
                                c.detail!.title,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 100,
                                ),
                                child: SelectableText(c.detail!.desc ?? ''),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // 收藏按钮
                                  const DetailFavoriteButton(),
                                  const SizedBox(width: 8),
                                  if (c.tmdbDetail != null)
                                    fluent.Button(
                                      child: const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("TMDB"),
                                            SizedBox(width: 8),
                                            Icon(fluent.FluentIcons.pop_expand)
                                          ],
                                        ),
                                      ),
                                      onPressed: () {
                                        launchUrl(
                                          Uri.parse(
                                            "https://www.themoviedb.org/${c.tmdbDetail!.mediaType}/${c.tmdbDetail!.id}",
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (c.detail!.episodes != null) const DetailEpisodes(),
                    const SizedBox(height: 16),
                    Obx(
                      () {
                        if (c.tmdbDetail == null ||
                            c.tmdbDetail!.images.isEmpty) {
                          return const SizedBox();
                        }
                        return CardTile(
                          title: 'tmdb.backdrops'.i18n,
                          child: SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final image = c.tmdbDetail!.images[index];
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
                                  child: CacheNetWorkImage(
                                    url,
                                    height: 200,
                                  ),
                                );
                              },
                              itemCount: c.tmdbDetail!.images.length,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () {
                        if (c.tmdbDetail == null ||
                            c.tmdbDetail!.casts.isEmpty) {
                          return const SizedBox();
                        }
                        return CardTile(
                          title: 'detail.cast'.i18n,
                          child: SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final cast = c.tmdbDetail!.casts[index];
                                String? url;
                                if (cast.profilePath != null) {
                                  url = TmdbApi.getImageUrl(cast.profilePath!);
                                }
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      launchUrl(
                                        Uri.parse(
                                          "https://www.themoviedb.org/person/${cast.id}}",
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(right: 16),
                                      width: 170,
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: CacheNetWorkImage(
                                              url ?? '',
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            cast.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            cast.character,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: c.tmdbDetail!.casts.length,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () {
                        if (c.tmdbDetail == null ||
                            c.tmdbDetail!.overview == null) {
                          return const SizedBox();
                        }
                        return CardTile(
                          title: "detail.overview".i18n,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: SelectableText(c.tmdbDetail!.overview ?? ''),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () {
                        if (c.tmdbDetail == null) {
                          return const SizedBox();
                        }
                        return CardTile(
                          title: 'detail.additional-info'.i18n,
                          child: Wrap(children: [
                            ...[
                              _buildInfoTile(
                                context,
                                'tmdb.status'.i18n,
                                c.tmdbDetail!.status,
                              ),
                              _buildInfoTile(
                                context,
                                'tmdb.genres'.i18n,
                                c.tmdbDetail!.genres.join(', '),
                              ),
                              _buildInfoTile(
                                context,
                                'tmdb.languages'.i18n,
                                c.tmdbDetail!.languages.join(', '),
                              ),
                              _buildInfoTile(
                                context,
                                'tmdb.release-date'.i18n,
                                c.tmdbDetail!.releaseDate,
                              ),
                              _buildInfoTile(
                                context,
                                'tmdb.original-title'.i18n,
                                c.tmdbDetail!.originalTitle,
                              ),
                              _buildInfoTile(
                                context,
                                'tmdb.runtime'.i18n,
                                c.tmdbDetail!.runtime.toString(),
                              ),
                            ]
                                .map((e) => SizedBox(
                                      width: 200,
                                      child: e,
                                    ))
                                .toList(),
                          ]),
                        );
                      },
                    )
                  ],
                ),
              );
            },
          ))
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroidDetail,
      desktopBuilder: _buildDesktopDetail,
    );
  }
}

_buildInfoTile(BuildContext context, String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      SelectableText(
        value,
      ),
      const SizedBox(height: 16)
    ],
  );
}
