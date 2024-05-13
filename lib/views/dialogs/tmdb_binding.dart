import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:get/get.dart';
import 'package:miru_app/data/providers/tmdb_provider.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/grid_item_tile.dart';
import 'package:miru_app/views/widgets/infinite_scroller.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/search_appbar.dart';
import 'package:tmdb_api/tmdb_api.dart';

class TMDBBinding extends StatefulWidget {
  const TMDBBinding({
    super.key,
    required this.title,
  });
  final String title;

  @override
  State<TMDBBinding> createState() => _TMDBBindingState();
}

class _TMDBBindingState extends State<TMDBBinding> {
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
      final data = await TmdbApi.search(_keyWord, page: _page);
      final result = data["results"] as List;
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
        title: 'detail.modify-tmdb-binding'.i18n,
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
              return GridItemTile(
                title: item['name'] ?? item['original_title'],
                cover: TmdbApi.getImageUrl(
                      item['poster_path'],
                      size: ImageSizes.POSTER_SIZE_HIGH,
                    ) ??
                    '',
                onTap: () {
                  Get.back(
                    result: {
                      'id': item['id'],
                      'media_type': item['media_type'],
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
                  'detail.modify-tmdb-binding'.i18n,
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
                        return GridItemTile(
                          title: item['name'] ?? item['original_title'],
                          cover: TmdbApi.getImageUrl(
                                item['poster_path'],
                                size: ImageSizes.POSTER_SIZE_HIGH,
                              ) ??
                              '',
                          onTap: () {
                            router.pop({
                              'id': item['id'],
                              'media_type': item['media_type'],
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
