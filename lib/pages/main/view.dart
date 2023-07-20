import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app/pages/extension/view.dart';
import 'package:miru_app/pages/home/view.dart';
import 'package:miru_app/pages/main/controller.dart';
import 'package:miru_app/pages/search/view.dart';
import 'package:miru_app/pages/settings/view.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:window_manager/window_manager.dart';

class DesktopMainPage extends StatefulWidget {
  const DesktopMainPage({
    Key? key,
    required this.child,
    required this.shellContext,
    required this.state,
  }) : super(key: key);

  final Widget child;
  final BuildContext? shellContext;
  final GoRouterState state;

  @override
  State<DesktopMainPage> createState() => _DesktopMainPageState();
}

class _DesktopMainPageState extends State<DesktopMainPage> {
  late MainController c;

  @override
  void initState() {
    c = Get.put(MainController());
    if (MiruStorage.getSetting(SettingKey.autoCheckUpdate)) {
      c.checkUpdate(context);
    }
    super.initState();
  }

  Widget _title() {
    return const DragToMoveArea(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          'Miru',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => fluent.NavigationView(
          appBar: fluent.NavigationAppBar(
            leading: () {
              return fluent.IconButton(
                icon: const Icon(fluent.FluentIcons.back, size: 12.0),
                onPressed: () {
                  if (router.canPop()) {
                    context.pop();
                    setState(() {});
                  }
                },
              );
            }(),
            title: _title(),
            actions: SizedBox(
              width: 138,
              height: 50,
              child: WindowCaption(
                backgroundColor: Colors.transparent,
                brightness: fluent.FluentTheme.of(context).brightness,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          paneBodyBuilder: (item, body) {
            return widget.child;
          },
          pane: fluent.NavigationPane(
            size: const fluent.NavigationPaneSize(openMaxWidth: 200),
            selected: c.selectedTab.value,
            onChanged: c.changeTab,
            displayMode: fluent.PaneDisplayMode.compact,
            footerItems: [
              fluent.PaneItemSeparator(),
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.repo),
                title: Text('common.extension-repo'.i18n),
                body: const ExtensionPage(),
                onTap: () {
                  router.go('/extension_repo');
                },
              ),
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.settings),
                title: Text('common.settings'.i18n),
                body: const SettingsPage(),
                onTap: () {
                  router.go('/settings');
                },
              ),
            ],
            items: [
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.home),
                title: Text('common.home'.i18n),
                body: const HomePage(),
                onTap: () {
                  router.go('/');
                },
              ),
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.search),
                title: Text('common.search'.i18n),
                body: const SearchPage(),
                onTap: () {
                  router.go('/search');
                },
              ),
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.add_in),
                title: Text('common.extension'.i18n),
                body: const ExtensionPage(),
                onTap: () {
                  router.go('/extension');
                },
              ),
            ],
          ),
        ));
  }
}

class AndroidMainPage extends fluent.StatefulWidget {
  const AndroidMainPage({Key? key}) : super(key: key);

  @override
  fluent.State<AndroidMainPage> createState() => _AndroidMainPageState();
}

class _AndroidMainPageState extends fluent.State<AndroidMainPage> {
  late MainController c;
  final pages = const [
    HomePage(),
    SearchPage(),
    ExtensionPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    c = Get.put(MainController());
    if (MiruStorage.getSetting(SettingKey.autoCheckUpdate)) {
      c.checkUpdate(context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: pages[c.selectedTab.value],
          bottomNavigationBar: NavigationBar(
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: "common.home".i18n,
              ),
              NavigationDestination(
                icon: const Icon(Icons.search_outlined),
                label: "common.search".i18n,
                selectedIcon: const Icon(Icons.search),
              ),
              NavigationDestination(
                icon: const Icon(Icons.apps_outlined),
                label: "common.extension".i18n,
                selectedIcon: const Icon(Icons.apps),
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                label: "common.settings".i18n,
                selectedIcon: const Icon(Icons.settings),
              ),
            ],
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            selectedIndex: c.selectedTab.value,
            onDestinationSelected: c.changeTab,
          ),
        ));
  }
}
