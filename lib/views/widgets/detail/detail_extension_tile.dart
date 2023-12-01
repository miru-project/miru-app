import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';

class DetailExtensionTile extends StatelessWidget {
  const DetailExtensionTile({
    Key? key,
    this.tag,
  }) : super(key: key);

  final String? tag;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DetailPageController>(tag: tag);
    return Obx(() {
      if (c.extension == null) {
        return Text(FlutterI18n.translate(
          context,
          'common.extension-missing',
          translationParams: {
            'package': c.package,
          },
        ));
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
              child: CacheNetWorkImagePic(
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
