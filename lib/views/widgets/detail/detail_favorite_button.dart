import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class DetailFavoriteButton extends StatefulWidget {
  const DetailFavoriteButton({
    super.key,
    this.tag,
  });
  final String? tag;

  @override
  fluent.State<DetailFavoriteButton> createState() =>
      _DetailFavoriteButtonState();
}

class _DetailFavoriteButtonState extends State<DetailFavoriteButton> {
  late DetailPageController c = Get.find<DetailPageController>(tag: widget.tag);

  Widget _buildMobile(BuildContext context) {
    return Obx(
      () {
        final isFavorite = c.isFavorite.value;
        return OutlinedButton.icon(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          label: Text(
            isFavorite ? 'detail.favorited'.i18n : 'detail.favorite'.i18n,
          ),
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(
              const Size(double.infinity, 50),
            ),
            backgroundColor: isFavorite
                ? MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primary)
                : null,
            foregroundColor: isFavorite
                ? MaterialStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary)
                : null,
          ),
          onPressed: () async {
            await c.toggleFavorite();
          },
        );
      },
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Obx(() {
      final isFavorite = c.isFavorite.value;
      return fluent.FilledButton(
        onPressed: () async {
          await c.toggleFavorite();
        },
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isFavorite
                ? [
                    Text('detail.favorited'.i18n),
                    const SizedBox(width: 8),
                    const Icon(fluent.FluentIcons.favorite_star_fill)
                  ]
                : [
                    Text('detail.favorite'.i18n),
                    const SizedBox(width: 8),
                    const Icon(fluent.FluentIcons.favorite_star)
                  ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
