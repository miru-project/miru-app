import 'package:get/get.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class ExtensionPageController extends GetxController {
  RxMap<String, ExtensionRuntime> extensions = <String, ExtensionRuntime>{}.obs;
  RxMap<String, String> errors = <String, String>{}.obs;
  RxBool isInstallloading = false.obs;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() async {
    extensions.clear();
    errors.clear();
    extensions.addAll(ExtensionUtils.extensions);
    errors.addAll(ExtensionUtils.extensionErrorMap);
  }
}
