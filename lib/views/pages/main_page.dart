import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app/views/pages/extension/extension_page.dart';
import 'package:miru_app/views/pages/home_page.dart';
import 'package:miru_app/controllers/main_controller.dart';
import 'package:miru_app/views/pages/search/search_page.dart';
import 'package:miru_app/views/pages/settings/settings_page.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/application.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/layout.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:window_manager/window_manager.dart';

class DesktopMainPage extends StatefulWidget {
  const DesktopMainPage({
    super.key,
    required this.child,
    required this.shellContext,
    required this.state,
  });

  final Widget child;
  final BuildContext? shellContext;
  final GoRouterState state;

  @override
  State<DesktopMainPage> createState() => _DesktopMainPageState();
}

class _DesktopMainPageState extends State<DesktopMainPage> with WindowListener {
  late MainController c;

  @override
  void initState() {
    c = Get.put(MainController());
    if (MiruStorage.getSetting(SettingKey.autoCheckUpdate)) {
      ApplicationUtils.checkUpdate(context);
    }
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
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
    return fluent.NavigationView(
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
        actions: Obx(
          () => Row(
            children: [
              const Spacer(),
              ...c.actions,
              SizedBox(
                width: 138,
                height: 50,
                child: WindowCaption(
                  backgroundColor: Colors.transparent,
                  brightness: fluent.FluentTheme.of(context).brightness,
                ),
              )
            ],
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
    );
  }

  @override
  void onWindowResize() {
    WindowManager.instance.getSize().then((value) {
      MiruStorage.setSetting(
        SettingKey.windowSize,
        "${value.width},${value.height}",
      );
    });
  }

  @override
  void onWindowMove() {
    WindowManager.instance.getPosition().then((value) {
      MiruStorage.setSetting(
        SettingKey.windowPosition,
        "${value.dx},${value.dy}",
      );
    });
  }
}

class AndroidMainPage extends fluent.StatefulWidget {
  const AndroidMainPage({super.key});

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
      ApplicationUtils.checkUpdate(context);
    }
    if (!LayoutUtils.isTablet){
      SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<_Destination> destinations = <_Destination>[
      _Destination(Icons.home_outlined, Icons.home, 'common.home'.i18n),
      _Destination(Icons.search_outlined, Icons.search, 'common.search'.i18n),
      _Destination(
          Icons.extension_outlined, Icons.extension, 'common.extension'.i18n),
      _Destination(
          Icons.settings_outlined, Icons.settings, 'common.settings'.i18n),
    ];
    return Obx(
      () => Scaffold(
        body: LayoutUtils.isTablet
            ? Row(
                children: [
                  NavigationRail(
                    groupAlignment: 0,
                    labelType: NavigationRailLabelType.all,
                    destinations: destinations
                        .map((e) => NavigationRailDestination(
                              icon: Icon(e.icon),
                              selectedIcon: Icon(e.selectedIcon),
                              label: Text(e.label),
                            ))
                        .toList(),
                    selectedIndex: c.selectedTab.value,
                    onDestinationSelected: c.changeTab,
                  ),
                  Expanded(child: pages[c.selectedTab.value])
                ],
              )
            : pages[c.selectedTab.value],
        bottomNavigationBar: LayoutUtils.isTablet
            ? null
            : NavigationBar(
                destinations: destinations
                    .map((e) => NavigationDestination(
                          icon: Icon(e.icon),
                          selectedIcon: Icon(e.selectedIcon),
                          label: e.label,
                        ))
                    .toList(),
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                selectedIndex: c.selectedTab.value,
                onDestinationSelected: c.changeTab,
              ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label);
  final IconData selectedIcon;
  final IconData icon;
  final String label;
}
