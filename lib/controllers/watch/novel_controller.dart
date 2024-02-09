import 'dart:async';

import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class NovelController extends ReaderController<ExtensionFikushonWatch> {
  NovelController({
    required super.title,
    required super.playList,
    required super.detailUrl,
    required super.playIndex,
    required super.episodeGroupId,
    required super.runtime,
    required super.cover,
    required super.anilistID,
  });

  // 字体大小
  final fontSize = (18.0).obs;
  final ttsRate = 0.3.obs;
  final ttsVolume = 0.3.obs;
  final ttsPitch = 0.3.obs;
  final itemPositionsListener = ItemPositionsListener.create();
  final isRecover = false.obs;
  late final FlutterTts flutterTts;
  final RxBool enableSelectText = false.obs;
  final RxList ttsLang = [].obs;
  final RxString ttsLangValue = ''.obs;
  final playBackIsComplete = false;
  late final RxList<String> subtitles =
      List.generate(playList.length, (index) => "").obs;
  final Rx<Color> textColor = Colors.white.obs;
  initTts() {
    ttsVolume.value = MiruStorage.getSetting(SettingKey.ttsVolume);
    ttsRate.value = MiruStorage.getSetting(SettingKey.ttsRate);
    ttsPitch.value = MiruStorage.getSetting(SettingKey.ttsPitch);
    flutterTts = FlutterTts();
    flutterTts.awaitSpeakCompletion(true);
    flutterTts.setCompletionHandler(() {
      debugPrint("completed");
    });
  }

  @override
  void onInit() async {
    super.onInit();
    getContent();
    initTts();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    fontSize.value = MiruStorage.getSetting(SettingKey.novelFontSize);
    // textColor.value = MiruStorage.getSetting(SettingKey.textColor);
    WakelockPlus.toggle(
        enable: MiruStorage.getSetting(SettingKey.enableWakelock));
    ttsLangValue.value = MiruStorage.getSetting(SettingKey.ttsLanguage);
    ttsLang.value = await flutterTts.getLanguages;
    debugPrint(ttsLang.toString());
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.isEmpty) {
        return;
      }
      final pos = itemPositionsListener.itemPositions.value.first;
      currentGlobalProgress.value = pos.index;
    });
    scrollOffsetListener.changes.listen((event) {
      enableSelectText.value = false;
      hideControlPanel();
    });
    ever(
      fontSize,
      (callback) => MiruStorage.setSetting(SettingKey.novelFontSize, callback),
    );

    // 切换章节时重置页码
    ever(super.watchData, (callback) async {
      if (isRecover.value || callback == null) {
        return;
      }
      isRecover.value = true;
      // 获取上次阅读的页码
      final history = await DatabaseService.getHistoryByPackageAndUrl(
        super.runtime.extension.package,
        super.detailUrl,
      );

      if (history == null ||
          history.progress.isEmpty ||
          episodeGroupId != history.episodeGroupId ||
          history.episodeId != index.value) {
        return;
      }
      currentGlobalProgress.value = int.parse(history.progress);
      _jumpLine(currentGlobalProgress.value);
    });
    ever(progress, (callback) {
      // 防止逆向回饋
      if (!updateSlider.value) {
        return;
      }
      currentGlobalProgress.value = callback;
      _jumpLine(callback);
    });
    // tts 播放
    ever(enableAutoScroll, (callback) async {
      await flutterTts.setLanguage(ttsLangValue.value);
      await flutterTts.setSpeechRate(ttsRate.value);
      await flutterTts.setVolume(ttsVolume.value);
      await flutterTts.setPitch(ttsPitch.value);
      for (int i = currentLocalProgress.value;
          i < itemlength[index.value];
          i++) {
        if (!enableAutoScroll.value) {
          await flutterTts.stop();
          break;
        }
        final readingProgress = items[index.value][i];
        debugPrint("current reading: $readingProgress , progress: $i");
        animeScrollTo(localToGloabalProgress(i) - 1);
        await flutterTts.speak(items[index.value][i]);
      }
      enableAutoScroll.value = false;
    });
    ever(currentGlobalProgress, (callback) {
      if (updateSlider.value) {
        progress.value = callback;
      }
      updateSlider.value = false;
      int fullIndex = 0;
      // debugPrint(currentLocalProgress.value.toString());
      for (int i = 0; i < itemlength.length; i++) {
        fullIndex += itemlength[i];
        if (fullIndex > callback) {
          index.value = i;
          super.index.value = i;
          currentLocalProgress.value = callback - (fullIndex - itemlength[i]);
          break;
        }
      }
    });
    ever(super.watchData, (callback) async {
      if (isRecover.value || callback == null) {
        return;
      }
      loadTargetContent(playIndex);
      isRecover.value = true;
      // 获取上次阅读的页码
      final history = await DatabaseService.getHistoryByPackageAndUrl(
        super.runtime.extension.package,
        super.detailUrl,
      );

      if (history == null ||
          history.progress.isEmpty ||
          episodeGroupId != history.episodeGroupId ||
          history.episodeId != index.value) {
        return;
      }
      currentGlobalProgress.value = int.parse(history.progress);
      _jumpLine(currentGlobalProgress.value);
      // jumpScroller(index.value);
    });
  }

  _jumpLine(int? index) {
    if (index == null) {
      return;
    }
    itemScrollController.jumpTo(index: index);
  }

  animeScrollTo(index) {
    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 10),
    );
  }

  @override
  void onClose() {
    if (super.watchData.value != null) {
      final totalProgress = watchData.value!.content.length.toString();
      super.addHistory(
        currentGlobalProgress.value.toString(),
        totalProgress,
      );
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    flutterTts.stop();
    mouseTimer?.cancel();
    super.onClose();
  }

  //獲取目標章節內容，但不更新當前頁面
  @override
  Future<void> loadTargetContent(int targetIndex) async {
    try {
      if (targetIndex < 0 || targetIndex == itemlength.length) {
        return;
      }
      final dynamic updatedData =
          await runtime.watch(playList[targetIndex].url);
      items[targetIndex] = updatedData.content as List<String>;
      itemlength[targetIndex] = updatedData.content.length;
      subtitles[targetIndex] = updatedData.subtitle ?? '';
    } catch (e) {
      error.value = e.toString();
    }
  }

  @override
  Future<void> loadNextChapter() async {
    await loadTargetContent(index.value + 1);
    return;
  }

  // 加載上一章節，並跳轉到剛才的位置
  @override
  Future<void> loadPrevChapter() async {
    await loadTargetContent(index.value - 1);
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
          index: itemlength[index.value - 1],
          duration: const Duration(milliseconds: 10));
      return;
    }
  }

  @override
  Future<void> getContent() async {
    try {
      error.value = '';
      watchData.value =
          await runtime.watch(cuurentPlayUrl) as ExtensionFikushonWatch;
      itemlength[index.value] = (watchData.value as dynamic)?.content.length;
      items[index.value] = (watchData.value as dynamic)?.content;
      subtitles[index.value] = (watchData.value as dynamic)?.subtitle ?? '';
    } catch (e) {
      error.value = e.toString();
    }
  }
}
