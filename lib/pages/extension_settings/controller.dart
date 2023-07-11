import 'package:get/get.dart';
import 'package:miru_app/models/extension_setting.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class ExtensionSettingsPageController extends GetxController {
  ExtensionSettingsPageController(this.package);
  final String package;

  final Rx<ExtensionRuntime?> runtime = Rx(null);

  final List<ExtensionSetting> settings = <ExtensionSetting>[].obs;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() async {
    runtime.value = ExtensionUtils.extensions[package];
    settings.clear();
    settings.addAll(await DatabaseUtils.getExtensionSettings(package));
  }
}
