import 'package:isar/isar.dart';
import 'package:miru_app/models/extension.dart';

part 'favorite.g.dart';

@collection
class Favorite {
  Id id = Isar.autoIncrement;
  @Index(composite: [CompositeIndex('url')])
  late String package;
  late String url;
  @Enumerated(EnumType.name)
  late ExtensionType type;
  late String title;
  String? cover;
  DateTime date = DateTime.now();
}
