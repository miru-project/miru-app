import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/pages/watch/reader_controller.dart';
import 'package:miru_app/utils/database.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ComicController extends ReaderController<ExtensionMangaWatch> {
  ComicController({
    required super.title,
    required super.playList,
    required super.detailUrl,
    required super.playIndex,
    required super.episodeGroupId,
    required super.runtime,
  });

  final readerType = MangaReadMode.standard.obs;
  // 当前页码
  final currentPage = 0.obs;

  final pageController = PageController().obs;
  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();

  @override
  void onInit() {
    initSettings();
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.isEmpty) {
        return;
      }
      final pos = itemPositionsListener.itemPositions.value.first;
      currentPage.value = pos.index;
    });
    ever(readerType, (callback) {
      if (pageController.value.hasClients) {
        pageController.value.jumpToPage(currentPage.value);
      } else {
        pageController.value = PageController(initialPage: currentPage.value);
      }
      // 保存设置
      DatabaseUtils.setMangaReaderType(
        super.detailUrl,
        callback,
      );
    });
    // 如果切换章节，重置当前页码
    ever(super.index, (callback) => currentPage.value = 0);
    super.onInit();
  }

  initSettings() async {
    readerType.value = await DatabaseUtils.getMnagaReaderType(super.detailUrl);
  }

  // 下一页
  void nextPage() {
    if (readerType.value != MangaReadMode.webTonn) {
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
    if (readerType.value != MangaReadMode.webTonn) {
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
}
