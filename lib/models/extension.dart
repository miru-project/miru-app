import 'package:json_annotation/json_annotation.dart';

part 'extension.g.dart';

enum ExtensionType { manga, bangumi, fikushon }

enum ExtensionWatchBangumiType { hls, mp4, torrent }

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
    required this.tags,
    this.nsfw = false,
    this.icon,
    this.url,
    this.description,
    this.api,
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
  final String? icon;
  final String? url;
  final String? description;
  final int? api;
  final List<String> tags;
  factory Extension.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionToJson(this);
}

@JsonSerializable()
class ExtensionFilter {
  ExtensionFilter({
    required this.title,
    required this.min,
    required this.max,
    required this.defaultOption,
    required this.options,
  });
  final String title;
  final int min;
  final int max;
  @JsonKey(name: "default")
  final String defaultOption;
  final Map<String, String> options;

  factory ExtensionFilter.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFilterFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionFilterToJson(this);
}

@JsonSerializable()
class ExtensionListItem {
  ExtensionListItem({
    required this.title,
    required this.url,
    this.cover,
    this.update,
    this.headers,
  });

  final String title;
  final String url;
  final String? cover;
  final String? update;
  late Map<String, String>? headers;

  factory ExtensionListItem.fromJson(Map<String, dynamic> json) =>
      _$ExtensionListItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionListItemToJson(this);
}

@JsonSerializable()
class ExtensionDetail {
  ExtensionDetail({
    required this.title,
    this.cover,
    this.desc,
    this.episodes,
    this.headers,
  });

  final String title;
  final String? cover;
  final String? desc;
  final List<ExtensionEpisodeGroup>? episodes;
  late Map<String, String>? headers;

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
    this.subtitles,
    this.headers,
    this.audioTrack,
  });
  final ExtensionWatchBangumiType type;
  final String url;
  final List<ExtensionBangumiWatchSubtitle>? subtitles;
  late Map<String, String>? headers;
  late String? audioTrack;

  factory ExtensionBangumiWatch.fromJson(Map<String, dynamic> json) =>
      _$ExtensionBangumiWatchFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionBangumiWatchToJson(this);
}

@JsonSerializable()
class ExtensionBangumiWatchSubtitle {
  final String? language;
  final String title;
  final String url;
  ExtensionBangumiWatchSubtitle({
    required this.title,
    required this.url,
    this.language,
  });

  factory ExtensionBangumiWatchSubtitle.fromJson(Map<String, dynamic> json) =>
      _$ExtensionBangumiWatchSubtitleFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionBangumiWatchSubtitleToJson(this);
}

@JsonSerializable()
class ExtensionMangaWatch {
  ExtensionMangaWatch({
    required this.urls,
    this.headers,
    this.needReconstruct,
  });

  final List<String> urls;
  late Map<String, String>? headers;
  late bool? needReconstruct;
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

@JsonSerializable()
class ExtensionNetworkLog {
  final Extension extension;
  String? responseBody;
  String? requestBody;
  Map<String, dynamic>? requestHeaders;
  Map<String, dynamic>? responseHeaders;
  String url;
  String method;
  int? statusCode;

  ExtensionNetworkLog({
    required this.extension,
    required this.url,
    required this.method,
    this.statusCode,
    this.responseBody,
    this.requestBody,
    this.requestHeaders,
    this.responseHeaders,
  });

  factory ExtensionNetworkLog.fromJson(Map<String, dynamic> json) =>
      _$ExtensionNetworkLogFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionNetworkLogToJson(this);
}

@JsonSerializable()
class ReconstructPicVertex {
  final double sx1;
  final double sy1;
  final double sx2;
  final double sy2;
  final double dx1;
  final double dy1;
  final double dx2;
  final double dy2;

  ReconstructPicVertex({
    required this.sx1,
    required this.sy1,
    required this.sx2,
    required this.sy2,
    required this.dx1,
    required this.dy1,
    required this.dx2,
    required this.dy2,
  });

  factory ReconstructPicVertex.fromJson(Map<String, dynamic> json) {
    return ReconstructPicVertex(
      sx1: json['sx1'].toDouble(),
      sy1: json['sy1'].toDouble(),
      sx2: json['sx2'].toDouble(),
      sy2: json['sy2'].toDouble(),
      dx1: json['dx1'].toDouble(),
      dy1: json['dy1'].toDouble(),
      dx2: json['dx2'].toDouble(),
      dy2: json['dy2'].toDouble(),
    );
  }
  @override
  String toString() {
    return 'ReconstructPicVertex(sx1: $sx1, sy1: $sy1, sx2: $sx2, sy2: $sy2, dx1: $dx1, dy1: $dy1, dx2: $dx2, dy2: $dy2)';
  }
}
