import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/utils/miru_storage.dart';

class SearchPageController extends GetxController {
  Rx<ExtensionType?> cuurentExtensionType = Rx(null);
  final search = ''.obs;
  final searchResultList = <SearchResult>[].obs;
  String _randomKey = "";
  int get finishCount =>
      searchResultList.where((element) => element.completed).length;
  bool needRefresh = true;
  bool isPageOpen = false;
  // 是否打开了这个页面

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
    // 最后一个有结果的搜索结果索引
    var lastResultIndex = -1;
    for (var i = 0; i < searchResultList.length; i++) {
      final element = searchResultList[i];
      element.completed = false;
      element.result = null;
      element.error = null;
      Future<List<ExtensionListItem>> resultFuture;

      if (search.value.isEmpty) {
        resultFuture = element.runitme.latest(1, currentContext);
      } else {
        resultFuture = element.runitme.search(search.value, 1, currentContext);
      }

      futures.add(
        resultFuture.then((result) {
          if (_randomKey != key) {
            return;
          }
          element.result = result;
          // 如果搜索结果不为空,
          if (result.isNotEmpty) {
            searchResultList.remove(element);
            // 判断是否是第一个,将第一个放到最前面
            if (lastResultIndex == -1) {
              searchResultList.insert(0, element);
              lastResultIndex = 0;
            } else {
              searchResultList.insert(lastResultIndex + 1, element);
              lastResultIndex++;
            }
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

  callRefresh() {
    if (isPageOpen) {
      getRuntime();
    } else {
      needRefresh = true;
    }
  }
}

class SearchResult {
  final ExtensionService runitme;
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
