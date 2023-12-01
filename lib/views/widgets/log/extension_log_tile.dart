import 'package:fluent_ui/fluent_ui.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';

class ExtensionLogTile extends StatelessWidget {
  const ExtensionLogTile({Key? key, required this.log}) : super(key: key);
  final ExtensionLog log;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            color: log.level == ExtensionLogLevel.error
                ? Colors.red
                : Colors.green,
            child: Text(log.time.toString()),
          ),
          const SizedBox(width: 10),
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
