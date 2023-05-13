import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  static const routeName = "/detail";

  const DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ScrollController _scrollController = ScrollController();
  double scrollPositionOpacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    double position = _scrollController.position.pixels;
    if (position <= 100) {
      setState(() {
        //判断是否滚动显示标题
        scrollPositionOpacity = position / 100;
      });
    } else {
      scrollPositionOpacity = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: false,
                snap: false,
                primary: true,
                title: Text(
                  "我推的孩子",
                  style: TextStyle(
                      color: Colors.black.withOpacity(scrollPositionOpacity)),
                ),
                flexibleSpace: Stack(
                  children: [
                    Image.network(
                      "https://image.tmdb.org/t/p/original//s76eYQi6hcAcOVYpVd9hofdyt11.jpg",
                      height: 400,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              // 主题背景色
                              Theme.of(context).colorScheme.background,
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // flex 左边封面右边标题
                    Positioned(
                      left: 20,
                      bottom: 105,
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx150672-2WWJVXIAOG11.png",
                              fit: BoxFit.cover,
                              width: 100,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "我推的孩子",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: const [
                                    Text("动画"),
                                    SizedBox(width: 5),
                                    Text("剧情"),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        top: null,
                        left: 20,
                        right: 20,
                        bottom: 60,
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text("继续观看第三集"),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).colorScheme.primary),
                                    foregroundColor: MaterialStateProperty.all(
                                        Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                    // 宽度沾满
                                    minimumSize: MaterialStateProperty.all(
                                      const Size(double.infinity, 50),
                                    ),
                                  ),
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: OutlinedButton.icon(
                              icon: const Icon(Icons.favorite_border),
                              label: const Text("收藏"),
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                  const Size(double.infinity, 50),
                                ),
                              ),
                              onPressed: () {},
                            ))
                          ],
                        )),
                    Positioned.fill(
                      child: IgnorePointer(
                          child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: scrollPositionOpacity,
                        child: Container(
                          decoration: const BoxDecoration(
                            // 纯白
                            color: Colors.white,
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: "剧集"),
                    Tab(text: "概览"),
                    Tab(text: "演员"),
                  ],
                ),
                expandedHeight: 400,
              ),
            ];
          },
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // select 选择框
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 10, right: 20),
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          // 背景颜色为 primaryContainer
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: DropdownButton<String>(
                        // 内容为 primary 颜色
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: "1",
                        items: const [
                          DropdownMenuItem(
                            value: "1",
                            child: Text("线路一"),
                          ),
                          DropdownMenuItem(
                            value: "2",
                            child: Text("线路二"),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                      child: const Text(
                        "共12集",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ...List.generate(
                        12,
                        (index) => InkWell(
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text("第${index + 1}集"),
                                    ),
                                    // 图标
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.more_vert))
                                  ],
                                ),
                              ),
                              onTap: () {},
                            ))
                  ],
                ),
              ),
              const Center(child: Text("概览")),
              const Center(child: Text("演员")),
            ],
          ),
        )));
  }
}
