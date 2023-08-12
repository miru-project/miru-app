import 'package:get/get.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class ExtensionPageController extends GetxController {
  RxMap<String, ExtensionRuntime> runtimes = <String, ExtensionRuntime>{}.obs;
  RxMap<String, String> errors = <String, String>{}.obs;
  RxBool isInstallloading = false.obs;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() async {
    runtimes.clear();
    errors.clear();
    runtimes.addAll(ExtensionUtils.runtimes);
    errors.addAll(ExtensionUtils.extensionErrorMap);
  }
}
