import 'package:isar/isar.dart';

part 'manga_setting.g.dart';

enum MangaReadMode {
  // 标准 从左到右
  standard,
  // 从右到左
  rightToLeft,
  // 条漫
  webTonn,
}

@collection
class MangaSetting {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String url;
  @Enumerated(EnumType.name)
  late MangaReadMode readMode;
}
