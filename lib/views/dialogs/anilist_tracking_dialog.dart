import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/views/dialogs/date_tile_dialog.dart';
import 'package:miru_app/views/dialogs/number_tile_dialog.dart';
import 'package:miru_app/views/dialogs/switch_tile_dialog.dart';
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
  late final status = {
    for (final child in AnilistMediaListStatus.values)
      AniListProvider.mediaListStatusToTranslate(
        child,
        widget.anilistType,
      ): child,
  };

  // media list id
  int id = 0;

  AnilistMediaListStatus selectStatus = AnilistMediaListStatus.current;
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
        selectStatus = AniListProvider.stringToMediaListStatus(data["status"]);
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
    if (loading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: ProgressRing(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Anilist Tracking",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: SwitchTileDialog(
                          title: "Status",
                          value: selectStatus,
                          buildOptions: status,
                          onSelected: (value) {
                            setState(() {
                              selectStatus = value;
                            });
                          },
                          onClear: () {
                            setState(
                              () {
                                selectStatus = AnilistMediaListStatus.current;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: NumberTileDialog(
                          title: "Episodes",
                          value: episodes,
                          max: maxEpisodes,
                          min: 0,
                          onChange: (value) {
                            setState(() {
                              episodes = value.toInt();
                            });
                          },
                          onClear: () {
                            setState(() {
                              episodes = 0;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: NumberTileDialog(
                          title: "Score",
                          value: score,
                          max: 10,
                          min: 0,
                          onChange: (value) {
                            setState(() {
                              score = value;
                            });
                          },
                          onClear: () {
                            setState(() {
                              score = 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: DateTileDialog(
                          title: "Start Date",
                          value: startDate,
                          onChange: (value) {
                            setState(() {
                              startDate = value;
                            });
                          },
                          onClear: () {
                            setState(() {
                              startDate = null;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: DateTileDialog(
                          title: "End Date",
                          value: endDate,
                          onChange: (value) {
                            setState(() {
                              endDate = value;
                            });
                          },
                          onClear: () {
                            setState(() {
                              endDate = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (final child in _buildAction(context)) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: child,
                )
              ],
            ],
          ),
        ],
      ),
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
        fluent.ComboBox<AnilistMediaListStatus>(
          value: selectStatus,
          items: [
            for (final child in status.entries)
              fluent.ComboBoxItem(
                value: child.value,
                child: Text(child.key),
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
      PlatformTextButton(
        child: const Text('Cancel'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      PlatformTextButton(
        child: const Text('UnBind'),
        onPressed: () {
          c.aniListID.value = "";
          c.saveAniListIds();
          Navigator.of(context).pop();
        },
      ),
      PlatformFilledButton(
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
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    ];
  }

  Widget _buildAndroid(BuildContext context) {
    return _buildAndroidContent(context);
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
