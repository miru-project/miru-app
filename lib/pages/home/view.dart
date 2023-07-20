import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/home/controller.dart';
import 'package:miru_app/pages/home/widgets/home_favorites.dart';
import 'package:miru_app/pages/home/widgets/home_recent.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageController c;

  @override
  void initState() {
    c = Get.put(HomePageController());
    super.initState();
  }

  Widget _buildContent() {
    return Obx(
      () {
        if (c.resents.isEmpty && c.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "（＞人＜；）",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "home.no-record".i18n,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.resents.isNotEmpty) ...[
                  HomeRecent(
                    data: c.resents,
                  ),
                  const SizedBox(height: 16),
                ],
                if (c.favorites.isNotEmpty)
                  HomeFavorites(
                    data: c.favorites,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAndroidHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("common.home".i18n),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildDesktopHome(BuildContext context) {
    return _buildContent();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroidHome,
      desktopBuilder: _buildDesktopHome,
    );
  }
}
