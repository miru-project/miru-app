import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:miru_app/controllers/home_controller.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:battery_plus/battery_plus.dart';

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
  Timer? _barreryTimer;
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
  // final height = 1000.0.obs;
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
  final statusBarElement = <String, RxBool>{
    'reader-settings.battery'.i18n: true.obs,
    'reader-settings.time'.i18n: true.obs,
    'reader-settings.page-indicator'.i18n: true.obs,
    'reader-settings.battery-icon'.i18n: true.obs,
  };
  final batteryLevel = 100.obs;
  final currentTime = ''.obs;
  Future<void> _statusBar() async {
    final battery = Battery();
    batteryLevel.value = await battery.batteryLevel;
    final datenow = DateTime.now();
    final hour = datenow.hour < 10 ? "0${datenow.hour}" : datenow.hour;
    final minute = datenow.minute < 10 ? "0${datenow.minute}" : datenow.minute;
    currentTime.value = "$hour:$minute";
  }

  final alignMode = Alignment.bottomLeft.obs;

  @override
  void onInit() async {
    // getContent();
    autoScrollInterval.value = _autoScrollInterval;
    autoScrollOffset.value = _autoScrollOffset;
    nextPageHitBox.value = _nextPageHitBox;
    prevPageHitBox.value = _prevPageHitBox;
    await _statusBar();
    _barreryTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) => _statusBar());

    mouseTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (setControllPanel.value) {
        isShowControlPanel.value = true;
        return;
      }
      isShowControlPanel.value = false;
    });
    super.onInit();
  }

  int localToGloabalProgress(int localProgress) {
    int progress = 0;
    for (int i = 0; i < index.value; i++) {
      progress += itemlength[i];
    }
    progress = localProgress.toInt() + progress;
    return progress;
  }

  List<int> globalToLocalProgress(int globalProgress) {
    int fullIndex = 0;
    int localProgress = 0;
    int chapter = 0;
    // debugPrint(currentLocalProgress.value.toString());
    for (int i = 0; i < itemlength.length; i++) {
      fullIndex += itemlength[i];
      if (fullIndex > globalProgress) {
        chapter = i;
        localProgress = globalProgress - (fullIndex - itemlength[i]);
        break;
      }
    }
    return [localProgress, chapter];
  }

  void previousPage() {}
  void nextPage() {}
  void loadNextChapter();
  void loadPrevChapter();

  void nextChap() {
    clearData();
    index.value++;
    getContent();
  }

  void prevChap() {
    clearData();
    index.value--;
    getContent();
  }

  Future<void> getContent();
  Future<void> loadTargetContent(int targetIndex);

  void clearData() {
    itemlength.fillRange(0, itemlength.length, 0);
    items.fillRange(0, items.length, []);
    watchData.value = null;
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

  @override
  void onClose() {
    _barreryTimer?.cancel();
    autoScrollTimer?.cancel();
    mouseTimer?.cancel();
    super.onClose();
  }
}
