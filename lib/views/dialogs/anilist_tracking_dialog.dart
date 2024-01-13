import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:miru_app/views/widgets/progress.dart';

class AnilistTrackingDialog extends StatefulWidget {
  const AnilistTrackingDialog({
    super.key,
    required this.anilistType,
    required this.tag,
  });
  final AnilistType anilistType;
  final String? tag;

  @override
  State<AnilistTrackingDialog> createState() => _AnilistTrackingDialogState();
}

class _AnilistTrackingDialogState extends State<AnilistTrackingDialog> {
  late final DetailPageController c = Get.find(tag: widget.tag);
  late final status = [
    "Current",
    "Completed",
    "Planning",
    "Dropped",
    "Paused",
    "Rewatching",
  ];

  // media list id
  int id = 0;

  String selectStatus = "CURRENT";
  int? episodes = 0;
  int? maxEpisodes = 0;
  double? score = 0;
  DateTime? startDate;
  DateTime? endDate;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    dynamic res;
    try {
      res = await AniListProvider.getMediaList(c.aniListID.value);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
    if (res == null) {
      return;
    }
    if (res['mediaListEntry'] != null) {
      final data = res['mediaListEntry'];
      setState(() {
        id = data["id"];
        selectStatus = data["status"];
        episodes = data["progress"];
        score = data["score"].toDouble();
        if (_dateIsNotNull(data["startedAt"])) {
          startDate = DateTime(
            data["startedAt"]["year"] ?? 0,
            data["startedAt"]["month"] ?? 0,
            data["startedAt"]["day"] ?? 0,
          );
        }
        if (_dateIsNotNull(data["completedAt"])) {
          endDate = DateTime(
            data["completedAt"]["year"] ?? 0,
            data["completedAt"]["month"] ?? 0,
            data["completedAt"]["day"] ?? 0,
          );
        }
      });
    }
    setState(() {
      maxEpisodes = res["episodes"];
    });
  }

  _dateIsNotNull(dynamic data) {
    if (data["year"] == null || data["month"] == null || data["day"] == null) {
      return false;
    }
    return true;
  }

  Widget _buildAndroidContent(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [],
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: ProgressRing(),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Status"),
        const SizedBox(height: 8),
        fluent.ComboBox<String>(
          value: selectStatus,
          items: [
            for (final child in status)
              fluent.ComboBoxItem(
                value: child.toUpperCase(),
                child: Text(child),
              ),
          ],
          onChanged: (value) {
            setState(() {
              selectStatus = value!;
            });
          },
        ),
        const SizedBox(height: 8),
        const Text("Episodes"),
        const SizedBox(height: 8),
        fluent.NumberBox(
          min: 0,
          max: maxEpisodes,
          value: episodes,
          onChanged: (value) {
            setState(() {
              episodes = value;
            });
          },
          mode: fluent.SpinButtonPlacementMode.inline,
        ),
        const SizedBox(height: 8),
        const Text("Score"),
        const SizedBox(height: 8),
        fluent.NumberBox(
          min: 0,
          max: 10,
          smallChange: 0.5,
          value: score,
          onChanged: (value) {
            setState(() {
              score = value;
            });
          },
          mode: fluent.SpinButtonPlacementMode.inline,
        ),
        const SizedBox(height: 8),
        const Text("Start Date"),
        const SizedBox(height: 8),
        Row(
          children: [
            fluent.DatePicker(
              selected: startDate,
              onChanged: (value) {
                setState(() {
                  startDate = value;
                });
              },
            ),
            const SizedBox(width: 8),
            fluent.IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  startDate = null;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text("End Date"),
        const SizedBox(height: 8),
        Row(
          children: [
            fluent.DatePicker(
              selected: endDate,
              onChanged: (value) {
                setState(() {
                  endDate = value;
                });
              },
            ),
            const SizedBox(width: 8),
            fluent.IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  endDate = null;
                });
              },
            ),
          ],
        )
      ],
    );
  }

  List<Widget> _buildAction(BuildContext context) {
    return [
      PlatformButton(
        child: const Text('Cancel'),
        onPressed: () => router.pop(),
      ),
      PlatformButton(
        child: const Text('UnBind'),
        onPressed: () {
          c.aniListID.value = "";
          c.saveAniListIds();
          router.pop();
        },
      ),
      PlatformButton(
        child: const Text('Confirm'),
        onPressed: () async {
          try {
            await AniListProvider.editList(
              status: selectStatus,
              endDate: endDate,
              score: score,
              progress: episodes,
              mediaId: c.aniListID.value,
              startDate: startDate,
            );
          } catch (e) {
            if (mounted) {
              showPlatformSnackbar(
                context: context,
                content: e.toString(),
                severity: fluent.InfoBarSeverity.error,
              );
              return;
            }
          }
          router.pop();
        },
      ),
    ];
  }

  Widget _buildAndroid(BuildContext context) {
    return AlertDialog(
      title: const Text('Anilist Tracking'),
      content: _buildAndroidContent(context),
      actions: _buildAction(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.ContentDialog(
      title: const Text('Anilist Tracking'),
      constraints: const BoxConstraints(maxWidth: 375),
      content: _buildDesktopContent(context),
      actions: _buildAction(context),
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
