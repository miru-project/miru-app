// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_windows_webview/flutter_windows_webview.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/providers/tmdb_provider.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/views/dialogs/tmdb_binding.dart';
import 'package:miru_app/controllers/home_controller.dart';
import 'package:miru_app/controllers/main_controller.dart';
import 'package:miru_app/views/pages/watch/watch_page.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/utils/external_player.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/views/widgets/messenger.dart';

class DetailPageController extends GetxController {
  DetailPageController({
    required this.package,
    required this.url,
    this.heroTag,
  });

  final String package;
  final String url;
  final String? heroTag;

  ScrollController scrollController = ScrollController();

  final RxBool isFavorite = false.obs;
  final Rx<ExtensionDetail?> data = Rx(null);
  final Rx<History?> history = Rx(null);
  final RxString error = ''.obs;
  final RxBool isLoading = true.obs;
  final RxInt selectEpGroup = 0.obs;
  final RxString aniListID = ''.obs;
  final Rx<TMDBDetail?> tmdb = Rx(null);
  final Rx<ExtensionService?> runtime = Rx(null);
  ExtensionType get type =>
      runtime.value?.extension.type ?? ExtensionType.bangumi;
  Extension? get extension => runtime.value?.extension;

  ExtensionDetail? get detail => data.value;
  set detail(ExtensionDetail? value) => data.value = value;

  TMDBDetail? get tmdbDetail => tmdb.value;
  set tmdbDetail(TMDBDetail? value) => tmdb.value = value;

  String? get backgorund {
    String? bg;
    if (tmdbDetail != null && tmdbDetail!.backdrop != null) {
      bg = TmdbApi.getImageUrl(tmdbDetail!.backdrop!) ?? '';
    } else {
      bg = detail?.cover;
    }
    return bg;
  }

  MiruDetail? _miruDetail;

  int _tmdbID = -1;

  final _flyoutController = fluent.FlyoutController();

  @override
  void onInit() {
    onRefresh();
    Get.find<MainController>().setAcitons([
      fluent.IconButton(
        icon: const Icon(fluent.FluentIcons.pop_expand),
        onPressed: () async {
          final webview = FlutterWindowsWebview();
          await webview.setUA(MiruStorage.getUASetting());
          webview.launchWebview(
            extension!.webSite + url,
            WebviewOptions(
              onNavigation: (url) {
                if (Uri.parse(url).host != Uri.parse(extension!.webSite).host) {
                  return false;
                }
                webview.getCookies(url).then((value) async {
                  if (value.containsKey("cf_clearance")) {
                    debugPrint("验证通过");
                  }
                  runtime.value!.setCookie(
                    value.entries
                        .map((e) => '${e.key}=${e.value}')
                        .toList()
                        .join(';'),
                  );
                });

                return false;
              },
            ),
          );
        },
      ),
      fluent.FlyoutTarget(
        controller: _flyoutController,
        child: fluent.IconButton(
          icon: const Icon(fluent.FluentIcons.more),
          onPressed: () {
            _flyoutController.showFlyout(builder: (context) {
              return SizedBox(
                width: 300,
                child: Card(
                    child: fluent.Column(
                  mainAxisSize: fluent.MainAxisSize.min,
                  children: [
                    if (detail != null)
                      fluent.ListTile(
                        title: Text(
                          'detail.modify-tmdb-binding'.i18n,
                        ),
                        onPressed: () {
                          router.pop();
                          modifyTMDBBinding();
                        },
                      )
                  ],
                )),
              );
            });
          },
        ),
      )
    ]);
    super.onInit();
  }

  onRefresh() async {
    runtime.value = ExtensionUtils.runtimes[package];
    await refreshFavorite();
    try {
      _miruDetail = await DatabaseService.getMiruDetail(package, url);
      _tmdbID = _miruDetail?.tmdbID ?? -1;
      aniListID.value = _miruDetail?.aniListID ?? "";
      await getDetail();
      await getTMDBDetail();
      await getHistory();
      isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    }
  }

  // 修改 tmdb 绑定
  modifyTMDBBinding() async {
    // 判断是否有 key
    if (MiruStorage.getSetting(SettingKey.tmdbKey) == "") {
      showPlatformSnackbar(
        context: currentContext,
        content: 'detail.tmdb-key-missing'.i18n,
        severity: fluent.InfoBarSeverity.error,
      );
      return;
    }

    dynamic data;
    if (Platform.isAndroid) {
      data = await Get.to(TMDBBinding(
        title: detail!.title,
      ));
    } else {
      data = await fluent.showDialog(
        context: currentContext,
        builder: (context) => TMDBBinding(title: detail!.title),
      );
    }
    if (data != null) {
      await getRemoteTMDBDetail(
        id: data['id'],
        mediaType: data['media_type'],
      );
    }
  }

