import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/pages/watch/reader_controller.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class NovelController extends ReaderController<ExtensionFikushonWatch> {
  NovelController({
    required super.title,
    required super.playList,
    required super.detailUrl,
    required super.playIndex,
    required super.episodeGroupId,
    required super.runtime,
    required super.cover,
  });

  // 字体大小
  final fontSize = (18.0).obs;
  final itemPositionsListener = ItemPositionsListener.create();
  final isRecover = false.obs;
  final positions = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fontSize.value = MiruStorage.getSetting(SettingKey.novelFontSize);

    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.isEmpty) {
        return;
      }
      final pos = itemPositionsListener.itemPositions.value.first;
      positions.value = pos.index;
    });
    ever(
      fontSize,
      (callback) => MiruStorage.setSetting(SettingKey.novelFontSize, callback),
    );
    ever(super.watchData, (callback) async {
      if (isRecover.value || callback == null) {
        return;
      }
      isRecover.value = true;
      // 获取上次阅读的页码
      final history = await DatabaseUtils.getHistoryByPackageAndUrl(
        super.runtime.extension.package,
        super.detailUrl,
      );
      if (history == null) {
        return;
      }
      positions.value = int.parse(history.progress);
    });
  }

  @override
  void onClose() {
    if (super.watchData.value != null) {
      final totalProgress = watchData.value!.content.length.toString();
      super.addHistory(
        positions.value.toString(),
        totalProgress,
      );
    }
    super.onClose();
  }
}
