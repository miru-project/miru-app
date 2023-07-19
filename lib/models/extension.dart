import 'package:json_annotation/json_annotation.dart';
import 'package:miru_app/widgets/extension_item_card.dart';

part 'extension.g.dart';

enum ExtensionType { manga, bangumi, fikushon }

enum ExtensionWatchBangumiType { hls, mp4 }

enum ExtensionLogLevel {
  info,
  error,
}

@JsonSerializable()
class Extension {
  Extension({
    required this.package,
    required this.author,
    required this.version,
    required this.lang,
    required this.license,
    required this.type,
    required this.webSite,
    required this.name,
    this.nsfw = false,
    this.icon,
    this.url,
    this.description,
  });

  final bool nsfw;
  final String package;
  final String author;
  final String version;
  final String lang;
  final String license;
  final ExtensionType type;
  final String webSite;
  final String name;
  String? icon;
  String? url;
  String? description;

  factory Extension.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionToJson(this);
}

@JsonSerializable()
class ExtensionListItem {
  ExtensionListItem({
    required this.title,
    required this.url,
    required this.cover,
    this.update,
  });

  final String title;
  final String url;
  final String cover;
  final String? update;

  factory ExtensionListItem.fromJson(Map<String, dynamic> json) =>
      _$ExtensionListItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionListItemToJson(this);

  map(ExtensionItemCard Function(dynamic e) param0) {}
}

@JsonSerializable()
class ExtensionDetail {
  ExtensionDetail({
    required this.title,
    required this.cover,
    this.desc,
    this.episodes,
  });

  final String title;
  final String cover;
  final String? desc;
  final List<ExtensionEpisodeGroup>? episodes;

  factory ExtensionDetail.fromJson(Map<String, dynamic> json) =>
      _$ExtensionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionDetailToJson(this);
}

@JsonSerializable()
class ExtensionEpisodeGroup {
  ExtensionEpisodeGroup({
    required this.title,
    required this.urls,
  });
  final String title;
  final List<ExtensionEpisode> urls;

  factory ExtensionEpisodeGroup.fromJson(Map<String, dynamic> json) =>
      _$ExtensionEpisodeGroupFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionEpisodeGroupToJson(this);
}

@JsonSerializable()
class ExtensionEpisode {
  ExtensionEpisode({
    required this.name,
    required this.url,
  });
  final String name;
  final String url;

  factory ExtensionEpisode.fromJson(Map<String, dynamic> json) =>
      _$ExtensionEpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionEpisodeToJson(this);
}

@JsonSerializable()
class ExtensionBangumiWatch {
  ExtensionBangumiWatch({
    required this.type,
    required this.url,
  });
  final ExtensionWatchBangumiType type;
  final String url;

  factory ExtensionBangumiWatch.fromJson(Map<String, dynamic> json) =>
      _$ExtensionBangumiWatchFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionBangumiWatchToJson(this);
}

@JsonSerializable()
class ExtensionMangaWatch {
  final List<String> urls;
  ExtensionMangaWatch({
    required this.urls,
  });

  factory ExtensionMangaWatch.fromJson(Map<String, dynamic> json) =>
      _$ExtensionMangaWatchFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionMangaWatchToJson(this);
}

@JsonSerializable()
class ExtensionFikushonWatch {
  final List<String> content;
  final String title;
  final String? subtitle;
  ExtensionFikushonWatch({
    required this.content,
    required this.title,
    this.subtitle,
  });

  factory ExtensionFikushonWatch.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFikushonWatchFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionFikushonWatchToJson(this);
}

@JsonSerializable()
class ExtensionLog {
  ExtensionLog({
    required this.extension,
    required this.content,
    required this.time,
    required this.level,
  });

  final DateTime time;
  final Extension extension;
  final String content;
  final ExtensionLogLevel level;

  factory ExtensionLog.fromJson(Map<String, dynamic> json) =>
      _$ExtensionLogFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionLogToJson(this);
}
