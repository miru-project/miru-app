import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/search/controller.dart';
import 'package:miru_app/pages/search/pages/search_extension.dart';
import 'package:miru_app/pages/search/widgets/search_all_extension.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchPageController c;

  @override
  void initState() {
    c = Get.put(SearchPageController());
    super.initState();
  }

  Widget _buildAndroidSearch(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'search.hint-text'.i18n,
            border: InputBorder.none,
          ),
          controller: TextEditingController(
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
        ),
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
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              flexibleSpace: Obx(
                () => SizedBox(
                  height: 60,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: Text('search.all'.i18n),
                        selected: c.cuurentExtensionType.value == null,
                        onSelected: (value) {
                          if (value) {
                            c.getRuntime();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('extension-type.video'.i18n),
                        selected: c.cuurentExtensionType.value ==
                            ExtensionType.bangumi,
                        onSelected: (value) {
                          if (value) {
                            c.getRuntime(type: ExtensionType.bangumi);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('extension-type.comic'.i18n),
                        selected:
                            c.cuurentExtensionType.value == ExtensionType.manga,
                        onSelected: (value) {
                          if (value) {
                            c.getRuntime(type: ExtensionType.manga);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('extension-type.novel'.i18n),
                        selected: c.cuurentExtensionType.value ==
                            ExtensionType.fikushon,
                        onSelected: (value) {
                          if (value) {
                            c.getRuntime(
                              type: ExtensionType.fikushon,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              floating: true,
              snap: true,
            )
          ];
        },
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
                Get.to(SearchExtensionPage(
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
      androidBuilder: _buildAndroidSearch,
      desktopBuilder: _buildDesktopSearch,
    );
  }
}
