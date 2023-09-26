import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/widgets/messenger.dart';

class ExtensionRepoPageController extends GetxController {
  final isLoading = false.obs;
  List<dynamic> extensions = <dynamic>[].obs;
  final isError = false.obs;
  final search = ''.obs;
  List<dynamic> extensionsTemp = <dynamic>[];

  @override
  void onInit() {
    onRefresh();
    ever(search, (callback) {
      extensions.clear();
      extensions.addAll(
        extensionsTemp
            .where(
              (element) => (element['name'] as String).toLowerCase().contains(
                    search.value.toLowerCase(),
                  ),
            )
            .toList(),
      );
    });
    super.onInit();
  }

  onRefresh() async {
    isLoading.value = true;
    isError.value = false;

    try {
      final dio = Dio();
      final res = await dio.get<String>(
          '${MiruStorage.getSetting(SettingKey.miruRepoUrl)}/index.json');
      extensions = jsonDecode(res.data!);
      if (!MiruStorage.getSetting(SettingKey.enableNSFW)) {
        extensions.removeWhere((element) => element['nsfw'] == "true");
      }
      extensionsTemp.clear();
      extensionsTemp.addAll(extensions);

      if (Platform.isAndroid && extensions.isEmpty) {
        // ignore: use_build_context_synchronously
        showPlatformSnackbar(
          context: currentContext,
          content: 'extension-repo.empty'.i18n,
        );
      }
    } catch (e) {
      isError.value = true;
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
