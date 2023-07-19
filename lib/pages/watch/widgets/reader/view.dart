import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/watch/widgets/reader/control_panel_footer.dart';
import 'package:miru_app/pages/watch/widgets/reader/control_panel_header.dart';
import 'package:miru_app/pages/watch/widgets/reader/controller.dart';

class ReadView<T> extends StatelessWidget {
  const ReadView(
    this.tag, {
    Key? key,
    required this.content,
    required this.buildSettings,
  }) : super(key: key);
  final String tag;
  final Widget content;
  final Widget Function(BuildContext context) buildSettings;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReaderController<T>>(tag: tag);
    return Obx(
      () => Stack(
        children: [
          MouseRegion(
            onHover: (event) {
              if (event.position.dy < 60) {
                c.showControlPanel();
              }
              if (event.position.dy > Get.height - 60) {
                c.showControlPanel();
              }
            },
            child: content,
          ),

          // 点击中间显示控制面板
          if (c.error.value.isEmpty)
            Positioned(
              top: 120,
              bottom: 120,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // 中间点击的话 将不会定时关闭
                  c.isShowControlPanel.value = !c.isShowControlPanel.value;
                },
              ),
            ),

          if (c.isShowControlPanel.value) ...[
            // 顶部控制
            Positioned(
              child: ControlPanelHeader<T>(
                tag,
                buildSettings: buildSettings,
              ),
            ),
            // 底部控制
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: ControlPanelFooter<T>(tag),
            ),
          ]
        ],
      ),
    );
  }
}
