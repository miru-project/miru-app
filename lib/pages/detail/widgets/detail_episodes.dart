import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/detail/controller.dart';
import 'package:miru_app/pages/detail/widgets/detail_continue_play.dart';
import 'package:miru_app/widgets/card_tile.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class DetailEpisodes extends StatefulWidget {
  const DetailEpisodes({
    Key? key,
  }) : super(key: key);

  @override
  State<DetailEpisodes> createState() => _DetailEpisodesState();
}

class _DetailEpisodesState extends State<DetailEpisodes> {
  late DetailPageController c = Get.find<DetailPageController>();
  List<fluent.ComboBoxItem<int>>? comboBoxItems;
  List<DropdownMenuItem<int>>? dropdownItems;
  late List<ExtensionEpisodeGroup> episodes = [];

  Widget _buildAndroidEpisodes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // select 选择框
        if (episodes.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 8, top: 5, right: 8),
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
            decoration: BoxDecoration(
                // 背景颜色为 primaryContainer
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: DropdownButton<int>(
              // 内容为 primary 颜色
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              isExpanded: true,
              underline: const SizedBox(),
              value: c.selectEpGroup.value,
              items: dropdownItems,
              onChanged: (value) {
                setState(() {
                  c.selectEpGroup.value = value!;
                });
              },
            ),
          ),
        if (episodes.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            child: Text(
              FlutterI18n.translate(
                context,
                'detail.total-episodes',
                translationParams: {
                  'total':
                      episodes[c.selectEpGroup.value].urls.length.toString(),
                },
              ),
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: episodes.isEmpty
                ? 0
                : episodes[c.selectEpGroup.value].urls.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(episodes[c.selectEpGroup.value].urls[index].name),
                onTap: () {
                  c.goWatch(
                    context,
                    episodes[c.selectEpGroup.value].urls,
                    index,
                    c.selectEpGroup.value,
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildDesktopEpisodes(BuildContext context) {
    late String episodesString;
    if (c.type.value == ExtensionType.bangumi) {
      episodesString = 'video.episodes'.i18n;
    } else {
      episodesString = 'reader.chapters'.i18n;
    }
    return CardTile(
        title: episodesString,
        trailing: Row(
          children: [
            const DetailContinuePlay(),
            const SizedBox(width: 8),
            fluent.ComboBox<int>(
              items: comboBoxItems,
              value: c.selectEpGroup.value,
              onChanged: (value) {
                setState(() {
                  c.selectEpGroup.value = value!;
                });
              },
            )
          ],
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            constraints: const BoxConstraints(
              maxHeight: 500,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: episodes.isEmpty
                  ? 0
                  : episodes[c.selectEpGroup.value].urls.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth ~/ 180,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 5,
              ),
              itemBuilder: (context, index) {
                return fluent.Button(
                  child: Center(
                      child: Text(
                          episodes[c.selectEpGroup.value].urls[index].name)),
                  onPressed: () async {
                    c.goWatch(
                      context,
                      episodes[c.selectEpGroup.value].urls,
                      index,
                      c.selectEpGroup.value,
                    );
                  },
                );
              },
              // children: [
              //   for (var i = 0; i < episodes[c.selectEpGroup.value].urls.length; i++) ...[
              //     Container(
              //       margin: const EdgeInsets.only(right: 8, bottom: 8),
              //       child: fluent.Button(
              //         child: Text(episodes[c.selectEpGroup.value].urls[i].name),
              //         onPressed: () async {
              //           c.goWatch(
              //             context,
              //             episodes[c.selectEpGroup.value].urls,
              //             i,
              //             c.selectEpGroup.value,
              //           );
              //         },
              //       ),
              //     ),
              //   ]
              // ],
            ),
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      episodes = c.isLoading.value ? [] : c.data.value!.episodes ?? [];
      dropdownItems = [
        for (var i = 0; i < episodes.length; i++)
          DropdownMenuItem<int>(
            value: i,
            child: Text(episodes[i].title),
          )
      ];
      comboBoxItems = [
        for (var i = 0; i < episodes.length; i++)
          fluent.ComboBoxItem<int>(
            value: i,
            child: Text(episodes[i].title),
          )
      ];
      return PlatformBuildWidget(
        androidBuilder: _buildAndroidEpisodes,
        desktopBuilder: _buildDesktopEpisodes,
      );
    });
  }
}
