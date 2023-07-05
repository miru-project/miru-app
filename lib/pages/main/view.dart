import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app/main.dart';
import 'package:miru_app/pages/extension/view.dart';
import 'package:miru_app/pages/home/view.dart';
import 'package:miru_app/pages/main/controller.dart';
import 'package:miru_app/pages/search/view.dart';
import 'package:miru_app/pages/settings/view.dart';
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
            actions: const SizedBox(
              width: 138,
              height: 50,
              child: WindowCaption(),
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
            displayMode: fluent.PaneDisplayMode.open,
            footerItems: [
              fluent.PaneItemSeparator(),
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.repo),
                title: const Text('扩展仓库'),
                body: const ExtensionPage(),
                onTap: () {
                  router.go('/extension_repo');
                },
              ),
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.settings),
                title: const Text('设置'),
                body: const SettingsPage(),
                onTap: () {
                  router.go('/settings');
                },
              ),
            ],
            items: [
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.home),
                title: const Text('首页'),
                body: const HomePage(),
                onTap: () {
                  router.go('/');
                },
              ),
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.search),
                title: const Text('搜索'),
                body: const SearchPage(),
                onTap: () {
                  router.go('/search');
                },
              ),
              fluent.PaneItem(
                icon: const Icon(fluent.FluentIcons.add_in),
                title: const Text('扩展'),
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
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: "首页",
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                label: "探索",
                selectedIcon: Icon(Icons.search),
              ),
              NavigationDestination(
                icon: Icon(Icons.apps_outlined),
                label: "扩展",
                selectedIcon: Icon(Icons.apps),
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: "设置",
                selectedIcon: Icon(Icons.settings),
              ),
            ],
            selectedIndex: c.selectedTab.value,
            onDestinationSelected: c.changeTab,
          ),
        ));
  }
}
