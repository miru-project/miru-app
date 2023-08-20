import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final selectedTab = 0.obs;

  void changeTab(int i) {
    selectedTab.value = i;
  }

  List<Widget> actions = <Widget>[].obs;

  setAcitons(List<Widget> list) async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      actions.clear();
      actions.addAll(list);
    });
  }
}
