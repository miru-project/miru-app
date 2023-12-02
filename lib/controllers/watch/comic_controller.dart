import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:async';
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
  });
  Map<String, MangaReadMode> readmode = {
    'standard': MangaReadMode.standard,
    'rightToLeft': MangaReadMode.rightToLeft,
    'webTonn': MangaReadMode.webTonn,
  };
  final String setting = MiruStorage.getSetting(SettingKey.readingMode);
  final readType = MangaReadMode.standard.obs;

  // MangaReadMode
  // 当前页码
  final currentPage = 0.obs;
  bool timerCancel = false;
  final pageController = ExtendedPageController().obs;
  final itemPositionsListener = ItemPositionsListener.create();
  final itemScrollController = ItemScrollController();
  final scrollOffsetController = ScrollOffsetController();
  final scrolloffsetListener = ScrollOffsetListener.create();

  // 是否已经恢复上次阅读
  final isRecover = false.obs;

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
    _pageUpdate();
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

  _pageUpdate() async {
    int curPage = currentPage.value;
    Timer(const Duration(seconds: 2), () {
      //set update timer
      Timer.periodic(const Duration(milliseconds: 600), (timer) {
        // debugPrint('$curPage');
        if (curPage >= super.watchData.value!.urls.length - 2 || timerCancel) {
          timer.cancel();
        }
        curPage++;

        if (super.watchData.value!.urls[curPage] == "") {
          _getPage(curPage);
        }
      });
    });
  }

  _getPage(int page) async {
    await Future.delayed(const Duration(seconds: 1));

    final updatePage = await runtime.updatePages(page) as ExtensionUpdatePages;
    super.watchData.value!.urls[page] = updatePage.url;
  }

  _initSetting() async {
    readType.value = readmode[setting] ?? MangaReadMode.standard;
    readType.value = await DatabaseService.getMnagaReaderType(
        super.detailUrl, readType.value);
  }

  // double mapValue(double value) {
  //   double mappedValue = ((value - 0) * (1 - (-1))) / (2.5 - 0) + (-1);
  //   return mappedValue;
  // }

  _jumpPage(int page) {
    if (readType.value == MangaReadMode.webTonn) {
      if (itemScrollController.isAttached) {
        itemScrollController.jumpTo(
          index: page,
        );
      }
      int curPage = currentPage.value;
      Timer.periodic(const Duration(milliseconds: 600), (timer) {
        // debugPrint('$curPage');
        if (curPage == 0 || timerCancel) {
          timer.cancel();
        }

        if (super.watchData.value!.urls[curPage] == "") {
          _getPage(curPage);
        }
        curPage--;
      });
      return;
    }
    if (pageController.value.hasClients) {
      pageController.value.jumpToPage(page);
      return;
    }
    pageController.value = ExtendedPageController(initialPage: page);
  }

  // 下一页
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
  void previousPage() {
    if (readType.value != MangaReadMode.webTonn) {
      pageController.value.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      scrollOffsetController.animateScroll(
        duration: const Duration(milliseconds: 10),
        curve: Curves.linear,
        offset: -200.0,
      );
    }
  }

  // void scrollWithOffset(double offset) {
  //   scrollOffsetController.animateScroll(
  //       duration: const Duration(milliseconds: 100),
  //       curve: Curves.ease,
  //       offset: offset);
  // }

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
    pageController.value.dispose();
    timerCancel = true;
    super.onClose();
  }
}
