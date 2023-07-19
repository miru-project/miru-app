import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/extension_item_card.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';

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
                    setState(() {
                      _keyWord = value;
                    });
                  }
                },
                onSubmitted: (value) {
                  setState(() {
                    _keyWord = value;
                  });
                },
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
      body: FutureBuilder(
        key: ValueKey(_keyWord),
        future: _keyWord.isEmpty
            ? _runtime.latest(1)
            : _runtime.search(_keyWord, 1),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: ProgressRing(),
              ),
            );
          }
          final data = snapshot.data;

          if (data != null && data.isEmpty) {
            return Center(
              child: Text("common.no-result".i18n),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) => GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth ~/ 120,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: data!.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return ExtensionItemCard(
                  title: item.title,
                  url: item.url,
                  package: widget.package,
                  cover: item.cover,
                  update: item.update,
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _runtime.extension.name,
                  style: fluent.FluentTheme.of(context).typography.subtitle,
                ),
              ),
              Expanded(
                child: fluent.TextBox(
                  controller: TextEditingController(
                    text: _keyWord,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _keyWord = value;
                      });
                    }
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _keyWord = value;
                    });
                  },
                  placeholder: 'search.hint-text'.i18n,
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder(
              key: ValueKey(_keyWord),
              future: _keyWord.isEmpty
                  ? _runtime.latest(1)
                  : _runtime.search(_keyWord, 1),
              builder: ((context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data;

                if (data == null) {
                  return const Center(
                    child: Text('No data'),
                  );
                }

                return LayoutBuilder(
                  builder: ((context, constraints) => GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth ~/ 160,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return ExtensionItemCard(
                            title: item.title,
                            url: item.url,
                            package: widget.package,
                            cover: item.cover,
                            update: item.update,
                          );
                        },
                      )),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final runtime = ExtensionUtils.extensions[widget.package];
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
