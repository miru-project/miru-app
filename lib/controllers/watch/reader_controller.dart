import 'dart:async';

import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/controllers/home_controller.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/router/router.dart';

class ReaderController<T> extends GetxController {
  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playIndex;
  final int episodeGroupId;
  final ExtensionService runtime;
  final String? cover;
  final String anilistID;

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
  get cuurentPlayUrl => playList[index.value].url;
  Timer? _timer;

  @override
  void onInit() {
    getContent();
    ever(index, (callback) => getContent());
    super.onInit();
  }

  getContent() async {
    try {
      error.value = '';
      watchData.value = null;
      watchData.value =
          await runtime.watch(cuurentPlayUrl, currentContext) as T;
    } catch (e) {
      error.value = e.toString();
    }
  }

  void previousPage() {}

  void nextPage() {}

  showControlPanel() {
    isShowControlPanel.value = true;
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      isShowControlPanel.value = false;
    });
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
