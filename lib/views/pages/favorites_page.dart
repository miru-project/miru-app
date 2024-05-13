import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/extension_item_card.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/progress.dart';

class FavoritesPage extends fluent.StatefulWidget {
  const FavoritesPage({super.key, required this.type});
  final ExtensionType type;

  @override
  fluent.State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends fluent.State<FavoritesPage> {
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(
            context,
            "home.favorite-all",
            translationParams: {
              "type": ExtensionUtils.typeToString(widget.type).toLowerCase(),
            },
          ),
        ),
      ),
      body: FutureBuilder(
        future: DatabaseService.getFavoritesByType(type: widget.type),
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
                  FlutterI18n.translate(
                    context,
                    "home.favorite-all",
                    translationParams: {
                      "type": ExtensionUtils.typeToString(widget.type)
                          .toLowerCase(),
                    },
                  ),
                  style: fluent.FluentTheme.of(context).typography.subtitle,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder(
              future: DatabaseService.getFavoritesByType(type: widget.type),
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
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
