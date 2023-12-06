import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:miru_app/views/widgets/detail/detail_continue_play.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/views/widgets/card_tile.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class DetailEpisodes extends StatefulWidget {
  const DetailEpisodes({
    Key? key,
    this.tag,
  }) : super(key: key);
  final String? tag;

  @override
  State<DetailEpisodes> createState() => _DetailEpisodesState();
}

class _DetailEpisodesState extends State<DetailEpisodes> {
  late DetailPageController c = Get.find<DetailPageController>(tag: widget.tag);
  List<fluent.ComboBoxItem<int>>? comboBoxItems;
  List<DropdownMenuItem<int>>? dropdownItems;
  late List<ExtensionEpisodeGroup> episodes = [];
  late String listMode = MiruStorage.getSetting(SettingKey.listMode);
  bool isRevered = false;
  Widget _buildAndroidEpisodes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // select 选择框
        if (episodes.isNotEmpty)
          SizedBox(
              child: Row(children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isRevered = !isRevered;
                  });
                },
                icon: isRevered
                    ? const Icon(Icons.keyboard_double_arrow_up_rounded)
                    : const Icon(Icons.keyboard_double_arrow_down_rounded)),
            Expanded(
                flex: 1,
                child: Container(
                    margin: const EdgeInsets.only(left: 8, top: 5, right: 8),
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        // 背景颜色为 primaryContainer
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: DropdownButton<int>(
                      // 内容为 primary 颜色
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      isExpanded: true,
                      underline: const SizedBox(),
                      value: c.selectEpGroup.value,
                      items: dropdownItems,
                      onChanged: (value) {
                        setState(() {
                          c.selectEpGroup.value = value!;
                        });
                      },
                    )))
          ])),
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
                title: isRevered
                    ? Text(episodes[c.selectEpGroup.value]
                        .urls[episodes[c.selectEpGroup.value].urls.length -
                            1 -
                            index]
                        .name)
                    : Text(episodes[c.selectEpGroup.value].urls[index].name),
                onTap: () {
                  c.goWatch(
                    context,
                    episodes[c.selectEpGroup.value].urls,
                    isRevered
                        ? episodes[c.selectEpGroup.value].urls.length -
                            1 -
                            index
                        : index,
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
    if (c.type == ExtensionType.bangumi) {
      episodesString = 'video.episodes'.i18n;
    } else {
      episodesString = 'reader.chapters'.i18n;
    }

    Widget cardTile(Widget child) {
      return CardTile(
        title: episodesString,
        leading: Row(children: [
          fluent.IconButton(
            icon: Icon(
              listMode == "grid"
                  ? fluent.FluentIcons.view_list
                  : fluent.FluentIcons.grid_view_medium,
            ),
            onPressed: () {
              setState(() {
                listMode == "grid" ? listMode = "list" : listMode = "grid";
                MiruStorage.setSetting(SettingKey.listMode, listMode);
              });
            },
          ),
          fluent.IconButton(
            icon: isRevered
                ? const Icon(fluent.FluentIcons.sort_lines_ascending)
                : const Icon(fluent.FluentIcons.sort_lines),
            onPressed: () {
              setState(() {
                isRevered = !isRevered;
                // MiruStorage.setSetting(SettingKey.listMode, listMode);
              });
            },
          )
        ]),
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
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 500,
          ),
          child: child,
        ),
      );
    }

    if (listMode == "grid") {
      return cardTile(
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              reverse: isRevered,
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
            );
          },
        ),
      );
    }

    return cardTile(
      ListView.builder(
        shrinkWrap: true,
        reverse: isRevered,
        padding: const EdgeInsets.all(0),
        itemCount:
            episodes.isEmpty ? 0 : episodes[c.selectEpGroup.value].urls.length,
        itemBuilder: (context, index) {
          return fluent.ListTile(
            title: Text(episodes[c.selectEpGroup.value].urls[index].name),
            onPressed: () {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      episodes = c.isLoading.value ? [] : c.detail!.episodes ?? [];
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
