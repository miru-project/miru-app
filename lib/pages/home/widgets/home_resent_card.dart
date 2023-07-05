import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/main.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/pages/detail/view.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class HomeRecentCard extends StatefulWidget {
  const HomeRecentCard({
    Key? key,
    required this.history,
  }) : super(key: key);
  final History history;

  @override
  State<HomeRecentCard> createState() => _HomeRecentCardState();
}

class _HomeRecentCardState extends State<HomeRecentCard> {
  late ExtensionRuntime? runtime;
  String update = "";

  @override
  void initState() {
    _getUpdate();
    super.initState();
  }

  _getUpdate() async {
    runtime = ExtensionUtils.extensions[widget.history.package];
    if (runtime == null) {
      return;
    }
    update = await runtime!.checkUpdate(widget.history.url);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (Platform.isAndroid) {
              Get.to(
                DetailPage(
                    url: widget.history.url, package: widget.history.package),
              );
              return;
            }
            router.push(
              Uri(
                path: '/detail',
                queryParameters: {
                  "url": widget.history.url,
                  "package": widget.history.package,
                },
              ).toString(),
            );
          },
          child: Container(
            width: 350,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Image.file(
                  File(widget.history.cover),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 350,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.history.title,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                "看到 ${widget.history.episodeTitle}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (update.isNotEmpty)
                            Text(
                              update,
                              style: const TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
