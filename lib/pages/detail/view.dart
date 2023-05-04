import 'dart:ui';

import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  static const routeName = "/detail";

  const DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.network(
                "https://image.tmdb.org/t/p/original//s76eYQi6hcAcOVYpVd9hofdyt11.jpg",
                height: 300,
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
                        Colors.white,
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
              // flex 左边封面右边标题
              Positioned(
                bottom: 10,
                left: 20,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        "https://www.7xi.tv/upload/vod/20230413-1/e8b8a6943cfd44142b3e71b106707b32.jpg",
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
              // 返回按钮
              Positioned(
                top: 10,
                left: 10,
                child: SafeArea(
                    child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                )),
              ),
            ],
          ),
          // TabBar 和视图
          DefaultTabController(
            length: 3,
            child: Column(
              children: const [
                TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(text: "剧集"),
                    Tab(text: "概览"),
                    Tab(text: "演员"),
                  ],
                ),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      Center(child: Text("剧集")),
                      Center(child: Text("概览")),
                      Center(child: Text("演员")),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
