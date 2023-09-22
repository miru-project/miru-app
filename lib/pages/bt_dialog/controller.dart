import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/main/controller.dart';
import 'package:miru_app/utils/bt_server.dart';
import 'package:miru_app/widgets/messenger.dart';

class BTDialogController extends GetxController {
  final isInstalled = false.obs;
  final isDownloading = false.obs;
  final progress = 0.0.obs;
  final hasUpdate = false.obs;
  final remoteVersion = "".obs;

  final _mainController = Get.find<MainController>();
  late final isRuning = _mainController.btServerisRunning;
  late final version = _mainController.btServerVersion;

  @override
  void onInit() {
    super.onInit();
    ever(
      isRuning,
      (callback) {
        hasUpdate.value = version.value != remoteVersion.value;
      },
    );
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      isInstalled.value = await BTServerUtils.isInstalled();
      remoteVersion.value = await BTServerUtils.getRemoteVersion();
    });
  }

  downloadOrUpgradeServer(BuildContext context) async {
    progress.value = 0;
    BTServerUtils.stopServer();
    isInstalled.value = false;
    isDownloading.value = true;
    try {
      await BTServerUtils.downloadLatestBTServer(
        onReceiveProgress: (p0, p1) {
          progress.value = p0 / p1;
        },
      );
    } catch (e) {
      context.mounted &&
          showPlatformSnackbar(
            context: context,
            content: e.toString(),
            severity: fluent.InfoBarSeverity.error,
          );
    } finally {
      isDownloading.value = false;
    }
    isInstalled.value = await BTServerUtils.isInstalled();
  }
}
