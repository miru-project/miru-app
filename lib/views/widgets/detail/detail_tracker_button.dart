import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/messenger.dart';

class DetailTrackButtonAndroid extends StatefulWidget {
  const DetailTrackButtonAndroid(
      {super.key, this.tag, required this.anilistType});
  final String? tag;
  final String anilistType;
  @override
  State<DetailTrackButtonAndroid> createState() =>
      _DetailTrackButtonAndroidState();
}

class _DetailTrackButtonAndroidState extends State<DetailTrackButtonAndroid> {
  bool isFavorite = false;
  String status = "CURRENT";
  RxString startDateText = "Start Date".obs;
  RxString endDateText = "End Date".obs;
  DateTime? startDate;
  DateTime? endDate;
  String? score;
  String? episodes;
  String? aniListMediaId;
  final RxBool isStartDateChecked = false.obs;
  final RxBool isEndDateChecked = false.obs;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _episodeTextController = TextEditingController();
  final TextEditingController _scoreTextController = TextEditingController();

  Widget textContent(String text1, String text2) {
    return (Text.rich(
      TextSpan(
          text: "$text1 ",
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            // fontStyle: FontStyle.italic,
          ),
          children: [
            TextSpan(
              text: text2,
              style: const TextStyle(
                fontWeight: FontWeight.w300,
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
    return IconButton(
      onPressed: () {
        if (aniListMediaId == null && c.aniListID.value == "") {
          final extensionDetail = c.data.value;
          final searchString = extensionDetail!.title.obs;
          _textController.value = TextEditingValue(text: searchString.value);
          debugPrint("$extensionDetail");
          Get.to(() => Scaffold(
                appBar: AppBar(
                    title: Row(children: [
                  Expanded(
                      child: SizedBox(
                          height: 45,
                          child: TextField(
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) {
                              searchString.value = value;
                            },
                            controller: _textController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              labelText: 'Enter your search keyword',
                            ),
                          ))),
                  IconButton(
                      onPressed: () {
                        _textController.clear();
                      },
                      icon: const Icon(Icons.close))
                ])),
                body: Obx(() => FutureBuilder(
                      future: AniListProvider.mediaQuerypage(
                          searchString: searchString.value,
                          type: widget.anilistType,
                          page: 1),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data;
                          if (data!.isEmpty) {
                            return Center(child: Text('nothing found'.i18n));
                          }
                          return ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                // final String description =
                                //     data[index]["description"] ?? "";
                                return Card(
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      child: Row(children: [
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 10, 10, 10),
                                            child: Card(
                                                clipBehavior: Clip.hardEdge,
                                                child: CacheNetWorkImagePic(
                                                  data[index]["coverImage"]
                                                      ["large"],
                                                  height: 150,
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
                                                  "",
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                            textContent(
                                                "English Name",
                                                data[index]["title"]
                                                        ["english"] ??
                                                    ""),
                                            textContent("Status",
                                                data[index]["status"] ?? ""),
                                            textContent("Start Date",
                                                "${data[index]["startDate"]["year"] ?? ""}-${data[index]["startDate"]["month"] ?? ""}-${data[index]["startDate"]["day"] ?? ""}"),
                                            textContent("End Date",
                                                "${data[index]["endDate"]["year"] ?? ""}-${data[index]["endDate"]["month"] ?? ""}-${data[index]["endDate"]["day"] ?? ""}"),
                                            textContent(
                                                "isAdult",
                                                data[index]["isAdult"]
                                                    .toString()),
                                            // textContent(
                                            //     "Description",
                                            //     description.replaceAll(
                                            //         "\r\n", ""))
                                            // Text(data[index]["description"] ?? "",
                                            //     overflow: TextOverflow.ellipsis),
                                          ],
                                        )
                                      ]),
                                      onTap: () {
                                        final id = data[index]["id"].toString();
                                        aniListMediaId = id;
                                        Get.back();
                                      },
                                    ));
                              });
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    )),
              ));
        } else {
          showModalBottomSheet<void>(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 600,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: (Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Save to anilist?".i18n,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          )),
                      Text(
                        "Status:".i18n,
                        textAlign: TextAlign.left,
                      ),
                      DropdownMenu<String>(
                          inputDecorationTheme: InputDecorationTheme(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          initialSelection: "CURRENT",
                          onSelected: (String? value) {
                            status = value ?? "CURRENT";
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(
                                value: "CURRENT", label: "Current"),
                            DropdownMenuEntry(
                                value: "PLANNING", label: "Planning"),
                            DropdownMenuEntry(
                                value: "COMPLETED", label: "Completed"),
                            DropdownMenuEntry(
                                value: "DROPPED", label: "Dropped"),
                            DropdownMenuEntry(value: "PAUSED", label: "Paused"),
                            DropdownMenuEntry(
                                value: "REPEATING", label: "Rewatching"),
                          ]),
                      const Spacer(),
                      Text("Watch to:".i18n),
                      TextField(
                          onChanged: (value) {
                            episodes = value;
                            _episodeTextController.text = value;
                          },
                          controller: _episodeTextController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            labelText: 'Episode',
                          )),
                      const Spacer(),
                      Text("Score:".i18n),
                      TextField(
                          onChanged: (value) {
                            score = value;
                            _scoreTextController.text = value;
                          },
                          keyboardType: TextInputType.number,
                          controller: _scoreTextController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            labelText: 'Score',
                          )),
                      const Spacer(),
                      Text("Start at:".i18n),
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              )),
                          child: Row(children: [
                            Obx(() => Checkbox(
                                value: isStartDateChecked.value,
                                onChanged: (value) {
                                  if (value != null) {
                                    isStartDateChecked.value = value;
                                  }
                                })),
                            Expanded(
                                child: Obx(() => RichText(
                                    text: (TextSpan(
                                        text: startDateText.value,
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            final result = await showDatePicker(
                                                context: context,
                                                initialDate: startDate,
                                                firstDate: DateTime(1980, 01),
                                                lastDate: DateTime(2100, 12));
                                            debugPrint("$result");
                                            if (result != null) {
                                              startDate = result;
                                              startDateText.value =
                                                  "${result.year}/${result.month}/${result.day}";
                                            }
                                          })))))
                          ])),
                      const Spacer(),
                      Text("End at:".i18n),
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              )),
                          child: Row(children: [
                            Obx(() => Checkbox(
                                value: isEndDateChecked.value,
                                onChanged: (value) {
                                  if (value != null) {
                                    isEndDateChecked.value = value;
                                  }
                                })),
                            Expanded(
                                child: Obx(() => RichText(
                                        text: TextSpan(
                                      text: endDateText.value,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          final result = await showDatePicker(
                                              context: context,
                                              initialDate: endDate,
                                              firstDate: DateTime(1980, 01),
                                              lastDate: DateTime(2100, 12));
                                          debugPrint("$result");
                                          if (result != null) {
                                            endDate = result;
                                            endDateText.value =
                                                "${result.year}/${result.month}/${result.day}";
                                          }
                                        },
                                    ))))
                          ])),
                      const Spacer(),
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(40.0)))),
                              child: const Text('delete'),
                              onPressed: () async {
                                try {
                                  final result =
                                      await AniListProvider.deleteList(
                                          id: c.aniListID.value);
                                  debugPrint("$result");
                                  if (!context.mounted) return;
                                  showPlatformSnackbar(
                                      context: context,
                                      content: "delete success");
                                } catch (e) {
                                  if (!context.mounted) return;
                                  showPlatformSnackbar(
                                      title: "delete failed",
                                      context: context,
                                      content: "$e");
                                }

                                c.aniListID.value = "";
                                c.getAniListIds("");
                                aniListMediaId = null;

                                Navigator.pop(context);
                              },
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(40.0)))),
                                onPressed: () {
                                  c.aniListID.value = "";
                                  c.getAniListIds("");
                                  aniListMediaId = null;
                                  showPlatformSnackbar(
                                      context: context,
                                      content: "Unbinded".i18n);
                                  Navigator.pop(context);
                                },
                                child: Text('Unbind'.i18n)),
                            FilledButton(
                              child: Text('confirm'.i18n),
                              onPressed: () async {
                                debugPrint(
                                    "$episodes $score $status $startDate $endDate");
                                debugPrint(aniListMediaId);
                                debugPrint(c.aniListID.value);
                                try {
                                  final listid = await AniListProvider.editList(
                                      status: status,
                                      score: score,
                                      startDate: (isStartDateChecked.value)
                                          ? startDate
                                          : null,
                                      mediaId: aniListMediaId,
                                      endDate: (isEndDateChecked.value)
                                          ? endDate
                                          : null,
                                      progress: episodes,
                                      id: c.aniListID.value);
                                  if (!context.mounted) return;
                                  debugPrint(listid);
                                  c.aniListID.value = listid;
                                  c.getAniListIds(listid);
                                  showPlatformSnackbar(
                                      context: context,
                                      content: "Anilist saved".i18n);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  showPlatformSnackbar(
                                      context: context, content: e.toString());
                                }
                                Navigator.pop(context);
                              },
                            )
                          ]),
                    ],
                  )),
                ),
              );
            },
          );
        }
      },
      icon: const Icon(Icons.sync_rounded),
      // label: Text("detail.tracker".i18n),
      style: ButtonStyle(
        backgroundColor: isFavorite
            ? MaterialStateProperty.all(Theme.of(context).colorScheme.primary)
            : null,
        foregroundColor: isFavorite
            ? MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary)
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _episodeTextController.dispose();
    _scoreTextController.dispose();
    super.dispose();
  }
}
