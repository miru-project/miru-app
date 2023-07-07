import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/main.dart';
import 'package:miru_app/pages/main/controller.dart';
import 'package:miru_app/pages/search/controller.dart';
import 'package:miru_app/pages/search/widgets/search_all_extension.dart';
import 'package:miru_app/widgets/bangumi_card.dart';
import 'package:miru_app/widgets/cache_network_image.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';

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
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text("搜索"),
        ),
        body: (c.runtimeList.isEmpty)
            ? SizedBox(
                height: 300,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("未安装任何扩展"),
                    const SizedBox(height: 8),
                    FilledButton(
                      child: const Text("扩展仓库"),
                      onPressed: () {
                        Get.find<MainController>().selectedTab.value = 2;
                      },
                    )
                  ],
                ),
              )
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      flexibleSpace: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller:
                                  TextEditingController(text: c.search.value),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                hintText: "请善用搜索哦!~",
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  c.search.value = '';
                                }
                              },
                              onSubmitted: (value) {
                                c.search(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 60,
                            child: ListView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              children: [
                                ChoiceChip(
                                  avatar: const Icon(Icons.extension),
                                  label: const Text('全部'),
                                  selected: c.selectIndex.value == (-1),
                                  onSelected: (value) {
                                    if (value) {
                                      c.selectIndex.value = -1;
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                for (var i = 0;
                                    i < c.runtimeList.length;
                                    i++) ...[
                                  ChoiceChip(
                                    avatar: CacheNetWorkImage(
                                      c.runtimeList[i].extension.icon ?? '',
                                      width: 20,
                                    ),
                                    label:
                                        Text(c.runtimeList[i].extension.name),
                                    selected: c.selectIndex.value == i,
                                    onSelected: (value) {
                                      if (value) {
                                        c.selectIndex.value = i;
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ]
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      expandedHeight: 135,
                      collapsedHeight: 135,
                    )
                  ];
                },
                body: Column(
                  children: [
                    if (c.selectIndex.value == -1)
                      Expanded(
                        child: SearchAllExtSearch(
                          kw: c.search.value,
                          runtimeList: c.runtimeList,
                          onClickMore: (index) {
                            c.selectIndex.value = index;
                          },
                        ),
                      )
                    else
                      Expanded(
                        child: FutureBuilder(
                          key: ValueKey(c.cuurentRuntime.extension.package +
                              c.search.value),
                          future: c.search.value.isNotEmpty
                              ? c.cuurentRuntime.search(c.search.value, 1)
                              : c.cuurentRuntime.latest(1),
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
                              return const Center(
                                child: Text("没有数据"),
                              );
                            }
                            return LayoutBuilder(
                              builder: (context, constraints) =>
                                  GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: constraints.maxWidth ~/ 120,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: data!.length,
                                itemBuilder: (context, index) => BangumiCard(
                                  key: ValueKey(data[index].url),
                                  title: data[index].title,
                                  url: data[index].url,
                                  package: c.cuurentRuntime.extension.package,
                                  cover: data[index].cover,
                                  update: data[index].update,
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                  ],
                ),
              ),
      );
    });
  }

  Widget _buildDesktopSearch(BuildContext context) {
    return Obx(() {
      if (c.runtimeList.isEmpty) {
        return SizedBox(
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("未安装任何扩展"),
              const SizedBox(height: 8),
              fluent.FilledButton(
                child: const Text("扩展仓库"),
                onPressed: () {
                  router.push('/extension_repo');
                },
              )
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        "搜索",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: fluent.Card(
                        child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              fluent.ToggleButton(
                                checked: c.selectIndex.value == (-1),
                                onChanged: (b) {
                                  if (b) {
                                    c.selectIndex.value = -1;
                                  }
                                },
                                child: const Row(
                                  children: [
                                    Text("全部"),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              for (var i = 0;
                                  i < c.runtimeList.length;
                                  i++) ...[
                                fluent.ToggleButton(
                                  key: ValueKey(i),
                                  checked: c.selectIndex.value == i,
                                  onChanged: (b) {
                                    if (b) {
                                      c.selectIndex.value = i;
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: CacheNetWorkImage(
                                          c.runtimeList[i].extension.icon ?? '',
                                          width: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(c.runtimeList[i].extension.name),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ]
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: fluent.TextBox(
                            controller:
                                TextEditingController(text: c.search.value),
                            placeholder: "请善用搜索哦!~",
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
                    )),
                  ),
                ],
              )),
          const SizedBox(height: 16),
          if (c.selectIndex.value == -1)
            Expanded(
              child: SearchAllExtSearch(
                kw: c.search.value,
                runtimeList: c.runtimeList,
                onClickMore: (index) {
                  c.selectIndex.value = index;
                },
              ),
            )
          else
            Expanded(
              child: FutureBuilder(
                key: ValueKey(
                    c.cuurentRuntime.extension.package + c.search.value),
                future: c.search.value.isNotEmpty
                    ? c.cuurentRuntime.search(c.search.value, 1)
                    : c.cuurentRuntime.latest(1),
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
                    return const Center(
                      child: Text("没有数据"),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) => GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth ~/ 170,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: data!.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return BangumiCard(
                          key: ValueKey(item.url),
                          title: item.title,
                          url: item.url,
                          package: c.cuurentRuntime.extension.package,
                          cover: item.cover,
                          update: item.update,
                        );
                      },
                    ),
                  );
                }),
              ),
            )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroidSearch,
      desktopBuilder: _buildDesktopSearch,
    );
  }
}
