import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/detail/controller.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/widgets/cache_network_image.dart';

class DetailExtensionTile extends StatelessWidget {
  const DetailExtensionTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DetailPageController>();
    return Obx(() {
      if (c.extension == null) {
        return const SizedBox.shrink();
      }
      return Row(
        children: [
          if (c.extension!.icon != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: CacheNetWorkImage(
                c.extension!.icon!,
                width: 20,
              ),
            ),
          Text(
            c.extension!.name,
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => Text(
              ExtensionUtils.typeToString(c.type),
            ),
          ),
        ],
      );
    });
  }
}
