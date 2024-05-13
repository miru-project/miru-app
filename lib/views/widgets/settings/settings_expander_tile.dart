import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:get/get.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/settings/settings_tile.dart';

class SettingsExpanderTile extends StatelessWidget {
  const SettingsExpanderTile({
    super.key,
    this.icon,
    this.androidIcon,
    this.leading,
    required this.content,
    required this.title,
    required this.subTitle,
    this.open = false,
    this.noPage = false,
  });
  final IconData? icon;
  final IconData? androidIcon;
  final Widget? leading;
  final String title;
  final String subTitle;
  final bool open;
  final Widget content;
  // 不使用二级页面
  final bool noPage;

  Widget _buildMobile(BuildContext context) {
    if (noPage) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(
              subTitle,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 15),
            content,
          ],
        ),
      );
    }

    Widget iconWidget = androidIcon != null
        ? Icon(androidIcon, size: 24)
        : icon != null
            ? Icon(icon, size: 24)
            : leading!;

    return SettingsTile(
      icon: iconWidget,
      title: title,
      buildSubtitle: () => subTitle,
      onTap: () {
        Get.to(
          () => Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: content,
          ),
        );
      },
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.Expander(
      initiallyExpanded: open,
      leading: icon != null ? Icon(icon, size: 24) : leading,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(title),
          const SizedBox(height: 2),
          Text(
            subTitle,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 15)
        ],
      ),
      content: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
