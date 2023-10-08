import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miru_app/controllers/search_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/extension_item_card.dart';
import 'package:miru_app/views/widgets/horizontal_list.dart';
import 'package:miru_app/views/widgets/progress.dart';

class SearchAllTile extends StatefulWidget {
  const SearchAllTile({
    Key? key,
    required this.searchResult,
    required this.onClickMore,
    required this.kw,
  }) : super(key: key);

  final String kw;
  final SearchResult searchResult;
  final Function() onClickMore;

  @override
  State<SearchAllTile> createState() => _SearchAllTileState();
}

class _SearchAllTileState extends State<SearchAllTile> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: HorizontalList(
        onClickMore: widget.onClickMore,
        title: widget.searchResult.runitme.extension.name,
        contentBuilder: (controller) {
          if (widget.searchResult.error != null) {
            return Text(widget.searchResult.error!.split('\n').first);
          }
          if (widget.searchResult.result == null) {
            return const ProgressRing();
          }

          final data = widget.searchResult.result;

          if (data != null && data.isEmpty) {
            return Text('common.no-result'.i18n);
          }

          return SizedBox(
            height: Platform.isAndroid ? 170 : 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: controller,
              itemCount: data!.length,
              itemBuilder: ((context, index) {
                return Container(
                  width: Platform.isAndroid ? 110 : 170,
                  margin: const EdgeInsets.only(right: 16),
                  child: ExtensionItemCard(
                    key: ValueKey(data[index].url),
                    title: data[index].title,
                    url: data[index].url,
                    package: widget.searchResult.runitme.extension.package,
                    cover: data[index].cover,
                    update: data[index].update,
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
