import 'package:flutter/material.dart';
import 'package:miru_app/utils/color.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';

class Cover extends StatelessWidget {
  const Cover({
    Key? key,
    required this.alt,
    this.url,
    this.noText = false,
  }) : super(key: key);
  final String? url;
  final String alt;
  final bool noText;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return CacheNetWorkImagePic(
        url!,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: ColorUtils.getColorByText(alt),
      child: noText
          ? const SizedBox.expand()
          : Center(
              child: Text(
                alt,
                style: const TextStyle(
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
              ),
            ),
    );
  }
}
