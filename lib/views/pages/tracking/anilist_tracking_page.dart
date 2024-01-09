import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/tracking_page_controller.dart';
import 'package:miru_app/views/widgets/anilist_horizontal_list.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/card.dart';
import 'package:miru_app/views/widgets/progress.dart';
import 'package:miru_app/views/widgets/settings/settings_tile.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/pages/anilist_webview.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:desktop_webview_window/desktop_webview_window.dart';

class AniListTrackingPage extends StatefulWidget {
  const AniListTrackingPage({super.key});

  @override
  State<AniListTrackingPage> createState() => _AniListTrackingPageState();
}

class _AniListTrackingPageState extends State<AniListTrackingPage> {
  var options = InAppBrowserClassOptions(
    crossPlatform: InAppBrowserOptions(hideUrlBar: false),
    inAppWebViewGroupOptions: InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
    ),
  );
  final TrackingPageController c = Get.put(TrackingPageController());
  late Future<Map<String, String>> userValue;
  final isRefreshing = false.obs;

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync'),
        actions: [
          PopupMenuButton(
            child: const Icon(Icons.more_horiz_rounded),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Login with webview'.i18n),
                onTap: () {
                  Get.to(
                    () => const AnilistWebViewPage(
                      url:
                          "https://anilist.co/api/v2/oauth/authorize?client_id=15748&response_type=token",
                    ),
                  );
                },
              )
            ],
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            isRefreshing.value = true;
          },
          child: Center(
            child: Obx(() => ListView(children: [
                  if (!c.anilistIsLogin.value)
                    Card(
                        child: SettingsTile(
                      title: "Seems you haven't login into AniList yet".i18n,
                      buildSubtitle: () =>
                          "Please login into AniList first".i18n,
                      trailing: FilledButton(
                        onPressed: () {
                          AniListProvider.authenticate();
                        },
                        child: Text("Login".i18n),
                      ),
                    ))
                  else
                    Column(children: [
                      FutureBuilder(
                          future: AniListProvider.getuserData(),
                          builder: (context, snapshot) {
                            final data = snapshot.data;
                            if (snapshot.hasData) {
                              return Column(children: [
                                Card(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 10),
                                        child: ListTile(
                                          leading: ClipOval(
                                              child: CacheNetWorkImagePic(
                                            data!["UserAvatar"]!,
                                            fit: BoxFit.fitHeight,
                                            width: 64,
                                            height: 64,
                                          )),
                                          title: Text(data['User']!),
                                        ))),
                                Card(
                                    child: Column(children: [
                                  SettingsTile(
                                    title: "Manga Watched".i18n,
                                    buildSubtitle: () =>
                                        "${"Total".i18n} : ${data['MangaChapterRead']}",
                                  ),
                                  SettingsTile(
                                    title: "Amime Episodes Watched".i18n,
                                    buildSubtitle: () =>
                                        "${"Total".i18n} : ${data['AnimeEpWatched']}",
                                  )
                                ]))
                              ]);
                            } else if ((snapshot.hasError)) {
                              return SettingsTile(
                                title: "Error".i18n,
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }),
                      const Card(
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: AnilistHorizontalList(
                                anilistType: AnilistType.anime,
                              ))),
                      const Card(
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: AnilistHorizontalList(
                                anilistType: AnilistType.manga,
                              )))
                    ]),
                  const SizedBox(height: 8),
                ])),
          )),
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
        const Text("Seems you haven't login into AniList yet"),
        const SizedBox(height: 20),
        const Text(
          "Please login into AniList first",
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 20),
        PlatformFilledButton(
          onPressed: () async {
            // AniList.authenticate();
            final webview = await WebviewWindow.create();
            webview
              ..launch(
                "https://anilist.co/api/v2/oauth/authorize?client_id=15748&response_type=token",
              )
              ..addOnUrlRequestCallback((url) {
                debugPrint(url);
                if (url.contains("miruapp")) {
                  AniListProvider.saveAuthToken(url);
                  webview.close();
                }
              });
          },
          child: Text("Login".i18n),
        )
      ];
    }
    return [
      Text(
        "AniList Tracking",
        style: fluent.FluentTheme.of(context).typography.subtitle,
      ),
      const SizedBox(height: 20),
      FutureBuilder(
        future: AniListProvider.getuserData(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(
              child: ProgressRing(),
            );
          }
          return PlatformCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  ClipOval(
                    child: CacheNetWorkImagePic(
                      data!["UserAvatar"]!,
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
                        data['User']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Manga Watched: ${data['MangaChapterRead']}".i18n,
                      ),
                      Text(
                        "Amime Episodes Watched: ${data['AnimeEpWatched']}"
                            .i18n,
                      ),
                    ],
                  ),
                  const Spacer(),
                  PlatformButton(
                    child: const Text("Logout"),
                    onPressed: () {
                      c.anilistIsLogin.value = false;
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 10),
      const AnilistHorizontalList(anilistType: AnilistType.anime),
      const AnilistHorizontalList(
        anilistType: AnilistType.manga,
      )
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
