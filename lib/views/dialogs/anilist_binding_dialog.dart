import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:get/get.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/grid_item_tile.dart';
import 'package:miru_app/views/widgets/infinite_scroller.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/search_appbar.dart';

class AnilistBindingDialog extends StatefulWidget {
  const AnilistBindingDialog({
    super.key,
    required this.title,
    required this.type,
  });
  final String title;
  final AnilistType type;

  @override
  State<AnilistBindingDialog> createState() => _AnilistBindingDialogState();
}

class _AnilistBindingDialogState extends State<AnilistBindingDialog> {
  late final TextEditingController _textEditingController =
      TextEditingController(text: widget.title);
  final EasyRefreshController _easyRefreshController = EasyRefreshController();

  int _page = 1;
  final List<dynamic> _data = [];
  bool _isLoading = true;
  late String _keyWord = widget.title;

  Future<void> _onRefresh() async {
    setState(() {
      _page = 1;
      _data.clear();
    });
    await _onLoad();
  }

  Future<void> _onLoad() async {
    try {
      _isLoading = true;
      setState(() {});
      final result = await AniListProvider.mediaQuerypage(
        searchString: _keyWord,
        type: widget.type,
        page: _page,
      );
      debugPrint(result.toString());
      if (result.isEmpty && mounted) {
        showPlatformSnackbar(
          context: context,
          content: "common.no-more-data".i18n,
          severity: fluent.InfoBarSeverity.warning,
        );
      }
      _data.addAll(result);
      _page++;
    } catch (e) {
      if (mounted) {
        showPlatformSnackbar(
          context: context,
          content: e.toString(),
          severity: fluent.InfoBarSeverity.error,
        );
      }
      rethrow;
    } finally {
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  _onSearch(String keyWord) {
    _keyWord = keyWord;
    if (Platform.isAndroid || Platform.isIOS) {
      _easyRefreshController.callRefresh();
    } else {
      _onRefresh();
    }
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        title: 'Anilist binding'.i18n,
        onChanged: (value) {
          if (value.isEmpty) {
            _onSearch(value);
          }
        },
        onSubmitted: _onSearch,
        textEditingController: _textEditingController,
      ),
      body: InfiniteScroller(
        onRefresh: _onRefresh,
        easyRefreshController: _easyRefreshController,
        onLoad: _onLoad,
        child: LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 120,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _data.length,
            itemBuilder: (context, index) {
              final item = _data[index];
              final title = item["title"]["userPreferred"] ?? "None";
              final cover = item["coverImage"]["large"];
              return GridItemTile(
                title: title,
                cover: cover,
                onTap: () {
                  Get.back(
                    result: {
                      'id': item['id'],
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.Card(
      padding: const EdgeInsets.all(0),
      backgroundColor: fluent.FluentTheme.of(context).micaBackgroundColor,
      child: Column(
        mainAxisSize: fluent.MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const SizedBox(
              height: 4,
              width: double.infinity,
              child: fluent.ProgressBar(),
            )
          else
            const SizedBox(height: 4),
          fluent.Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.IconButton(
                  icon: const Icon(fluent.FluentIcons.back),
                  onPressed: () {
                    router.pop();
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Anilist binding'.i18n,
                  style: fluent.FluentTheme.of(context).typography.subtitle,
                ),
                const Spacer(),
                SizedBox(
                  width: 300,
                  child: fluent.TextBox(
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _onSearch(value);
                      }
                    },
                    onSubmitted: _onSearch,
                    controller: _textEditingController,
                    placeholder: 'search.hint-text'.i18n,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: InfiniteScroller(
              onRefresh: _onRefresh,
              onLoad: _onLoad,
              child: LayoutBuilder(
                builder: ((context, constraints) => GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth ~/ 160,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        final item = _data[index];
                        final title = item["title"]["userPreferred"] ?? "None";
                        final cover = item["coverImage"]["large"];
                        return GridItemTile(
                          title: title,
                          cover: cover,
                          onTap: () {
                            router.pop({
                              'id': item['id'],
                            });
                          },
                        );
                      },
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
