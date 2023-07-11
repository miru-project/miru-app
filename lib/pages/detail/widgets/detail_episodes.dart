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
  late int selectEpGroup = 0;
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
              value: selectEpGroup,
              items: dropdownItems,
              onChanged: (value) {
                setState(() {
                  selectEpGroup = value!;
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
                  'total': episodes[selectEpGroup].urls.length.toString(),
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
            itemCount:
                episodes.isEmpty ? 0 : episodes[selectEpGroup].urls.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(episodes[selectEpGroup].urls[index].name),
                onTap: () {
                  c.goWatch(
                    context,
                    episodes[selectEpGroup].urls,
                    index,
                    selectEpGroup,
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
    return CardTile(
        title: 'detail.episodes'.i18n,
        trailing: Row(
          children: [
            const DetailContinuePlay(),
            const SizedBox(width: 8),
            fluent.ComboBox<int>(
              items: comboBoxItems,
              value: selectEpGroup,
              onChanged: (value) {
                setState(() {
                  selectEpGroup = value!;
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
              itemCount:
                  episodes.isEmpty ? 0 : episodes[selectEpGroup].urls.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth ~/ 180,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 5,
              ),
              itemBuilder: (context, index) {
                return fluent.Button(
                  child: Center(
                      child: Text(episodes[selectEpGroup].urls[index].name)),
                  onPressed: () async {
                    c.goWatch(
                      context,
                      episodes[selectEpGroup].urls,
                      index,
                      selectEpGroup,
                    );
                  },
                );
              },
              // children: [
              //   for (var i = 0; i < episodes[selectEpGroup].urls.length; i++) ...[
              //     Container(
              //       margin: const EdgeInsets.only(right: 8, bottom: 8),
              //       child: fluent.Button(
              //         child: Text(episodes[selectEpGroup].urls[i].name),
              //         onPressed: () async {
              //           c.goWatch(
              //             context,
              //             episodes[selectEpGroup].urls,
              //             i,
              //             selectEpGroup,
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
      debugPrint("episodes: ${dropdownItems!.length}");
      if (c.history.value != null) {
        selectEpGroup = c.history.value!.episodeGroupId;
      }
      return PlatformBuildWidget(
        androidBuilder: _buildAndroidEpisodes,
        desktopBuilder: _buildDesktopEpisodes,
      );
    });
  }
}
