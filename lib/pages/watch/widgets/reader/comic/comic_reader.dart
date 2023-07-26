import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/watch/widgets/reader/comic/comic_reader_content.dart';
import 'package:miru_app/pages/watch/widgets/reader/comic/comic_reader_settings.dart';
import 'package:miru_app/pages/watch/widgets/reader/comic/controller.dart';
import 'package:miru_app/pages/watch/widgets/reader/view.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:window_manager/window_manager.dart';

class ComicReader extends StatefulWidget {
  const ComicReader({
    Key? key,
    required this.title,
    required this.playList,
    required this.detailUrl,
    required this.playerIndex,
    required this.episodeGroupId,
    required this.runtime,
  }) : super(key: key);

  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playerIndex;
  final int episodeGroupId;
  final ExtensionRuntime runtime;

  @override
  State<ComicReader> createState() => _ComicReaderState();
}

class _ComicReaderState extends State<ComicReader> {
  @override
  void initState() {
    Get.put(
      ComicController(
        title: widget.title,
        playList: widget.playList,
        detailUrl: widget.detailUrl,
        playIndex: widget.playerIndex,
        episodeGroupId: widget.episodeGroupId,
        runtime: widget.runtime,
      ),
      tag: widget.title,
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ComicController>(tag: widget.title);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReadView<ComicController>(
      widget.title,
      content: DragToMoveArea(
        child: ComicReaderContent(widget.title),
      ),
      buildSettings: (context) => ComicReaderSettings(widget.title),
    );
  }
}
