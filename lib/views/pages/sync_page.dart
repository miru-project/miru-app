import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/sync_page_controller.dart';
import 'package:miru_app/views/widgets/anilist_horizontal_list.dart';
import 'package:miru_app/views/widgets/settings_tile.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/pages/anilist_webview.dart';
import 'package:miru_app/utils/anilist.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:desktop_webview_window/desktop_webview_window.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  var options = InAppBrowserClassOptions(
      crossPlatform: InAppBrowserOptions(hideUrlBar: false),
      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));
  final SyncPageController c = Get.put(SyncPageController());
  late Future<Map<String, String>> userValue;
  final isRefreshing = false.obs;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidWidget: _buildAndroid(context),
      desktopWidget: _buildDesktop(context),
    );
  }

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
                  Get.to(() => const AnilistWebViewPage(
                      url:
                          "https://anilist.co/api/v2/oauth/authorize?client_id=15748&response_type=token"));
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
                          AniList.authenticate();
                        },
                        child: Text("Login".i18n),
                      ),
                    ))
                  else
                    Column(children: [
                      FutureBuilder(
                          future: AniList.getuserData(),
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
      // floatingActionButton: FloatingActionButton.extended(
      //     onPressed: () {
      //       // Get.back();
      //       showDialog(
      //           context: context,
      //           builder: (context) {
      //             return const AlertDialog();
      //           });
      //     },
      //     icon: SvgPicture.asset(
      //       "assets/icon/anilist_black_white.svg",
      //       color: Colors.white,
      //     ),
      //     label: const Text("Anilist")),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    int index = 0;
    return fluent.TabView(
      currentIndex: index,
      onChanged: (ind) => setState(() => index = ind),
      tabs: [
        fluent.Tab(
            icon: SvgPicture.asset(
              "assets/icon/anilist_black_white.svg",
              color: Colors.white,
            ),
            text: const Text("Anilist"),
            body: _desktopTabAnilist(context)),
      ],
    );
  }

  Widget _desktopTabAnilist(BuildContext context) {
    return Center(
      child: Obx(() => fluent.ListView(children: [
            if (!c.anilistIsLogin.value)
              SettingsTile(
                title: "Seems you haven't login into AniList yet".i18n,
                buildSubtitle: () => "Please login into AniList first".i18n,
                trailing: FilledButton(
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
                          AniList.saveAuthToken(url);
                          webview.close();
                        }
                      });
                  },
                  child: Text("Login".i18n),
                ),
              )
            else
              Column(children: [
                FutureBuilder(
                    future: AniList.getuserData(),
                    builder: (context, snapshot) {
                      final data = snapshot.data;
                      if (snapshot.hasData) {
                        return Column(children: [
                          fluent.ListTile(
                            leading: ClipOval(
                                child: CacheNetWorkImagePic(
                              data!["UserAvatar"]!,
                              fit: BoxFit.fitHeight,
                              width: 64,
                              height: 64,
                            )),
                            title: Text(data['User']!),
                          ),
                          const SizedBox(height: 8),
                          SettingsTile(
                            title: "Manga Watched".i18n,
                            buildSubtitle: () =>
                                "${"Total".i18n} : ${data['MangaChapterRead']}",
                          ),
                          const SizedBox(height: 8),
                          SettingsTile(
                            title: "Amime Episodes Watched".i18n,
                            buildSubtitle: () =>
                                "${"Total".i18n} : ${data['AnimeEpWatched']}",
                          ),
                          // const SizedBox(height: 8),
                        ]);
                      } else if ((snapshot.hasError)) {
                        return SettingsTile(
                          title: "Error".i18n,
                        );
                      } else {
                        return const fluent.ProgressRing();
                      }
                    }),
                const AnilistHorizontalList(anilistType: AnilistType.anime),
                const AnilistHorizontalList(
                  anilistType: AnilistType.manga,
                )
              ]),
            const SizedBox(height: 8),
          ])),
    );
  }
}
