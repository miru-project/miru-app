import 'package:flutter/material.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.content,
  }) : super(key: key);
  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            content,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Expanded(
              child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          )),
        ],
      ),
      desktopWidget: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 4),
                Text(content),
              ],
            ),
          )
        ],
      ),
    );
  }
}
