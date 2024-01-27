import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/controllers/home_controller.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReaderController<T> extends GetxController {
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
  final isShowControlPanel = false.obs;
  late final index = playIndex.obs;
  late final progress = 0.obs;
  get cuurentPlayUrl => playList[index.value].url;
  Timer? _timer;
  Timer? autoScrollTimer;
  final isScrolled = true.obs;
  final updateSlider = true.obs;
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
  @override
  void onInit() {
    getContent();
    autoScrollInterval.value = _autoScrollInterval;
    autoScrollOffset.value = _autoScrollOffset;
    nextPageHitBox.value = _nextPageHitBox;
    prevPageHitBox.value = _prevPageHitBox;
    ever(index, (callback) => getContent());
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
      debugPrint(setControllPanel.toString());
      if (setControllPanel.value) {
        isShowControlPanel.value = true;
        return;
      }
      isShowControlPanel.value = false;
      setControllPanel.value = false;
    });
    super.onInit();
  }

  getContent() async {
    try {
      error.value = '';
      watchData.value = null;
      watchData.value = await runtime.watch(cuurentPlayUrl) as T;
    } catch (e) {
      error.value = e.toString();
    }
  }

  void previousPage() {}

  void nextPage() {}

  // showControlPanel() {
  //   if (isShowControlPanel.value) {
  //     hideControlPanel();
  //     return;
  //   }
  //   debugPrint(isMouseHover.toString());
  //   isShowControlPanel.value = true;
  //   _timer?.cancel();
  //   _timer = Timer(const Duration(seconds: 3), () {
  //     isShowControlPanel.value = false;
  //   });
  // }

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
