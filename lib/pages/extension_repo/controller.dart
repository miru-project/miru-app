import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/miru_storage.dart';

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
      extensionsTemp.clear();
      extensionsTemp.addAll(extensions);
    } catch (e) {
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
