import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:go_router/go_router.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:flutter/services.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorPageDesktop extends StatefulWidget {
  const ErrorPageDesktop({super.key});
  @override
  State<ErrorPageDesktop> createState() => _ErrorPageDesktopState();
}

class _ErrorPageDesktopState extends State<ErrorPageDesktop> {
  final issueUrl = Uri.parse("https://github.com/miru-project/miru-app/issues");

  final List errorMessage = MiruStorage.getSetting(SettingKey.errorMessage);
  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      bottomSheet: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              FilledButton(
                  onPressed: () async {
                    MiruStorage.setSetting(SettingKey.errorMessage, []);
                    Clipboard.setData(ClipboardData(
                        text: errorMessage
                            .map((map) => map.entries
                                .map((e) => '${e.key}:${e.value}')
                                .join('\n'))
                            .join('\n')));
                    showPlatformSnackbar(
                        context: context, content: "report.copied".i18n);
                    if (await canLaunchUrl(issueUrl)) {
                      await launchUrl(issueUrl);
                    } else {
                      throw 'failed to launch $issueUrl';
                    }
                    Get.back();
                  },
                  child: Text("report.github-bug-report".i18n)),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text: errorMessage
                            .map((map) => map["exception"])
                            .join('\n')));
                    showPlatformSnackbar(
                        context: context, content: "report.copied".i18n);
                  },
                  child: Text("report.copy-message".i18n)),
              ElevatedButton(
                  onPressed: () async {
                    MiruStorage.setSetting(SettingKey.errorMessage, []);
                    Get.back();
                  },
                  child: Text("common.close".i18n)),
            ])
          ])),
      appBar: AppBar(
        title: Text('report.title'.i18n),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                  itemCount: errorMessage.length,
                  itemBuilder: (context, index) {
                    return Card(
                        child: ListTile(
                      trailing: Text(errorMessage[index]["time"].toString()),
                      isThreeLine: true,
                      title:
                          Text("Context : ${errorMessage[index]["context"]}"),
                      subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Exception : ${errorMessage[index]["exception"]}"),
                            Text("${errorMessage[index]["stackTrace"]}")
                          ]),
                    ));
                  }),
            ),
          ])),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.ScaffoldPage(
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // const SizedBox(height: 4),
            Row(children: [
              const SizedBox(
                width: 8,
              ),
              Text(
                'report.title'.i18n,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ]),
            const SizedBox(height: 10),
            Expanded(
                child: fluent.ListView.builder(
                    itemCount: errorMessage.length,
                    itemBuilder: (context, index) {
                      return Column(children: [
                        fluent.Card(
                            child: fluent.ListTile(
                          title: Text(
                              "Context : ${errorMessage[index]["context"]}"),
                          subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Exception : ${errorMessage[index]["exception"]}"),
                                Text("${errorMessage[index]["stackTrace"]}"),
                              ]),
                        )),
                        const SizedBox(height: 8)
                      ]);
                    }))
          ]),
      bottomBar: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              // const Spacer(),
              fluent.FilledButton(
                child: Text("report.github-bug-report".i18n),
                onPressed: () async {
                  MiruStorage.setSetting(SettingKey.errorMessage, []);
                  Clipboard.setData(ClipboardData(
                      text: errorMessage
                          .map((map) => map.entries
                              .map((e) => '${e.key}:${e.value}')
                              .join('\n'))
                          .join('\n')));
                  showPlatformSnackbar(
                      context: context, content: "report.copied".i18n);
                  if (await canLaunchUrl(issueUrl)) {
                    await launchUrl(issueUrl);
                  } else {
                    throw 'failed to launch $issueUrl';
                  }
                  if (!context.mounted) return;
                  context.go("/");
                },
              ),
              // const Spacer(),
              fluent.Button(
                child: Text("report.copy-message".i18n),
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text: errorMessage
                          .map((map) => map["exception"])
                          .join('\n')));
                  showPlatformSnackbar(
                      context: context, content: "report.copied".i18n);
                },
              ),
              // const Spacer(),
              fluent.Button(
                child: Text("common.close".i18n),
                onPressed: () {
                  MiruStorage.setSetting(SettingKey.errorMessage, []);
                  if (!context.mounted) return;
                  context.go("/");
                },
              )
            ]),
            const SizedBox(
              height: 10,
            )
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
        androidWidget: _buildAndroid(context),
        desktopWidget: _buildDesktop(context));
  }
}
