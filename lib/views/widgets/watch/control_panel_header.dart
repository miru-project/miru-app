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

  Widget _buildAndroid(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Container(
          height: 60,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: AppBar(
            title: Text(_c.title),
            actions: [
              IconButton(
                  onPressed: () {
                    _c.enableAutoScroll.value = !_c.enableAutoScroll.value;
                  },
                  icon: _c.enableAutoScroll.value
                      ? const Icon(Icons.stop_rounded)
                      : const Icon(Icons.play_arrow_rounded)),
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
                    isScrollControlled: true,
                    builder: (context) => DraggableScrollableSheet(
                        expand: false,
                        builder: (context, controller) {
                          return Obx(
                            () => PlayList(
                              title: _c.title,
                              list: _c.playList.map((e) => e.name).toList(),
                              selectIndex: _c.index.value,
                              scrollController: controller,
                              onChange: (value) {
                                _c.clearData();
                                _c.index.value = value;
                                _c.getContent();
                                Get.back();
                              },
                            ),
                          );
                        }),
                  );
                },
                icon: const Icon(Icons.list),
              ),
            ],
          ),
        ),
        Material(
            child: Obx(() => Row(children: [
                  const SizedBox(width: 30),
                  const Icon(Icons.brightness_medium_rounded),
                  Expanded(
                      child: Slider(
                    value: _c.brightness.value,
                    max: 1,
                    min: 0,
                    onChanged: (val) async {
                      _c.brightness.value = val;
                      await _c.setBrightness(val);
                    },
                  )),
                  const SizedBox(width: 30)
                ])))
      ]),
    ).animate().fade();
  }

  Widget _buildDesktop(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    debugPrint(route ?? '');
    return Obx(
      () => fluent.Column(children: [
        Container(
          width: double.infinity,
          height: 40,
          color: fluent.FluentTheme.of(context).micaBackgroundColor,
          padding: const EdgeInsets.only(left: 16),
          child: MouseRegion(
              onHover: (detail) {
                _c.setControllPanel.value = true;
              },
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
                    // const SizedBox(width: 8),
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
                                    _c.clearData();
                                    _c.index.value = value;
                                    _c.getContent();
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
              )),
        ),
        fluent.Container(
            height: 70,
            color: fluent.FluentTheme.of(context).micaBackgroundColor,
            child: widget.buildSettings(context)),
        //  Obx())
      ]).animate().fade(),
    );
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

  @override
  void dispose() {
    _playListFlayoutcontroller.dispose();
    super.dispose();
  }
}
