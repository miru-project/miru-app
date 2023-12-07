// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

late PackageInfo packageInfo;
late AndroidDeviceInfo androidDeviceInfo;
late WindowsDeviceInfo windowsDeviceInfo;

class ApplicationUtils {
  static Future ensureInitialized() async {
    packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfo.androidInfo;
    }
    if (Platform.isWindows) {
      windowsDeviceInfo = await deviceInfo.windowsInfo;
    }
    return packageInfo;
  }

  static checkUpdate(BuildContext context, {bool showSnackbar = false}) async {
    try {
      const url =
          "https://api.github.com/repos/miru-project/miru-app/releases/latest";
      final res = await Dio().get(url);
      final remoteVersion =
          (res.data["tag_name"] as String).replaceFirst('v', '');
      debugPrint('remoteVersion: $remoteVersion');
      if (packageInfo.version != remoteVersion) {
        if (Platform.isAndroid) {
          Get.to(
            Scaffold(
              appBar: AppBar(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    'upgrade.new-version',
                    translationParams: {
                      'version': remoteVersion,
                    },
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(child: Markdown(data: res.data['body'])),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PlatformFilledButton(
                        onPressed: () {
                          RouterUtils.pop();
                          launchUrl(
                            Uri.parse(res.data['html_url']),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text('upgrade.download'.i18n),
                      ),
                    )
                  ],
                ),
              ),
            ),
            transition: Transition.rightToLeftWithFade,
          );
          return;
        }

        showPlatformDialog(
          context: context,
          title: FlutterI18n.translate(
            context,
            'upgrade.new-version',
            translationParams: {
              'version': remoteVersion,
            },
          ),
          content: Markdown(
            shrinkWrap: true,
            data: res.data['body'],
          ),
          actions: [
            PlatformTextButton(
              onPressed: () {
                RouterUtils.pop();
              },
              child: Text('upgrade.not-now'.i18n),
            ),
            PlatformFilledButton(
              onPressed: () {
                RouterUtils.pop();
                launchUrl(
                  Uri.parse(res.data['html_url']),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Text('upgrade.download'.i18n),
            )
          ],
        );
      } else {
        if (!showSnackbar) {
          return;
        }
        showPlatformSnackbar(
          context: context,
          title: 'upgrade.check-update'.i18n,
          content: "upgrade.no-update".i18n,
        );
      }
    } catch (e) {
      if (!showSnackbar) {
        return;
      }
      showPlatformSnackbar(
        context: context,
        title: 'upgrade.check-update'.i18n,
        content: 'upgrade.error'.i18n,
      );
    }
  }

  static Future exportSaveFile(
    BuildContext context,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final archive = Archive();
    DateTime now = DateTime.now();
    //android backup function
    if (Platform.isAndroid) {
      bool result = await archivefiles([
        "${directory.path}/miru/default.isar",
        "${directory.path}/miru/settings.hive"
      ], "${directory.path}/miru-backup-${now.year}-${now.month}-${now.day}_${now.hour}:${now.minute}.zip",
          archive, ZipEncoder());
      if (result) {
        return showPlatformSnackbar(
          context: context,
          title: 'backup.export-success'.i18n,
          content: "backup.export-success".i18n,
        );
      }
      return showPlatformSnackbar(
        context: context,
        title: 'backup.export-failed'.i18n,
        content: "backup.export-failed".i18n,
      );
    }
    //desktop backup function
    else {
      String? folderPath = await FilePicker.platform
          .getDirectoryPath(dialogTitle: "backup.select-folder".i18n);
      if (folderPath == null) {
        return showPlatformSnackbar(
          context: context,
          title: 'backup.import-filePath-failed'.i18n,
          content: "backup.import-failed".i18n,
        );
      }
      bool result = await archivefiles([
        "${directory.path}/miru/default.isar",
        "${directory.path}/miru/settings.hive"
      ], "$folderPath\\miru-backup-${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}.zip",
          archive, ZipEncoder());
      if (result) {
        return showPlatformSnackbar(
          context: context,
          title: 'backup.export-success'.i18n,
          content: "backup.export-success".i18n,
        );
      }
      return showPlatformSnackbar(
        context: context,
        title: 'backup.export-failed'.i18n,
        content: "backup.export-failed".i18n,
      );
    }
  }

  static Future importSaveFile(
    BuildContext context,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    FilePickerResult? folderPath = await FilePicker.platform.pickFiles();
    if (folderPath == null) {
      return showPlatformSnackbar(
        context: context,
        title: 'backup.import-filePath-failed'.i18n,
        content: "backup.import-failed".i18n,
      );
    }
    debugPrint("${folderPath.files.single.path}");
    debugPrint("unZip: $directory");
    //clear database
    MiruStorage.deleteAll();
    final unZip = await unarchivefiles(
        folderPath.files.single.path!, "${directory.path}/miru", ZipDecoder());

    //unzip succeeded 解壓成功
    if (unZip == null) {
      return showPlatformSnackbar(
        context: context,
        title: 'backup.import-unzip-success'.i18n,
        content: "backup.import-unzip-success-sub".i18n,
      );
    }
    //unzip failed 解壓失敗
    return showPlatformSnackbar(
      context: context,
      title: 'backup.import-unzip-failed'.i18n,
      content: unZip,
    );
  }

  static Future<bool> copyFile(
      String sourcePath, String destinationPath) async {
    File sourceFile = File(sourcePath);
    File destinationFile = File(destinationPath);
    try {
      await sourceFile.copy(destinationFile.path);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<dynamic> unarchivefiles(
      String path, String targetPath, dynamic encoder) async {
    try {
      final bytes = await File(path).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          debugPrint("$path/$filename");
          File("$targetPath/$filename")
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('$path/$filename').create(recursive: true);
        }
      }
      return;
    } catch (e) {
      debugPrint("$e");
      return e;
    }
  }

  static Future<bool> archivefiles(List<String> paths, String targetPath,
      Archive archive, dynamic encoder) async {
    for (final path in paths) {
      final bytes = await File(path).readAsBytes();
      final fileName = File(path).path.split('/').last;
      final archiveFile = ArchiveFile(fileName, bytes.length, bytes);
      archive.addFile(archiveFile);
      debugPrint("${bytes.length}");
    }
    final output = encoder.encode(archive);
    if (output == null) {
      debugPrint("encode failed");
      return false;
    }
    if (Platform.isAndroid) {
      File(targetPath).writeAsBytesSync(output);
      await Share.shareXFiles(
        [XFile(targetPath)],
      );
      File(targetPath).delete();
      return true;
    }
    File(targetPath).writeAsBytesSync(output);
    debugPrint("$targetPath");
    //
    return true;
  }
}
