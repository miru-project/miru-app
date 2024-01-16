import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/views/pages/watch/reader/comic/comic_reader_content.dart';
import 'package:miru_app/views/pages/watch/reader/comic/comic_reader_settings.dart';
import 'package:miru_app/controllers/watch/comic_controller.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
// import 'package:miru_app/views/pages/watch/reader/comic/comic_zoom.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/views/widgets/watch/reader_view.dart';
import 'package:window_manager/window_manager.dart';

class ComicReader extends StatefulWidget {
  const ComicReader({
    super.key,
    required this.title,
    required this.playList,
    required this.detailUrl,
    required this.playerIndex,
    required this.episodeGroupId,
    required this.runtime,
    required this.anilistID,
    this.cover,
  });

  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playerIndex;
  final int episodeGroupId;
  final ExtensionService runtime;
  final String? cover;
  final String anilistID;

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
        cover: widget.cover,
        anilistID: widget.anilistID,
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
    return ReaderView<ComicController>(
      widget.title,
      content: PlatformWidget(
          androidWidget: ComicReaderContent(widget.title),
          desktopWidget: DragToMoveArea(
            child: ComicReaderContent(widget.title),
          )),
      buildSettings: (context) => ComicReaderSettings(widget.title),
    );
  }
}
