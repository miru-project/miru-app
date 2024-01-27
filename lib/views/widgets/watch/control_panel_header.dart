import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:miru_app/views/widgets/watch/playlist.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:window_manager/window_manager.dart';

class ControlPanelHeader<T extends ReaderController> extends StatefulWidget {
  const ControlPanelHeader(
    this.tag, {
    super.key,
    required this.buildSettings,
  });
  final String tag;
  final Widget Function(BuildContext context) buildSettings;

  @override
  State<ControlPanelHeader> createState() => _ControlPanelHeaderState<T>();
}

class _ControlPanelHeaderState<T extends ReaderController>
    extends State<ControlPanelHeader> {
  late final _c = Get.find<T>(tag: widget.tag);
  final fluent.FlyoutController _playListFlayoutcontroller =
      fluent.FlyoutController();
  final fluent.FlyoutController _settingFlayoutcontroller =
      fluent.FlyoutController();

  Widget _buildAndroid(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 60,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: AppBar(
          title: Text(_c.title),
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => DraggableScrollableSheet(
                    expand: false,
                    builder: (context, controller) => SingleChildScrollView(
                        controller: controller,
                        child: widget.buildSettings(context)),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Obx(
                      () => PlayList(
                        title: _c.title,
                        list: _c.playList.map((e) => e.name).toList(),
                        selectIndex: _c.index.value,
                        onChange: (value) {
                          _c.index.value = value;
                          Get.back();
                        },
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.list),
            ),
          ],
        ),
      ),
    ).animate().fade();
  }

  Widget _buildDesktop(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    debugPrint(route ?? '');
    return MouseRegion(
        onHover: (details) {
          // _c.setControllPanel.value = true;
        },
        child: Obx(
          () => fluent.Column(children: [
            Container(
              width: double.infinity,
              height: 40,
              color: fluent.FluentTheme.of(context).micaBackgroundColor,
              padding: const EdgeInsets.only(left: 16),
              child: DragToMoveArea(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    fluent.IconButton(
                      icon: const Icon(fluent.FluentIcons.back),
                      onPressed: () {
                        RouterUtils.pop();
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(_c.title + _c.playList[_c.index.value].name),
                    const Spacer(),
                    fluent.FlyoutTarget(
                      controller: _settingFlayoutcontroller,
                      child: fluent.IconButton(
                        icon: const Icon(fluent.FluentIcons.settings),
                        onPressed: () {
                          _settingFlayoutcontroller.showFlyout(
                              builder: (context) {
                            return widget.buildSettings(context);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    fluent.FlyoutTarget(
                      controller: _playListFlayoutcontroller,
                      child: fluent.IconButton(
                        icon: const Icon(fluent.FluentIcons.collapse_menu),
                        onPressed: () {
                          _playListFlayoutcontroller.showFlyout(
                              builder: (context) {
                            return SizedBox(
                              width: 300,
                              child: Obx(
                                () => PlayList(
                                  title: _c.title,
                                  list: _c.playList.map((e) => e.name).toList(),
                                  selectIndex: _c.index.value,
                                  onChange: (value) {
                                    _c.index.value = value;
                                    router.pop();
                                  },
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 138,
                      child: WindowCaption(
                        backgroundColor: Colors.transparent,
                        brightness: fluent.FluentTheme.of(context).brightness,
                      ),
                    )
                  ],
                ),
              ),
            ),
            fluent.Container(
                height: 40,
                color: fluent.FluentTheme.of(context).micaBackgroundColor,
                // child: Row(
                //   children: [
                //     commandBaruilder(fluent.IconButton(
                //       icon: const Icon(
                //         fluent.FluentIcons.chevron_left,
                //         // size: 30,
                //       ),
                //       onPressed: () {},
                //     ))
                //   ],
                // )
                child: Obx(() => fluent.CommandBar(
                      primaryItems: <fluent.CommandBarItem>[
                        fluent.CommandBarButton(
                          icon: const Icon(fluent.FluentIcons.add),
                          label: SizedBox(
                              width: 100,
                              child: fluent.NumberBox(
                                mode: fluent.SpinButtonPlacementMode.none,
                                value: _c.progress.value + 1,
                                onChanged: (value) {
                                  if (value != null) {
                                    _c.progress.value = value - 1;
                                  }
                                },
                              )),
                          onPressed: null,
                        ),
                        fluent.CommandBarBuilderItem(
                          builder: (context, mode, w) => Tooltip(
                            message: "Create something new!",
                            child: w,
                          ),
                          wrappedItem: fluent.CommandBarButton(
                            icon: const Icon(fluent.FluentIcons.add),
                            label: const Text('New'),
                            onPressed: () {},
                          ),
                        ),
                        fluent.CommandBarBuilderItem(
                          builder: (context, mode, w) => Tooltip(
                            message: "Delete what is currently selected!",
                            child: w,
                          ),
                          wrappedItem: fluent.CommandBarButton(
                            icon: const Icon(fluent.FluentIcons.delete),
                            label: const Text('Delete'),
                            onPressed: () {},
                          ),
                        ),
                        fluent.CommandBarButton(
                          icon: const Icon(fluent.FluentIcons.archive),
                          label: const Text('Archive'),
                          onPressed: () {},
                        ),
                        fluent.CommandBarButton(
                          icon: const Icon(fluent.FluentIcons.move),
                          label: const Text('Move'),
                          onPressed: () {},
                        ),
                        fluent.CommandBarBuilderItem(
                          builder: (context, displayMode, widget) =>
                              fluent.NumberBox(
                            value: 1,
                            onChanged: null,
                          ),
                          wrappedItem: fluent.CommandBarButton(
                            icon: const Icon(fluent.FluentIcons.add),
                            label: const Text('New'),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    )))
          ]).animate().fade(),
        ));
  }

  Widget commandBaruilder(child) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
