import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/pages/watch/reader_controller.dart';
import 'package:miru_app/utils/miru_storage.dart';

class NovelController extends ReaderController<ExtensionFikushonWatch> {
  NovelController({
    required super.title,
    required super.playList,
    required super.detailUrl,
    required super.playIndex,
    required super.episodeGroupId,
    required super.runtime,
  });

  // 字体大小
  final fontSize = (18.0).obs;

  @override
  void onInit() {
    super.onInit();
    fontSize.value = MiruStorage.getSetting(SettingKey.novelFontSize);
    ever(
      fontSize,
      (callback) => MiruStorage.setSetting(SettingKey.novelFontSize, callback),
    );
  }
}
