import 'package:flutter/material.dart';
import 'package:miru_app/pages/home/index.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack 保持页面状态
      body: IndexedStack(
        index: index,
        children: const [
          HomePage(),
          Center(child: Text("探索")),
          Center(child: Text("扩展")),
          Center(child: Text("设置")),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "首页",
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            label: "探索",
            selectedIcon: Icon(Icons.search),
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            label: "扩展",
            selectedIcon: Icon(Icons.apps),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: "设置",
            selectedIcon: Icon(Icons.settings),
          ),
        ],
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() {
          index = value;
        }),
      ),
    );
  }
}
