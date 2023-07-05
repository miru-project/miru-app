import 'package:get/get.dart';

class MainController extends GetxController {
  final selectedTab = 0.obs;

  void changeTab(int i) {
    selectedTab.value = i;
  }
}
