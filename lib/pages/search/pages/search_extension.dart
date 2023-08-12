import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/extension_item_card.dart';
import 'package:miru_app/widgets/infinite_scroller.dart';
import 'package:miru_app/widgets/messenger.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class SearchExtensionPage extends fluent.StatefulWidget {
  const SearchExtensionPage({
    Key? key,
    required this.package,
    this.keyWord,
  }) : super(key: key);
  final String package;
  final String? keyWord;

  @override
  fluent.State<SearchExtensionPage> createState() =>
      _SearchExtensionPageState();
}

class _SearchExtensionPageState extends fluent.State<SearchExtensionPage> {
  late ExtensionRuntime _runtime;
  late String _keyWord = widget.keyWord ?? '';
  bool _showSearh = false;
  final List<ExtensionListItem> _data = [];
  int _page = 1;
  bool _isLoding = true;

  Future<void> _onRefresh() async {
    setState(() {
      _page = 1;
      _data.clear();
    });
    await _onLoad();
  }

  Future<void> _onLoad() async {
    try {
      _isLoding = true;
      setState(() {});
      late List<ExtensionListItem> data;
      if (_keyWord.isEmpty) {
        data = await _runtime.latest(_page);
      } else {
        data = await _runtime.search(_keyWord, _page);
      }
      if (data.isEmpty && mounted) {
        showPlatformSnackbar(
          context: context,
          content: "common.no-more-data".i18n,
          severity: fluent.InfoBarSeverity.warning,
        );
      }
      _data.addAll(data);
      _page++;
    } catch (e) {
      showPlatformSnackbar(
        context: context,
        content: e.toString(),
        severity: fluent.InfoBarSeverity.error,
      );
    } finally {
      _isLoding = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  _onSearch(String keyWord) {
    _keyWord = keyWord;
    _onRefresh();
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearh || _keyWord.isNotEmpty
            ? TextField(
                decoration: InputDecoration(
                  hintText: 'search.hint-text'.i18n,
                  border: InputBorder.none,
                ),
                controller: TextEditingController(
                  text: _keyWord,
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    _onSearch(value);
                  }
                },
                onSubmitted: _onSearch,
              )
            : Text(
                _runtime.extension.name,
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearh ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_showSearh) {
                  _keyWord = '';
                }
                _showSearh = !_showSearh;
              });
            },
          ),
        ],
      ),
      body: InfiniteScroller(
        onRefresh: _onRefresh,
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
              return ExtensionItemCard(
                title: item.title,
                url: item.url,
                package: widget.package,
                cover: item.cover,
                update: item.update,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoding)
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
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _runtime.extension.name,
                  style: fluent.FluentTheme.of(context).typography.subtitle,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                child: fluent.TextBox(
                  controller: TextEditingController(
                    text: _keyWord,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _onSearch(value);
                    }
                  },
                  onSubmitted: _onSearch,
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
                      return ExtensionItemCard(
                        title: item.title,
                        url: item.url,
                        package: widget.package,
                        cover: item.cover,
                        update: item.update,
                      );
                    },
                  )),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final runtime = ExtensionUtils.runtimes[widget.package];
    final extensionMissing = Text(
      FlutterI18n.translate(
        context,
        'common-extension-missing',
        translationParams: {'package': widget.package},
      ),
    );
    if (runtime == null) {
      return PlatformWidget(
        androidWidget: Scaffold(
          body: extensionMissing,
        ),
        desktopWidget: Center(
          child: extensionMissing,
        ),
      );
    }
    _runtime = runtime;
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
