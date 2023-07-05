import 'package:isar/isar.dart';
import 'package:miru_app/models/extension.dart';

part 'history.g.dart';

@collection
class History {
  Id id = Isar.autoIncrement;
  @Index(composite: [CompositeIndex('url')])
  late String package;
  late String url;
  // 截图，保存封面地址
  late String cover;
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
  DateTime date = DateTime.now();
}
