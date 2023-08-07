import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/api/tmdb.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/models/tmdb.dart';
import 'package:miru_app/pages/home/controller.dart';
import 'package:miru_app/pages/watch/view.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/messenger.dart';

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

  final isFavorite = false.obs;
  final Rx<ExtensionDetail?> data = Rx(null);
  final Rx<History?> history = Rx(null);
  final RxString error = ''.obs;
  final RxBool isLoading = true.obs;
  final RxInt selectEpGroup = 0.obs;
  final Rx<ExtensionType> type = ExtensionType.bangumi.obs;
  final Rx<TMDBDetail?> tmdb = Rx(null);

  ExtensionDetail? get detail => data.value;
  set detail(ExtensionDetail? value) => data.value = value;
  TMDBDetail? get tmdbDetail => tmdb.value;
  set tmdbDetail(TMDBDetail? value) => tmdb.value = value;
  String get backgorund {
    String bg = '';
    if (tmdbDetail != null && tmdbDetail!.backdrop != null) {
      bg = TmdbApi.getImageUrl(tmdbDetail!.backdrop!) ?? '';
    } else {
      bg = detail!.cover;
    }
    return bg;
  }

  int _tmdbID = -1;
  MiruDetail? _miruDetail;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() async {
    // 获取收藏状态
    await refreshFavorite();
    try {
      // 获取扩展类型
      final runtime = ExtensionUtils.extensions[package];
      type.value = runtime!.extension.type;
      _miruDetail = await DatabaseUtils.getMiruDetail(package, url);
      _tmdbID = _miruDetail?.tmdbID ?? -1;
      await getDetail();
      await getTMDBDetail();
      await getHistory();
      isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
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
      detail = await ExtensionUtils.extensions[package]?.detail(url);
      await DatabaseUtils.putMiruDetail(package, url, detail!, tmdbID: _tmdbID);
    } catch (e) {
      // 弹出错误信息
      showPlatformSnackbar(
        context: cuurentContext,
        title: 'detail.get-lastest-data-error'.i18n,
        content: e.toString().split('\n')[0],
        severity: fluent.InfoBarSeverity.error,
      );
    }
  }

  getTMDBDetail() async {
    tmdbDetail = await DatabaseUtils.getTMDBDetail(_tmdbID);
    getRemoteTMDBDetail();
  }

  getRemoteTMDBDetail() async {
    tmdbDetail = await TmdbApi.getDetail(detail!.title);
    _tmdbID = tmdbDetail!.id;
    DatabaseUtils.putTMDBDetail(
      tmdbDetail!.id,
      tmdbDetail!,
    );
    // 更新 id
    await DatabaseUtils.putMiruDetail(
      package,
      url,
      detail!,
      tmdbID: tmdbDetail!.id,
    );
  }

  getHistory() async {
    // 获取历史记录
    final history_ = await DatabaseUtils.getHistoryByPackageAndUrl(
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
    isFavorite.value =
        await DatabaseUtils.isFavorite(package: package, url: url);
  }

  toggleFavorite() async {
    if (isLoading.value) {
      return;
    }
    await DatabaseUtils.toggleFavorite(
      package: package,
      url: url,
      cover: detail!.cover,
      name: detail!.title,
    );
    await refreshFavorite();
    Get.find<HomePageController>().onRefresh();
  }

  goWatch(
    BuildContext context,
    List<ExtensionEpisode> urls,
    int index,
    int selectEpGroup,
  ) {
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
            ),
          );
        }),
      ),
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
