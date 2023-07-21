import 'dart:async';

import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class ReaderController<T> extends GetxController {
  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playIndex;
  final int episodeGroupId;
  final ExtensionRuntime runtime;

  ReaderController({
    required this.title,
    required this.playList,
    required this.detailUrl,
    required this.playIndex,
    required this.episodeGroupId,
    required this.runtime,
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
      watchData.value = await runtime.watch(
        cuurentPlayUrl,
      ) as T;
    } catch (e) {
      error.value = e.toString();
    }
  }

  showControlPanel() {
    isShowControlPanel.value = true;
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      isShowControlPanel.value = false;
    });
  }
}
