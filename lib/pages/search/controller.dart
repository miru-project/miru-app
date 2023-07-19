import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class SearchPageController extends GetxController {
  final RxList<ExtensionRuntime> runtimeList = <ExtensionRuntime>[].obs;

  final RxString search = ''.obs;

  Rx<ExtensionType?> cuurentExtensionType = Rx(null);

  @override
  void onInit() {
    getRuntime();
    super.onInit();
  }

  getRuntime({ExtensionType? type}) {
    cuurentExtensionType.value = type;
    final exts = ExtensionUtils.extensions.values.toList();
    if (type != null) {
      exts.removeWhere((element) => element.extension.type != type);
    }
    runtimeList.clear();
    runtimeList.addAll(exts);
  }
}
