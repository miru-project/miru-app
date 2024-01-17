import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/data/services/database_service.dart';
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
  bool timerCancel = false;
  Rx<AnimationController>? animationController;
  final pageController = ExtendedPageController().obs;
  final itemPositionsListener = ItemPositionsListener.create();
  final itemScrollController = ItemScrollController();
  final scrollOffsetController = ScrollOffsetController();
  final scrolloffsetListener = ScrollOffsetListener.create();
  final transformationController = TransformationController();

  List columnKeys = [GlobalKey()];
  // 是否已经恢复上次阅读
  final isRecover = false.obs;
  double yPos = 0.0;
  @override
  void onInit() {
    _initSetting();
    transformationController.addListener(() {
      if (columnKeys[0].currentWidget == null) return;
      final matrix = transformationController.value;
      yPos = matrix.getTranslation().y;
      final scale = matrix.getMaxScaleOnAxis();
      final page = getYPage(columnKeys, yPos, scale);
      currentPage.value = page;
      // debugPrint("$page $yPos");
    });
    // transformationcontroller.addListener(() {
    //   final matrix = transformationcontroller.value;
    //   final scale = matrix.getMaxScaleOnAxis();
    //   currentScale.value = scale;
    //   final y_dir = matrix.getTranslation().y;
    //   // print('Current scale: $scale y_dir: $y_dir');
    // });
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
      columnKeys =
          List.generate(watchData.value!.urls.length, (index) => GlobalKey());
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

  _initSetting() async {
    readType.value = readmode[setting] ?? MangaReadMode.standard;
    readType.value = await DatabaseService.getMnagaReaderType(
        super.detailUrl, readType.value);
  }

  //get the postion of  children border
  List<double> childSepHeight(List columnKeys) {
    {
      final List<double> heights = [];
      double seperator = 0;
      for (int i = 0; i < columnKeys.length; i++) {
        final RenderBox renderBox =
            columnKeys[i].currentContext.findRenderObject();
        seperator -= renderBox.size.height;
        heights.add(seperator);
      }
      return heights;
    }
  }

  int getYPage(List columnKeys, double yPos, double scale) {
    double seperator = -1.0;
    int val = 0;
    for (int i = 0; i < columnKeys.length; i++) {
      final RenderBox renderBox =
          columnKeys[i].currentContext.findRenderObject();

      if (seperator * scale < yPos) {
        val = i;
        break;
      }
      seperator -= renderBox.size.height;
    }
    debugPrint("$yPos $val $seperator $scale");
    return val;
  }

  _jumpPage(int page) async {
    if (readType.value == MangaReadMode.webTonn) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (columnKeys[0].currentWidget == null) return;
      final renderHeight = childSepHeight(columnKeys);
      transformationController.value = Matrix4.identity()
        ..translate(0.0, renderHeight[page - 1]); // translate(x,y);
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
      if (currentPage.value == columnKeys.length - 1) return;
      final offset = columnKeys[currentPage.value]
          .currentContext
          .findRenderObject()
          .size
          .height;
      webtoonJumpWithOffset(offset);
    }
  }

  void webtoonJumpWithOffset(double yOffset) {
    double endYPos = yPos - yOffset;
    Tween(begin: yPos, end: endYPos)
        .animate(
      CurvedAnimation(
        parent: animationController!.value,
        curve: Curves.ease,
      ),
    )
        .addListener(() {
      transformationController.value = Matrix4.identity()
        ..translate(0.0, endYPos); // translate(x,y);
    });
    animationController!.value.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController!.value.reset();
      }
    });
    animationController!.value.forward();
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
      if (currentPage.value == 0) return;
      final offset = columnKeys[currentPage.value - 1]
          .currentContext
          .findRenderObject()
          .size
          .height;
      webtoonJumpWithOffset(-offset);
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
    pageController.value.dispose();
    animationController?.value.dispose();
    transformationController.dispose();
    if (MiruStorage.getSetting(SettingKey.autoTracking) && anilistID != "") {
      AniListProvider.editList(
        status: AnilistMediaListStatus.current,
        progress: playIndex + 1,
        mediaId: anilistID,
      );
    }
    super.onClose();
  }
}
