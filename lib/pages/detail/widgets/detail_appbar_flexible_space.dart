import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/detail/controller.dart';
import 'package:miru_app/pages/detail/widgets/detail_continue_play.dart';
import 'package:miru_app/pages/detail/widgets/detail_favorite_button.dart';
import 'package:miru_app/widgets/cache_network_image.dart';

class DetailAppbarflexibleSpace extends StatefulWidget {
  const DetailAppbarflexibleSpace({
    Key? key,
  }) : super(key: key);

  @override
  State<DetailAppbarflexibleSpace> createState() =>
      _DetailAppbarflexibleSpaceState();
}

class _DetailAppbarflexibleSpaceState extends State<DetailAppbarflexibleSpace> {
  final DetailPageController c = Get.find();
  late ExtensionDetail data = c.data.value!;

  double _offset = 1;

  @override
  void initState() {
    c.scrollController.addListener(() {
      setState(() {
        _offset = c.scrollController.offset;
      });
    });
    super.initState();
  }

  double _scrollListener() {
    if (_offset <= 0) {
      return 1;
    } else if (_offset >= 300) {
      return 0;
    } else {
      return (_offset - 300) / (0 - 300);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _scrollListener(),
      child: Stack(
        children: [
          CacheNetWorkImage(
            data.cover,
            height: 400,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // 主题背景色
                    Theme.of(context).colorScheme.background.withOpacity(0.3),
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.background,
                  ],
                ),
              ),
            ),
          ),
          // flex 左边封面右边标题
          Positioned(
            left: 20,
            bottom: 105,
            right: 20,
            child: Row(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: 150,
                    width: 100,
                    child: CacheNetWorkImage(
                      data.cover,
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        softWrap: true,
                        style: Get.theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (data.desc ?? ''),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ))
              ],
            ),
          ),
          const Positioned(
            top: null,
            left: 20,
            right: 20,
            bottom: 40,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DetailContinuePlay(),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: DetailFavoriteButton(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
