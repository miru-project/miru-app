import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:extended_image/extended_image.dart';
import 'package:miru_app/utils/miru_storage.dart';

class ComicController extends ReaderController<ExtensionMangaWatch> {
  ComicController({
    required super.title,
    required super.playList,
    required super.detailUrl,
    required super.playIndex,
    required super.episodeGroupId,
    required super.runtime,
    required super.cover,
    required super.anilistID,
  });
  Map<String, MangaReadMode> readmode = {
    'standard': MangaReadMode.standard,
    'rightToLeft': MangaReadMode.rightToLeft,
    'webTonn': MangaReadMode.webTonn,
  };
  final String setting = MiruStorage.getSetting(SettingKey.readingMode);

  final readType = MangaReadMode.standard.obs;

  final currentScale = 1.0.obs;
  // MangaReadMode
  // 当前页码
  final currentPage = 0.obs;

  final pageController = ExtendedPageController().obs;
  final itemPositionsListener = ItemPositionsListener.create();
  final itemScrollController = ItemScrollController();
  final scrollOffsetController = ScrollOffsetController();

  // 是否已经恢复上次阅读
  final isRecover = false.obs;

  // 是否按下 ctrl

  final isZoom = false.obs;

  @override
  void onInit() {
    _initSetting();
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.isEmpty) {
        return;
      }
      final pos = itemPositionsListener.itemPositions.value.first;
      currentPage.value = pos.index;
    });

    ever(readType, (callback) {
      _jumpPage(currentPage.value);
      // 保存设置
      DatabaseService.setMangaReaderType(
        super.detailUrl,
        callback,
      );
    });
    // 如果切换章节，重置当前页码
    ever(super.index, (callback) => currentPage.value = 0);
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
      currentPage.value = int.parse(history.progress);
      _jumpPage(currentPage.value);
    });
    super.onInit();
  }

  onKey(RawKeyEvent event) {
    // 按下 ctrl
    isZoom.value = event.isControlPressed;
    // 上下
    if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      if (readType.value == MangaReadMode.webTonn) {
        return previousPage();
      }
    }
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      if (readType.value == MangaReadMode.webTonn) {
        return nextPage();
      }
    }

    if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      if (readType.value == MangaReadMode.rightToLeft) {
        return nextPage();
      }
      previousPage();
    }

    if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      if (readType.value == MangaReadMode.rightToLeft) {
        return previousPage();
      }
      nextPage();
    }
  }

  _initSetting() async {
    readType.value = readmode[setting] ?? MangaReadMode.standard;
    readType.value = await DatabaseService.getMnagaReaderType(
      super.detailUrl,
      readType.value,
    );
  }

  _jumpPage(int page) async {
    if (readType.value == MangaReadMode.webTonn) {
      if (itemScrollController.isAttached) {
        itemScrollController.jumpTo(
          index: page,
        );
      }
      return;
    }
    if (pageController.value.hasClients) {
      pageController.value.jumpToPage(page);
      return;
    }
    pageController.value = ExtendedPageController(initialPage: page);
  }

  // 下一页
  @override
  void nextPage() {
    if (readType.value != MangaReadMode.webTonn) {
      pageController.value.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      scrollOffsetController.animateScroll(
        duration: const Duration(milliseconds: 100),
        curve: Curves.ease,
        offset: 200.0,
      );
    }
  }

  // 上一页
  @override
  void previousPage() {
    if (readType.value != MangaReadMode.webTonn) {
      pageController.value.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      scrollOffsetController.animateScroll(
        duration: const Duration(milliseconds: 100),
        curve: Curves.ease,
        offset: -200.0,
      );
    }
  }

  @override
  void onClose() {
    if (super.watchData.value != null) {
      // 获取所有页数量
      final pages = super.watchData.value!.urls.length;
      super.addHistory(
        currentPage.value.toString(),
        pages.toString(),
      );
    }
    if (MiruStorage.getSetting(SettingKey.autoTracking) && anilistID != "") {
      AniListProvider.editList(
        status: AnilistMediaListStatus.current,
        progress: playIndex + 1,
        mediaId: anilistID,
      );
    }
    super.onClose();
    //remove the cache that saved
    CacheNetWorkImagePic.clearCache();
  }
}
