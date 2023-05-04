import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = "/home";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "首页",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "最近观看",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 横向滑动的列表
                      SizedBox(
                        height: 200,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List.generate(
                            10,
                            (index) => const SizedBox(
                              width: 350,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Image(
                                  image: NetworkImage(
                                      "https://images.weserv.nl/?url=https://artworks.thetvdb.com/banners/v4/episode/9687593/screencap/645188bf7be73.jpg"),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "收藏",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView(
                        // 取消滚动
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        children: List.generate(
                          10,
                          (index) => SizedBox(
                              child: Column(
                            // 居左
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: InkWell(
                                  child: const Card(
                                    // 隐藏溢出的部分
                                    clipBehavior: Clip.antiAlias,
                                    margin: EdgeInsets.all(0),
                                    // 显示图片并显示圆角
                                    child: Image(
                                      image: NetworkImage(
                                          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx150672-2WWJVXIAOG11.png"),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  onTap: () => {
                                    // 跳转路由到详情页
                                    Navigator.pushNamed(context, "/detail")
                                  },
                                ),
                              ),
                              // 文字只显示一行
                              const SizedBox(
                                height: 20,
                                child: Text(
                                  "我推的孩子",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )),
                        ),
                      )
                    ],
                  ),
                ))));
  }
}
