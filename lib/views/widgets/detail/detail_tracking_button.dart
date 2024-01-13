import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/views/dialogs/anilist_binding_dialog.dart';
import 'package:miru_app/views/dialogs/anilist_tracking_dialog.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class DetailTrackingButton extends StatefulWidget {
  const DetailTrackingButton({
    super.key,
    required this.tag,
  });
  final String? tag;

  @override
  State<DetailTrackingButton> createState() => _DetailTrackingButtonState();
}

class _DetailTrackingButtonState extends State<DetailTrackingButton> {
  late final c = Get.find<DetailPageController>(tag: widget.tag);
  final anlistExtensionMap = <ExtensionType, AnilistType>{
    ExtensionType.bangumi: AnilistType.anime,
    ExtensionType.manga: AnilistType.manga,
  };

  _showTrackingDialog() async {
    if (c.aniListID.value.isEmpty) {
      dynamic data;
      if (Platform.isAndroid) {
        data = await Get.to(
          AnilistBindingDialog(
            title: c.detail!.title,
            type: AnilistType.anime,
          ),
        );
      } else {
        data = await fluent.showDialog(
          context: currentContext,
          builder: (context) => AnilistBindingDialog(
            title: c.detail!.title,
            type: AnilistType.anime,
          ),
        );
      }
      if (data == null) {
        return;
      }
      final mediaID = data["id"].toString();
      c.aniListID.value = mediaID;
      c.saveAniListIds();
    }

    debugPrint("Anilist ID: ${c.aniListID.value}");

    if (!mounted) {
      return;
    }

    if (Platform.isAndroid) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        constraints: const BoxConstraints(maxWidth: 640),
        builder: (context) => AnilistTrackingDialog(
          anilistType: anlistExtensionMap[c.extension?.type]!,
          tag: widget.tag,
        ),
      );
      return;
    }

    fluent.showDialog(
      context: context,
      builder: (context) => AnilistTrackingDialog(
        anilistType: anlistExtensionMap[c.extension?.type]!,
        tag: widget.tag,
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return _buildShow(
      IconButton(
        onPressed: () {
          _showTrackingDialog();
        },
        icon: const Icon(Icons.sync),
      ),
    );
  }

  Widget _buildDeskltop(BuildContext context) {
    return _buildShow(
      fluent.Button(
        child: const Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Tracking"),
              SizedBox(width: 8),
              Icon(fluent.FluentIcons.sync)
            ],
          ),
        ),
        onPressed: () {
          _showTrackingDialog();
        },
      ),
    );
  }

  Widget _buildShow(Widget widget) {
    if (anlistExtensionMap.containsKey(c.extension?.type) ||
        AniListProvider.anilistToken != "") {
      return widget;
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDeskltop,
    );
  }
}
