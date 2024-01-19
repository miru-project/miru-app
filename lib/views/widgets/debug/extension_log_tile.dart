import 'package:fluent_ui/fluent_ui.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';

class ExtensionLogTile extends StatelessWidget {
  const ExtensionLogTile({super.key, required this.log});
  final ExtensionLog log;

  @override
  Widget build(BuildContext context) {
    Color? color;

    if (log.level == ExtensionLogLevel.error) {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      color: color?.withAlpha(50),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.extension.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SelectableText(log.content),
              ],
            ),
          ),
          const Spacer(),
          if (log.extension.icon != null)
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: CacheNetWorkImagePic(
                log.extension.icon!,
                width: 32,
                height: 32,
              ),
            ),
        ],
      ),
    );
  }
}
