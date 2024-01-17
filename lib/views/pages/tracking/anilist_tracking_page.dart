import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/tracking_page_controller.dart';
import 'package:miru_app/views/widgets/anilist_horizontal_list.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/card.dart';
import 'package:miru_app/views/widgets/progress.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class AniListTrackingPage extends StatefulWidget {
  const AniListTrackingPage({super.key});

  @override
  State<AniListTrackingPage> createState() => _AniListTrackingPageState();
}

class _AniListTrackingPageState extends State<AniListTrackingPage> {
  final TrackingPageController c = Get.put(TrackingPageController());

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('anilist.title'.i18n),
        actions: [
          Obx(
            () {
              if (!c.anilistIsLogin.value) {
                return const SizedBox.shrink();
              }
              return PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text("common.logout".i18n),
                      onTap: () {
                        c.logoutAniList();
                      },
                    )
                  ];
                },
              );
            },
          )
        ],
      ),
      body: Obx(
        () {
          final isLogin = c.anilistIsLogin.value;
          if (isLogin) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: _buildContent(context),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildContent(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Obx(() {
      final isLogin = c.anilistIsLogin.value;
      if (isLogin) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          children: _buildContent(context),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildContent(context),
        ),
      );
    });
  }

  List<Widget> _buildContent(BuildContext context) {
    if (!c.anilistIsLogin.value) {
      return [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/icon/anilist.jpg'),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 20),
        Text("anilist.login-hint-1".i18n),
        const SizedBox(height: 20),
        Text(
          "anilist.login-hint-2".i18n,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 20),
        PlatformFilledButton(
          onPressed: () {
            c.loginAniList();
          },
          child: Text("common.login".i18n),
        )
      ];
    }

    return [
      if (!Platform.isAndroid) ...[
        Text(
          'anilist.title'.i18n,
          style: fluent.FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 20),
      ],
      FutureBuilder(
        future: c.initAnilistData(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.hasError) {
            return Column(
              children: [
                Text(snapshot.error.toString()),
                PlatformButton(
                  child: Text("common.retry".i18n),
                  onPressed: () {
                    setState(() {});
                  },
                )
              ],
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: ProgressRing(),
            );
          }

          if (data == null) {
            return Center(
              child: Text("common.no-data".i18n),
            );
          }

          final userData = data["userData"];
          final animeData = data["animeData"];
          final mangaData = data["mangaData"];

          return Column(
            children: [
              PlatformCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      ClipOval(
                        child: CacheNetWorkImagePic(
                          userData["UserAvatar"]!,
                          fit: BoxFit.fitHeight,
                          width: 64,
                          height: 64,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['User']!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            FlutterI18n.translate(
                              context,
                              "anilist.manga-chaper-read",
                              translationParams: {
                                "chapters": userData['MangaChapterRead']
                              },
                            ),
                          ),
                          Text(
                            FlutterI18n.translate(
                              context,
                              "anilist.anime-episode-watch",
                              translationParams: {
                                "episodes": userData['AnimeEpWatched']
                              },
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (!Platform.isAndroid)
                        PlatformButton(
                          child: Text("common.logout".i18n),
                          onPressed: () {
                            c.logoutAniList();
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnilistHorizontalList(
                anilistType: AnilistType.anime,
                data: animeData,
              ),
              AnilistHorizontalList(
                anilistType: AnilistType.manga,
                data: mangaData,
              )
            ],
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidWidget: _buildAndroid(context),
      desktopWidget: _buildDesktop(context),
    );
  }
}
