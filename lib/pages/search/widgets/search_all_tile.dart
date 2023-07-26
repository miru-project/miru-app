import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/extension_item_card.dart';
import 'package:miru_app/widgets/horizontal_list.dart';
import 'package:miru_app/widgets/progress_ring.dart';

class SearchAllTile extends StatefulWidget {
  const SearchAllTile({
    Key? key,
    required this.runtime,
    required this.onClickMore,
    required this.kw,
  }) : super(key: key);

  final String kw;
  final ExtensionRuntime runtime;
  final Function() onClickMore;

  @override
  State<SearchAllTile> createState() => _SearchAllTileState();
}

class _SearchAllTileState extends State<SearchAllTile> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        key: ValueKey(widget.kw),
        future: widget.kw.isNotEmpty
            ? widget.runtime.search(widget.kw, 1)
            : widget.runtime.latest(1),
        builder: ((context, snapshot) {
          return HorizontalList(
            onClickMore: widget.onClickMore,
            title: widget.runtime.extension.name,
            contentBuilder: (controller) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (!snapshot.hasData) {
                return const ProgressRing();
              }

              final data = snapshot.data;

              if (snapshot.data != null && snapshot.data!.isEmpty) {
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
                        package: widget.runtime.extension.package,
                        cover: data[index].cover,
                        update: data[index].update,
                      ),
                    );
                  }),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