  getDetail() async {
    if (_miruDetail != null) {
      detail = ExtensionDetail.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(_miruDetail!.data),
        ),
      );
      getRemoteDeatil();
    } else {
      await getRemoteDeatil();
    }
  }

  getRemoteDeatil() async {
    try {
      detail = await runtime.value!.detail(url);
      await DatabaseService.putMiruDetail(
        package,
        url,
        detail!,
        tmdbID: _tmdbID,
        anilistID: aniListID.value,
      );
    } catch (e) {
      // 弹出错误信息
      if (runtime.value == null) {
        final content = FlutterI18n.translate(
          currentContext,
          'common.extension-missing',
          translationParams: {
            'package': package,
          },
        );
        showPlatformSnackbar(
          context: currentContext,
          content: content,
          severity: fluent.InfoBarSeverity.error,
        );
        throw content;
      } else {
        showPlatformSnackbar(
          context: currentContext,
          title: 'detail.get-lastest-data-error'.i18n,
          content: e.toString().split('\n')[0],
          severity: fluent.InfoBarSeverity.error,
        );
      }
      rethrow;
    }
  }

  getTMDBDetail() async {
    tmdbDetail = await DatabaseService.getTMDBDetail(_tmdbID);
    if (detail == null) {
      return;
    }
    if (tmdbDetail == null) {
      getRemoteTMDBDetail();
      return;
    }
    getRemoteTMDBDetail(id: tmdbDetail!.id, mediaType: tmdbDetail!.mediaType);
  }

  getRemoteTMDBDetail({int? id, String? mediaType}) async {
    if (id != null && mediaType != null) {
      tmdbDetail = await TmdbApi.getDetail(id, mediaType);
      if (tmdbDetail == null) {
        return;
      }
    } else {
      tmdbDetail = await TmdbApi.getDetailBySearch(detail!.title);
      if (tmdbDetail == null) {
        return;
      }
    }
    _tmdbID = await DatabaseService.putTMDBDetail(
      tmdbDetail!.id,
      tmdbDetail!,
      tmdbDetail!.mediaType,
    );
    // 更新 id
    await DatabaseService.putMiruDetail(
      package,
      url,
      detail!,
      tmdbID: _tmdbID,
      anilistID: aniListID.value,
    );
  }

  saveAniListIds() async {
    await DatabaseService.putMiruDetail(
      package,
      url,
      detail!,
      anilistID: aniListID.value,
    );
  }

  getHistory() async {
    // 获取历史记录
    final history_ = await DatabaseService.getHistoryByPackageAndUrl(
      package,
      url,
    );
    if (history_ != null) {
      // 并且剧集的数量大于历史记录的剧集列表数量 防止历史记录超出剧集列表数量
      if (history_.episodeGroupId < detail!.episodes!.length) {
        history.value = history_;
        selectEpGroup.value = history_.episodeGroupId;
      }
    }
  }

  refreshFavorite() async {
    isFavorite.value = await DatabaseService.isFavorite(
      package: package,
      url: url,
    );
  }

  toggleFavorite() async {
    if (detail == null) {
      return;
    }
    try {
      await DatabaseService.toggleFavorite(
        package: package,
        url: url,
        cover: detail!.cover,
        name: detail!.title,
      );
    } catch (e) {
      showPlatformSnackbar(
        context: currentContext,
        content: e.toString().split('\n')[0],
        severity: fluent.InfoBarSeverity.error,
      );
      rethrow;
    }
    await refreshFavorite();
    Get.find<HomePageController>().onRefresh();
  }

  goWatch(
    BuildContext context,
    List<ExtensionEpisode> urls,
    int index,
    int selectEpGroup,
  ) async {
    if (runtime.value == null) {
      showPlatformSnackbar(
        context: currentContext,
        content: FlutterI18n.translate(
          currentContext,
          'common.extension-missing',
          translationParams: {
            'package': package,
          },
        ),
        severity: fluent.InfoBarSeverity.error,
      );
      return;
    }

    if (type == ExtensionType.bangumi) {
      final player = MiruStorage.getSetting(SettingKey.videoPlayer);

      if (player != 'built-in') {
        showPlatformSnackbar(
          context: currentContext,
          content: FlutterI18n.translate(
            currentContext,
            'external-player-launching',
            translationParams: {
              'player': player,
            },
          ),
        );
        late ExtensionBangumiWatch watchData;
        try {
          watchData = await runtime.value!.watch(urls[index].url)
              as ExtensionBangumiWatch;
        } catch (e) {
          showPlatformSnackbar(
            context: currentContext,
            content: e.toString().split('\n')[0],
            severity: fluent.InfoBarSeverity.error,
          );
          return;
        }
        try {
          if (GetPlatform.isMobile) {
            await launchMobileExternalPlayer(watchData.url, player);
            return;
          }
          await launchDesktopExternalPlayer(watchData.url, player);
          return;
        } catch (e) {
          showPlatformSnackbar(
            context: currentContext,
            content: e.toString().split('\n')[0],
            severity: fluent.InfoBarSeverity.error,
          );
        }
      }
    }

    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: ((context, animation, secondaryAnimation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.ease,
              ),
            ),
            child: WatchPage(
              cover: detail!.cover,
              playList: urls,
              package: package,
              playerIndex: index,
              title: detail!.title,
              episodeGroupId: selectEpGroup,
              detailUrl: url,
              anilistID: aniListID.value,
            ),
          );
        }),
      ),
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    Get.find<MainController>().setAcitons([]);
    super.onClose();
  }
}
