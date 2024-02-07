import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:miru_app/controllers/home_controller.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

abstract class ReaderController<T> extends GetxController {
  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playIndex;
  final int episodeGroupId;
  final ExtensionService runtime;
  final String? cover;
  final String anilistID;
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();
  ReaderController({
    required this.title,
    required this.playList,
    required this.detailUrl,
    required this.playIndex,
    required this.episodeGroupId,
    required this.runtime,
    required this.anilistID,
    this.cover,
  });

  late Rx<T?> watchData = Rx(null);
  final error = ''.obs;
  final globalItemPositionsListener = ItemPositionsListener.create();
  final globalItemScrollController = ItemScrollController();
  final isShowControlPanel = false.obs;
  late final index = playIndex.obs;
  late final progress = 0.obs;
  get cuurentPlayUrl => playList[index.value].url;
  Timer? autoScrollTimer;
  final isScrolled = true.obs;
  final updateSlider = true.obs;
  final isInfinityScrollMode = false.obs;
  final isLoading = false.obs;
  //點擊區域是否反轉
  final RxBool tapRegionIsReversed = false.obs;
  final dynamic _nextPageHitBox =
      MiruStorage.getSetting(SettingKey.nextPageHitBox);
  final double _prevPageHitBox =
      MiruStorage.getSetting(SettingKey.prevPageHitBox);
  final int _autoScrollInterval =
      MiruStorage.getSetting(SettingKey.autoScrollInterval);
  final double _autoScrollOffset =
      MiruStorage.getSetting(SettingKey.autoScrollOffset);
  final RxInt autoScrollInterval = 300.obs;
  final RxDouble autoScrollOffset = 0.4.obs;
  final RxDouble nextPageHitBox = 0.3.obs;
  final RxDouble prevPageHitBox = 0.3.obs;
  final enableAutoScroll = false.obs;
  final height = 1000.0.obs;
  final RxBool isMouseHover = false.obs;
  final RxBool setControllPanel = false.obs;
  Timer? mouseTimer;
  final RxBool enableWakeLock = false.obs;
  final RxBool enableFullScreen = false.obs;
  late final RxList<List<String>> items =
      List.filled(playList.length, <String>[]).obs;
  late final List<int> itemlength = List.filled(playList.length, 0);
  final currentGlobalProgress = 0.obs;
  final currentLocalProgress = 0.obs;
  @override
  void onInit() {
    // getContent();
    autoScrollInterval.value = _autoScrollInterval;
    autoScrollOffset.value = _autoScrollOffset;
    nextPageHitBox.value = _nextPageHitBox;
    prevPageHitBox.value = _prevPageHitBox;
    // ever(index, (callback) {
    //   getContent();
    // });

    ever(enableAutoScroll, (callback) {
      if (callback) {
        autoScrollTimer = Timer.periodic(
            Duration(milliseconds: autoScrollInterval.value), (timer) {
          if (isScrolled.value) {
            scrollOffsetController.animateScroll(
              duration: const Duration(milliseconds: 100),
              curve: Curves.ease,
              offset: autoScrollOffset.value,
            );
          }
        });
        return;
      }
      autoScrollTimer?.cancel();
    });
    mouseTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (setControllPanel.value) {
        isShowControlPanel.value = true;
        return;
      }
      isShowControlPanel.value = false;
    });
    super.onInit();
  }

  getContent() async {
    try {
      error.value = '';
      // watchData.value = null;
      watchData.value = await runtime.watch(cuurentPlayUrl) as T;
      itemlength[index.value] = (watchData.value as dynamic)?.urls.length;
      items[index.value] = (watchData.value as dynamic)?.urls;
    } catch (e) {
      error.value = e.toString();
    }
  }

  localToGloabalProgress(int localProgress) {
    int progress = 0;
    for (int i = 0; i < index.value; i++) {
      progress += itemlength[i];
    }
    progress = localProgress.toInt() + progress;
    return progress;
  }

  void previousPage();

  void nextPage();
  void loadNextChapter() {}
  void nextChap();
  void prevChap();

  void clearData() {
    itemlength.fillRange(0, itemlength.length, 0);
    items.fillRange(0, items.length, []);
    progress.value = 0;
    currentGlobalProgress.value = 0;
    currentLocalProgress.value = 0;
  }

  hideControlPanel() {
    setControllPanel.value = false;
  }

  addHistory(String progress, String totalProgress) async {
    await DatabaseService.putHistory(
      History()
        ..url = detailUrl
        ..episodeId = index.value
        ..type = runtime.extension.type
        ..episodeGroupId = episodeGroupId
        ..package = runtime.extension.package
        ..episodeTitle = playList[index.value].name
        ..title = title
        ..progress = progress
        ..totalProgress = totalProgress
        ..cover = cover,
    );
    await Get.find<HomePageController>().onRefresh();
  }
}
