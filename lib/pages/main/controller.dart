import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final selectedTab = 0.obs;

  void changeTab(int i) {
    selectedTab.value = i;
  }

  List<Widget> actions = <Widget>[].obs;

  setAcitons(List<Widget> list) async {
    await Future.delayed(const Duration(milliseconds: 1));
    actions.clear();
    actions.addAll(list);
  }
}
