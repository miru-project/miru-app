import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/anilist.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:miru_app/views/widgets/messenger.dart';

class DetailTrackButtonDesktop extends StatefulWidget {
  const DetailTrackButtonDesktop({super.key, this.tag});
  final String? tag;
  @override
  State<DetailTrackButtonDesktop> createState() =>
      _DetailTrackButtonDesktopState();
}

class _DetailTrackButtonDesktopState extends State<DetailTrackButtonDesktop> {
  bool isFavorite = false;
  final status = "CURRENT".obs;
  // RxString startDateText = "Start Date".obs;
  // RxString endDateText = "End Date".obs;
  RxBool showStartDate = false.obs;
  RxBool showEndDate = false.obs;
  // DateTime? startDate;
  // DateTime? endDate;
  // Rx<DateTime?> startDate;
  // Rx<DateTime?> endDate;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  int? score;
  int? episodes;
  String? aniListMediaId;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _episodeTextController = TextEditingController();
  final TextEditingController _scoreTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  Widget textContent(String text1, String text2) {
    return (Text.rich(
      TextSpan(
          text: "$text1 ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            // fontStyle: FontStyle.italic,
          ),
          children: [
            TextSpan(
              text: text2,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
              ),
            )
          ]),
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final DetailPageController c =
        Get.find<DetailPageController>(tag: widget.tag);

    final anilistType = c.anlistExtensionMap[c.type] ?? "ANIME";
    return Button(
        child: const Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Tracking"),
              SizedBox(width: 8),
              Icon(FluentIcons.sync)
            ],
          ),
        ),
        onPressed: () {
          if (aniListMediaId == null && c.aniListID.value == "") {
            final extensionDetail = c.data.value;
            final searchString = extensionDetail!.title.obs;
            _textController.value = TextEditingValue(text: searchString.value);
            debugPrint("test");
            Navigator.push(
                context,
                FluentPageRoute(
                    builder: (context) => ScaffoldPage(
                        header: RawKeyboardListener(
                            onKey: (RawKeyEvent event) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.enter) {
                                debugPrint("search");
                                searchString.value = _textController.value.text;
                              }
                              debugPrint("$event");
                            },
                            focusNode: FocusNode(),
                            child: TextBox(
                              controller: _textController,
                              placeholder: 'Name',
                              expands: false,
                            )),
                        content: Obx(() => FutureBuilder(
                            future: AniList.mediaQuerypage(
                                searchString: searchString.value,
                                type: anilistType,
                                page: 1),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final data = snapshot.data;
                                debugPrint("$data");
                                if (data!.isEmpty) {
                                  return Center(
                                      child: Text('nothing found'.i18n));
                                }
                                return ListView.builder(
                                    itemCount: data.length,
                                    itemBuilder: (context, index) {
                                      // final String description =
                                      //     data[index]["description"] ?? "";
                                      return HoverButton(onPressed: () {
                                        debugPrint("pressed");
                                        final id = data[index]["id"].toString();
                                        aniListMediaId = id;
                                        Navigator.pop(context);
                                      }, builder:
                                          (BuildContext context, buttonstate) {
                                        return Card(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 10),
                                          // clipBehavior: Clip.hardEdge,
                                          // child: InkWell(
                                          child: Row(children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5, 10, 10, 10),
                                                child: Card(
                                                    // clipBehavior: Clip.hardEdge,
                                                    child: CacheNetWorkImagePic(
                                                  data[index]["coverImage"]
                                                      ["large"],
                                                  height: 200,
                                                ))),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data[index]["title"]
                                                          ["userPreferred"] ??
                                                      "None",
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                                textContent(
                                                    "English Name",
                                                    data[index]["title"]
                                                            ["english"] ??
                                                        "None"),
                                                textContent(
                                                    "Status",
                                                    data[index]["status"] ??
                                                        ""),
                                                textContent("Start Date",
                                                    "${data[index]["startDate"]["year"] ?? ""}-${data[index]["startDate"]["month"] ?? ""}-${data[index]["startDate"]["day"] ?? ""}"),
                                                textContent("End Date",
                                                    "${data[index]["endDate"]["year"] ?? ""}-${data[index]["endDate"]["month"] ?? ""}-${data[index]["endDate"]["day"] ?? ""}"),
                                                textContent(
                                                    "isAdult",
                                                    data[index]["isAdult"]
                                                        .toString()),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                          ]),
                                        );
                                      });
                                    });
                              }
                              return Center(child: Text('nothing found'.i18n));
                            })))));
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return Obx(() => (ContentDialog(
                        title: const Text('Save to anilist?'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Status".i18n),
                            const SizedBox(height: 8),
                            ComboBox<String>(
                              onChanged: (value) {
                                debugPrint("$value");
                                setState(() {
                                  status.value = value!;
                                });
                              },
                              items: [
                                ComboBoxItem<String>(
                                    value: "CURRENT",
                                    child: Text("Current".i18n)),
                                ComboBoxItem<String>(
                                    value: "PLANNING",
                                    child: Text("Planning".i18n)),
                                ComboBoxItem<String>(
                                    value: "COMPLETED",
                                    child: Text("Completed".i18n)),
                                ComboBoxItem<String>(
                                    value: "DROPPED",
                                    child: Text("Dropped".i18n)),
                                ComboBoxItem<String>(
                                    value: "PAUSED",
                                    child: Text("Paused".i18n)),
                                ComboBoxItem<String>(
                                    value: "REPEATING",
                                    child: Text("Rewatching".i18n)),
                              ],
                              value: status.value,
                            ),
                            const SizedBox(height: 8),
                            Text("Episode".i18n),
                            const SizedBox(height: 8),
                            NumberBox<int>(
                              value: episodes ?? 0,
                              onChanged: (value) {
                                // debugPrint("");
                                episodes = value;
                              },
                              min: 0,
                              mode: SpinButtonPlacementMode.inline,
                            ),
                            const SizedBox(height: 8),
                            Text("Score".i18n),
                            const SizedBox(height: 8),
                            NumberBox<int>(
                              value: score ?? 0,
                              onChanged: (value) {
                                score = value;
                              },
                              min: 0,
                              mode: SpinButtonPlacementMode.inline,
                            ),
                            const SizedBox(height: 8),
                            Checkbox(
                                checked: showStartDate.value,
                                content: Text("Start Date".i18n),
                                onChanged: (value) {
                                  if (value != null) {
                                    showStartDate.value = value;
                                  }
                                }),
                            const SizedBox(height: 8),
                            if (showStartDate.value)
                              DatePicker(
                                  // header: "Start Date".i18n,
                                  selected: startDate.value,
                                  onChanged: (time) {
                                    debugPrint("$time");
                                    // startDate.value = DateTime.now();
                                    startDate.value = time;
                                  }),
                            const SizedBox(height: 8),
                            Checkbox(
                                checked: showEndDate.value,
                                content: Text("End Date".i18n),
                                onChanged: (value) {
                                  if (value != null) {
                                    showEndDate.value = value;
                                  }
                                }),
                            const SizedBox(height: 8),
                            if (showEndDate.value)
                              DatePicker(
                                  // header: "Start Date".i18n,
                                  selected: endDate.value,
                                  onChanged: (time) {
                                    debugPrint("$time");
                                    // startDate.value = DateTime.now();
                                    endDate.value = time;
                                  }),
                          ],
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () async {
                              // Delete file here
                              debugPrint(
                                  "$episodes $score $status $startDate $endDate");
                              try {
                                final listid = await AniList.editList(
                                    status: status.value,
                                    score: score.toString(),
                                    startDate: (showStartDate.value)
                                        ? startDate.value
                                        : null,
                                    mediaId: aniListMediaId,
                                    endDate: (showEndDate.value)
                                        ? endDate.value
                                        : null,
                                    progress: episodes.toString(),
                                    id: c.aniListID.value);
                                debugPrint(listid);
                                c.aniListID.value = listid;
                                c.getAniListIds(listid);
                                showPlatformSnackbar(
                                    context: context, content: "success");
                              } catch (e) {
                                showPlatformSnackbar(
                                    context: context,
                                    content: "anilist id not found");
                                debugPrint("$e");
                              }
                            },
                            child: Text('Confirm'.i18n),
                          ),
                          Button(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'.i18n),
                          ),
                          FilledButton(
                            style: ButtonStyle(
                                foregroundColor: ButtonState.resolveWith(
                                    (states) => Colors.white),
                                backgroundColor: ButtonState.resolveWith(
                                    (states) => Colors.red)),
                            onPressed: () async {
                              try {
                                final result = await AniList.deleteList(
                                    id: c.aniListID.value);
                                debugPrint("$result");
                              } catch (e) {
                                showPlatformSnackbar(
                                    context: context,
                                    content: "anilist id not found");
                                debugPrint("$e");
                              }
                              c.aniListID.value = "";
                              c.getAniListIds("");
                              aniListMediaId = null;

                              // Navigator.pop(context);
                            },
                            child: Text('delete'.i18n),
                          )
                        ],
                      )));
                });
          }
        });
  }

  @override
  void dispose() {
    _textController.dispose();
    _episodeTextController.dispose();
    _scoreTextController.dispose();
    super.dispose();
  }
}
