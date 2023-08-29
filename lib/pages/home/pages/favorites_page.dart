import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/extension_item_card.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress.dart';

class FavoritesPage extends fluent.StatefulWidget {
  const FavoritesPage({Key? key, required this.type}) : super(key: key);
  final ExtensionType type;

  @override
  fluent.State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends fluent.State<FavoritesPage> {
  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "${ExtensionUtils.typeToString(widget.type)}${"home.favorite".i18n}",
      )),
      body: FutureBuilder(
        future: DatabaseUtils.getFavoritesByType(type: widget.type),
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
                  package: item.package,
                  cover: item.cover,
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
                  "${ExtensionUtils.typeToString(widget.type)}${"home.favorite".i18n}",
                  style: fluent.FluentTheme.of(context).typography.subtitle,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder(
              future: DatabaseUtils.getFavoritesByType(type: widget.type),
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
                        padding:
                            const EdgeInsets.only(right: 8, bottom: 8, top: 8),
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
                            package: item.package,
                            cover: item.cover,
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
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
