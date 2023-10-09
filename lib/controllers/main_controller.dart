import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/bt_server.dart';

// 全局 Controller
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

  @override
  void onReady() {
    super.onReady();
    SchedulerBinding.instance.addPersistentFrameCallback((_) async {
      // 判断 bt_server 是否已经安装
      final isInstalled = await BTServerUtils.isInstalled();
      if (isInstalled) {
        BTServerUtils.checkServer();
      }
    });
  }

  final btServerVersion = "".obs;
  final btServerisRunning = false.obs;
}
