import 'package:isar/isar.dart';

part 'miru_detail.g.dart';

@collection
class MiruDetail {
  Id id = Isar.autoIncrement;
  @Index(name: 'package&url', composite: [CompositeIndex('url')])
  late String package;
  late String url;
  late String data;
  int? tmdbID;
  DateTime updateTime = DateTime.now();
  String? aniListID;
}
