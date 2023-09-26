import 'package:isar/isar.dart';
import 'package:miru_app/models/extension.dart';

part 'history.g.dart';

@collection
class History {
  Id id = Isar.autoIncrement;
  @Index(name: 'package&url', composite: [CompositeIndex('url')])
  late String package;
  late String url;
  // 截图，保存封面地址
  String? cover;
  @Enumerated(EnumType.name)
  late ExtensionType type;
  // 不同线路
  late int episodeGroupId;
  // 不同线路下的集数
  late int episodeId;
  // 显示的标题
  late String title;
  // 进度标题
  late String episodeTitle;
  // 当前剧集/章节进度
  late String progress;
  // 当前章节/剧集总进度
  late String totalProgress;
  DateTime date = DateTime.now();
}
