import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/miru_storage.dart';

class SearchPageController extends GetxController {
  Rx<ExtensionType?> cuurentExtensionType = Rx(null);
  final search = ''.obs;
  final searchResultList = <SearchResult>[].obs;
  String _randomKey = "";
  int get finishCount =>
      searchResultList.where((element) => element.completed).length;
  bool needRefresh = true;

  @override
  void onInit() {
    ever(search, (callback) {
      _randomKey = DateTime.now().millisecondsSinceEpoch.toString();
      getResult(_randomKey);
    });
    super.onInit();
  }

  getRuntime({ExtensionType? type}) {
    _randomKey = DateTime.now().millisecondsSinceEpoch.toString();
    cuurentExtensionType.value = type;
    final exts = ExtensionUtils.runtimes.values.toList();
    if (type != null) {
      exts.removeWhere((element) => element.extension.type != type);
    }
    if (!MiruStorage.getSetting(SettingKey.enableNSFW)) {
      exts.removeWhere((element) => element.extension.nsfw);
    }
    searchResultList.clear();
    for (var element in exts) {
      searchResultList.add(SearchResult(runitme: element));
    }
    getResult(_randomKey);
    needRefresh = false;
  }

  Future<void> getResult(String key) async {
    final futures = <Future>[];
    for (var i = 0; i < searchResultList.length; i++) {
      final element = searchResultList[i];
      element.completed = false;
      element.result = null;
      element.error = null;
      Future<List<ExtensionListItem>> resultFuture;

      if (search.value.isEmpty) {
        resultFuture = element.runitme.latest(1);
      } else {
        resultFuture = element.runitme.search(search.value, 1);
      }

      futures.add(
        resultFuture.then((result) {
          if (_randomKey != key) {
            return;
          }
          element.result = result;
          if (result.isNotEmpty) {
            searchResultList.remove(element);
            searchResultList.insert(0, element);
          }
        }).catchError((e) {
          element.error = e.toString();
        }).whenComplete(() {
          element.completed = true;
        }),
      );
    }

    await Future.wait(futures);
  }

  getPackgeByIndex(int index) {
    return searchResultList[index].runitme.extension.package;
  }
}

class SearchResult {
  final ExtensionRuntime runitme;
  List<ExtensionListItem>? result;
  String? error;
  bool completed;
  SearchResult({
    required this.runitme,
    this.error,
    this.result,
    this.completed = false,
  });
}
