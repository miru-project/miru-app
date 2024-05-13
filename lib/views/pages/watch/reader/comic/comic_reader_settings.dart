import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/comic_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class ComicReaderSettings extends StatefulWidget {
  const ComicReaderSettings(this.tag, {super.key});
  final String tag;

  @override
  State<ComicReaderSettings> createState() => _ComicReaderSettingsState();
}

class _ComicReaderSettingsState extends State<ComicReaderSettings> {
  late final ComicController _c = Get.find<ComicController>(tag: widget.tag);

  Widget _buildMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 阅读模式
          Text('comic-settings.read-mode'.i18n),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton(
              segments: [
                ButtonSegment<MangaReadMode>(
                  value: MangaReadMode.standard,
                  label: Text('comic-settings.standard'.i18n),
                ),
                ButtonSegment<MangaReadMode>(
                  value: MangaReadMode.rightToLeft,
                  label: Text('comic-settings.right-to-left'.i18n),
                ),
                ButtonSegment<MangaReadMode>(
                  value: MangaReadMode.webTonn,
                  label: Text('comic-settings.web-tonn'.i18n),
                ),
              ],
              selected: <MangaReadMode>{_c.readType.value},
              onSelectionChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _c.readType.value = value.first;
                  });
                }
              },
              showSelectedIcon: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Obx(() {
      return fluent.Card(
        backgroundColor: fluent.FluentTheme.of(context).micaBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('comic-settings.read-mode'.i18n),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.ToggleButton(
                  checked: _c.readType.value == MangaReadMode.standard,
                  onChanged: (value) {
                    if (value) {
                      setState(() {
                        _c.readType.value = MangaReadMode.standard;
                      });
                    }
                  },
                  child: Text('comic-settings.standard'.i18n),
                ),
                const SizedBox(width: 8),
                fluent.ToggleButton(
                  checked: _c.readType.value == MangaReadMode.rightToLeft,
                  onChanged: (value) {
                    if (value) {
                      setState(() {
                        _c.readType.value = MangaReadMode.rightToLeft;
                      });
                    }
                  },
                  child: Text('comic-settings.right-to-left'.i18n),
                ),
                const SizedBox(width: 8),
                fluent.ToggleButton(
                  checked: _c.readType.value == MangaReadMode.webTonn,
                  onChanged: (value) {
                    if (value) {
                      setState(() {
                        _c.readType.value = MangaReadMode.webTonn;
                      });
                    }
                  },
                  child: Text('comic-settings.web-tonn'.i18n),
                )
              ],
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
