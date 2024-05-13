import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/controllers/search_controller.dart';
import 'package:miru_app/views/pages/search/extension_searcher_page.dart';
import 'package:miru_app/views/widgets/search/search_all_extension.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/search_appbar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchPageController c;

  @override
  void initState() {
    c = Get.put(SearchPageController());
    c.isPageOpen = true;
    if (c.needRefresh) {
      c.getRuntime();
    }
    super.initState();
  }

  @override
  void dispose() {
    c.isPageOpen = false;
    super.dispose();
  }

  Widget _buildMobileSearch(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: SearchAppBar(
          textEditingController: TextEditingController(
            text: c.search.value,
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              c.search.value = '';
            }
          },
          onSubmitted: (value) {
            c.search.value = value;
          },
          hintText: "search.hint-text".i18n,
          title: "common.search".i18n,
          flexibleSpace: Obx(
            () => Column(
              children: [
                if (c.finishCount != c.searchResultList.length)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(
                      value: (c.finishCount / c.searchResultList.length),
                      minHeight: 2,
                    ),
                  ),
              ],
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'search.all'.i18n),
              Tab(text: 'extension-type.video'.i18n),
              Tab(text: 'extension-type.comic'.i18n),
              Tab(text: 'extension-type.novel'.i18n),
            ],
            onTap: (value) {
              switch (value) {
                case 0:
                  c.getRuntime();
                  break;
                case 1:
                  c.getRuntime(type: ExtensionType.bangumi);
                  break;
                case 2:
                  c.getRuntime(type: ExtensionType.manga);
                  break;
                case 3:
                  c.getRuntime(type: ExtensionType.fikushon);
                  break;
              }
            },
          ),
        ),
        body: Obx(
          () {
            // ignore: invalid_use_of_protected_member
            final list = c.searchResultList.value;
            return SearchAllExtSearch(
              key: ValueKey(
                c.search.value + c.cuurentExtensionType.value.toString(),
              ),
              kw: c.search.value,
              runtimeList: list,
              onClickMore: (index) {
                Get.to(ExtensionSearcherPage(
                  package: c.getPackgeByIndex(index),
                  keyWord: c.search.value,
                ));
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopSearch(BuildContext context) {
    final suffix = Row(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 2.0),
        child: fluent.IconButton(
          icon: const Icon(fluent.FluentIcons.chrome_close, size: 9.0),
          onPressed: () {
            c.search.value = '';
            setState(() {});
          },
        ),
      ),
    ]);
    return Obx(
      () => Column(
        children: [
          if (c.finishCount != c.searchResultList.length)
            SizedBox(
              height: 4,
              width: double.infinity,
              child: fluent.ProgressBar(
                value: (c.finishCount / c.searchResultList.length) * 100,
              ),
            )
          else
            const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'common.search'.i18n,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Row(
                    children: [
                      Expanded(
                          child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          fluent.ToggleButton(
                            checked: c.cuurentExtensionType.value == null,
                            onChanged: (value) {
                              if (value) {
                                c.getRuntime();
                              }
                            },
                            child: Row(
                              children: [
                                Text("search.all".i18n),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          fluent.ToggleButton(
                            checked: c.cuurentExtensionType.value ==
                                ExtensionType.bangumi,
                            onChanged: (value) {
                              if (value) {
                                c.getRuntime(type: ExtensionType.bangumi);
                              }
                            },
                            child: Text('extension-type.video'.i18n),
                          ),
                          const SizedBox(width: 8),
                          fluent.ToggleButton(
                            checked: c.cuurentExtensionType.value ==
                                ExtensionType.manga,
                            onChanged: (value) {
                              if (value) {
                                c.getRuntime(type: ExtensionType.manga);
                              }
                            },
                            child: Text('extension-type.comic'.i18n),
                          ),
                          const SizedBox(width: 8),
                          fluent.ToggleButton(
                            checked: c.cuurentExtensionType.value ==
                                ExtensionType.fikushon,
                            onChanged: (value) {
                              if (value) {
                                c.getRuntime(type: ExtensionType.fikushon);
                              }
                            },
                            child: Text('extension-type.novel'.i18n),
                          ),
                        ],
                      )),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 300,
                        child: fluent.TextBox(
                          controller:
                              TextEditingController(text: c.search.value),
                          placeholder: "search.hint-text".i18n,
                          suffix: suffix,
                          suffixMode: fluent.OverlayVisibilityMode.editing,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              c.search.value = '';
                            }
                          },
                          onSubmitted: (value) {
                            c.search.value = value;
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SearchAllExtSearch(
              key: ValueKey(
                c.search.value + c.cuurentExtensionType.value.toString(),
              ),
              kw: c.search.value,
              // ignore: invalid_use_of_protected_member
              runtimeList: c.searchResultList.value,
              onClickMore: (index) {
                router.push(Uri(
                  path: "/search_extension",
                  queryParameters: {
                    "package": c.getPackgeByIndex(index),
                    "keyWord": c.search.value,
                  },
                ).toString());
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobileSearch,
      desktopBuilder: _buildDesktopSearch,
    );
  }
}
