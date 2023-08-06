import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/api/tmdb.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/history.dart';
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
  final RxInt tmdbId = (-1).obs;

  ExtensionDetail? get detail => data.value;
  TMDBDetail? get tmdbDetail => tmdb.value;
  String get backgorund {
    String bg = '';
    if (tmdbDetail != null && tmdbDetail!.backdrop != null) {
      bg = TmdbApi.getImageUrl(tmdbDetail!.backdrop!) ?? '';
    } else {
      bg = detail!.cover;
    }
    return bg;
  }

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() async {
    await refreshFavorite();
    try {
      // 获取详情信息
      final runtime = ExtensionUtils.extensions[package];
      type.value = runtime!.extension.type;
      // 从数据库获取详情信息
      final miruDetail = await DatabaseUtils.getMiruDetail(package, url);

      // 如果有数据则直接使用
      if (miruDetail != null) {
        data.value = ExtensionDetail.fromJson(
          Map<String, dynamic>.from(
            jsonDecode(miruDetail.data),
          ),
        );
        tmdbId.value = miruDetail.tmdbID ?? -1;
        getRemoteDetail();
        // 如果没有数据则从远程获取
      } else {
        await getRemoteDetail();
      }

      // 获取 TMDB 数据
      getTMDBData();

      // 获取历史记录
      final history_ = await DatabaseUtils.getHistoryByPackageAndUrl(
        package,
        url,
      );
      if (history_ != null) {
        // 并且剧集的数量大于历史记录的剧集列表数量 防止历史记录超出剧集列表数量
        if (history_.episodeGroupId < data.value!.episodes!.length) {
          history.value = history_;
          selectEpGroup.value = history_.episodeGroupId;
        }
      }
      isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
    }
  }

  getRemoteDetail() async {
    try {
      data.value = await ExtensionUtils.extensions[package]?.detail(url);
      await DatabaseUtils.putMiruDetail(
        package,
        url,
        data.value!,
      );
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

  getTMDBData() async {
    DatabaseUtils.getTMDBDetail(tmdbId.value).then(
      (value) => tmdb.value = value,
    );
    tmdb.value = await TmdbApi.getDetail(data.value!.title);
    DatabaseUtils.putTMDBDetail(
      tmdb.value!.id,
      tmdb.value!,
    );
    // 更新 id
    DatabaseUtils.putMiruDetail(
      package,
      url,
      data.value!,
      tmdbID: tmdb.value!.id,
    );
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
      cover: data.value!.cover,
      name: data.value!.title,
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
              cover: data.value!.cover,
              playList: urls,
              package: package,
              playerIndex: index,
              title: data.value!.title,
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
