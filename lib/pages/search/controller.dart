import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class SearchPageController extends GetxController {
  Rx<ExtensionType?> cuurentExtensionType = Rx(null);
  final search = ''.obs;
  final searchResultList = <SearchResult>[].obs;
  String _randomKey = "";

  @override
  void onInit() {
    getRuntime();
    ever(search, (callback) => getRuntime());
    super.onInit();
  }

  getRuntime({ExtensionType? type}) {
    _randomKey = DateTime.now().millisecondsSinceEpoch.toString();
    cuurentExtensionType.value = type;
    final exts = ExtensionUtils.extensions.values.toList();
    if (type != null) {
      exts.removeWhere((element) => element.extension.type != type);
    }
    searchResultList.clear();
    for (var element in exts) {
      searchResultList.add(SearchResult(runitme: element));
    }
    getResult(_randomKey);
  }

  Future<void> getResult(String key) async {
    final futures = <Future>[];

    for (var i = 0; i < searchResultList.length; i++) {
      final element = searchResultList[i];
      Future<List<ExtensionListItem>> resultFuture;

      if (search.value == "") {
        resultFuture = element.runitme.latest(1);
      } else {
        resultFuture = element.runitme.search(search.value, 1);
      }

      futures.add(resultFuture.then((result) {
        if (_randomKey != key) {
          return;
        }
        element.result = result;
        if (result.isNotEmpty) {
          searchResultList.removeAt(i);
          searchResultList.insert(0, element);
        }
      }).catchError((e) {
        element.error = e.toString();
      }));
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
  SearchResult({
    required this.runitme,
    this.error,
    this.result,
  });
}
