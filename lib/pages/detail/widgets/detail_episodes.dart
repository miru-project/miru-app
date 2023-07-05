import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/detail/controller.dart';
import 'package:miru_app/pages/detail/widgets/detail_continue_play.dart';
import 'package:miru_app/pages/detail/widgets/detail_tile.dart';
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
  late List<fluent.ComboBoxItem<int>> comboBoxItems;
  late List<DropdownMenuItem<int>> dropdownItems;
  late int selectEpGroup = 0;
  late List<ExtensionEpisodeGroup> episodes;

  @override
  void initState() {
    if (c.history.value != null) {
      selectEpGroup = c.history.value!.episodeGroupId;
    }
    episodes = c.data.value!.episodes ?? [];
    super.initState();
  }

  Widget _buildAndroidEpisodes(BuildContext context) {
    dropdownItems = [
      for (var i = 0; i < episodes.length; i++)
        DropdownMenuItem<int>(
          value: i,
          child: Text(episodes[i].title),
        )
    ];
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // select 选择框
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
        Container(
          margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: Text(
            "共 ${episodes[selectEpGroup].urls.length} 集",
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        for (var i = 0; i < episodes[selectEpGroup].urls.length; i++)
          ListTile(
            title: Text(episodes[selectEpGroup].urls[i].name),
            onTap: () {
              c.goWatch(
                context,
                episodes[selectEpGroup].urls,
                i,
                selectEpGroup,
              );
            },
          )
      ],
    );
  }

  Widget _buildDesktopEpisodes(BuildContext context) {
    comboBoxItems = [
      for (var i = 0; i < episodes.length; i++)
        fluent.ComboBoxItem(
          value: i,
          child: Text(episodes[i].title),
        )
    ];
    return DetailTile(
      title: "剧集",
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              for (var i = 0; i < episodes[selectEpGroup].urls.length; i++) ...[
                Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  child: fluent.Button(
                    child: Text(episodes[selectEpGroup].urls[i].name),
                    onPressed: () async {
                      c.goWatch(
                        context,
                        episodes[selectEpGroup].urls,
                        i,
                        selectEpGroup,
                      );
                    },
                  ),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroidEpisodes,
      desktopBuilder: _buildDesktopEpisodes,
    );
  }
}
