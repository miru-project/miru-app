import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class SearchPageController extends GetxController {
  final RxList<ExtensionRuntime> runtimeList = <ExtensionRuntime>[].obs;
  final RxInt selectIndex = (-1).obs;
  final RxString search = ''.obs;
  ExtensionRuntime get cuurentRuntime => runtimeList[selectIndex.value];

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() {
    final exts = ExtensionUtils.extensions.values.where(
      (element) => element.extension.type == ExtensionType.bangumi,
    );
    if (selectIndex >= exts.length) {
      selectIndex.value = -1;
    }
    runtimeList.clear();
    runtimeList.addAll(exts);
  }
}
