import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/main/controller.dart';
import 'package:miru_app/pages/search/controller.dart';
import 'package:miru_app/pages/search/widgets/search_all_tile.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/button.dart';

class SearchAllExtSearch extends StatefulWidget {
  const SearchAllExtSearch({
    Key? key,
    required this.kw,
    required this.runtimeList,
    required this.onClickMore,
  }) : super(key: key);
  final String kw;
  final List<SearchResult> runtimeList;
  final Function(int) onClickMore;

  @override
  State<SearchAllExtSearch> createState() => _SearchAllExtSearchState();
}

class _SearchAllExtSearchState extends State<SearchAllExtSearch> {
  @override
  Widget build(BuildContext context) {
    if (widget.runtimeList.isEmpty) {
      return SizedBox(
        height: 300,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('common.no-extension'.i18n),
            const SizedBox(height: 8),
            PlatformFilledButton(
              child: Text("common.extension-repo".i18n),
              onPressed: () {
                if (Platform.isAndroid) {
                  Get.find<MainController>().selectedTab.value = 2;
                  return;
                }
                router.push('/extension_repo');
              },
            )
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var index = 0; index < widget.runtimeList.length; index++)
            SearchAllTile(
              kw: widget.kw,
              searchResult: widget.runtimeList[index],
              onClickMore: () {
                widget.onClickMore(index);
              },
            )
        ],
      ),
    );
  }
}
