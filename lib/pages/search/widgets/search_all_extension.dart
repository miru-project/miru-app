import 'package:flutter/material.dart';
import 'package:miru_app/pages/search/widgets/search_all_tile.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class SearchAllExtSearch extends StatefulWidget {
  const SearchAllExtSearch({
    Key? key,
    required this.kw,
    required this.runtimeList,
    required this.onClickMore,
  }) : super(key: key);
  final String kw;
  final List<ExtensionRuntime> runtimeList;
  final Function(int) onClickMore;

  @override
  State<SearchAllExtSearch> createState() => _SearchAllExtSearchState();
}

class _SearchAllExtSearchState extends State<SearchAllExtSearch> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.runtimeList.length; i++)
          SearchAllTile(
            kw: widget.kw,
            runtime: widget.runtimeList[i],
            onClickMore: () {
              widget.onClickMore(i);
            },
          ),
      ],
    );
  }
}
