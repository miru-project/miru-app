import 'package:json_annotation/json_annotation.dart';
part 'anilist.g.dart';

@JsonSerializable()
class Viewer {
  final String name;
  final Avatar avatar;
  final String id;
  final Statistics statistics;

  Viewer(
      {required this.name,
      required this.id,
      required this.avatar,
      required this.statistics});

  factory Viewer.fromJson(Map<String, dynamic> json) => _$ViewerFromJson(json);
  Map<String, dynamic> toJson() => _$ViewerToJson(this);
}

@JsonSerializable()
class Avatar {
  final String medium;

  Avatar({required this.medium});

  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);
  Map<String, dynamic> toJson() => _$AvatarToJson(this);
}

@JsonSerializable()
class Statistics {
  final AnimeStatistics anime;
  final MangaStatistics manga;

  Statistics({required this.anime, required this.manga});

  factory Statistics.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsToJson(this);
}

@JsonSerializable()
class AnimeStatistics {
  final int episodesWatched;

  AnimeStatistics({required this.episodesWatched});

  factory AnimeStatistics.fromJson(Map<String, dynamic> json) =>
      _$AnimeStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$AnimeStatisticsToJson(this);
}

@JsonSerializable()
class MangaStatistics {
  final int chaptersRead;

  MangaStatistics({required this.chaptersRead});

  factory MangaStatistics.fromJson(Map<String, dynamic> json) =>
      _$MangaStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$MangaStatisticsToJson(this);
}

@JsonSerializable()
class MediaListCollection {
  final List<MediaList> lists;

  MediaListCollection({
    required this.lists,
  });

  factory MediaListCollection.fromJson(Map<String, dynamic> json) =>
      _$MediaListCollectionFromJson(json);

  Map<String, dynamic> toJson() => _$MediaListCollectionToJson(this);
}

@JsonSerializable()
class MediaList {
  final String name;
  final List<Entry> entries;

  MediaList({
    required this.name,
    required this.entries,
  });

  factory MediaList.fromJson(Map<String, dynamic> json) =>
      _$MediaListFromJson(json);

  Map<String, dynamic> toJson() => _$MediaListToJson(this);
}

@JsonSerializable()
class Entry {
  final String status;
  final int progress;
  final double score;
  final Media media;

  Entry({
    required this.status,
    required this.progress,
    required this.score,
    required this.media,
  });

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  Map<String, dynamic> toJson() => _$EntryToJson(this);
}

@JsonSerializable()
class Media {
  final String id;
  final String status;
  final int chapters;
  final int episodes;
  final double meanScore;
  final bool isFavourite;
  final CoverImage coverImage;
  final Title title;
  final String type;

  Media({
    required this.type,
    required this.id,
    required this.status,
    required this.chapters,
    required this.episodes,
    required this.meanScore,
    required this.isFavourite,
    required this.coverImage,
    required this.title,
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);

  Map<String, dynamic> toJson() => _$MediaToJson(this);
}

@JsonSerializable()
class CoverImage {
  final String large;

  CoverImage({
    required this.large,
  });

  factory CoverImage.fromJson(Map<String, dynamic> json) =>
      _$CoverImageFromJson(json);

  Map<String, dynamic> toJson() => _$CoverImageToJson(this);
}

// @JsonSerializable()
// class Title {
//   final String userPreferred;

//   Title({
//     required this.userPreferred,
//   });

//   factory Title.fromJson(Map<String, dynamic> json) => _$TitleFromJson(json);

//   Map<String, dynamic> toJson() => _$TitleToJson(this);
// }

@JsonSerializable()
class Title {
  final String romaji;
  final String english;
  final String native;
  final String userPreferred;

  Title(
      {required this.romaji,
      required this.english,
      required this.native,
      required this.userPreferred});

  factory Title.fromJson(Map<String, dynamic> json) => _$TitleFromJson(json);
  Map<String, dynamic> toJson() => _$TitleToJson(this);
}

// @JsonSerializable()
// class Media {
//   final String id;
//   final String type;
//   final CoverImage coverImage;
//   final Title title;

//   Media({required this.id, required this.type, required this.coverImage, required this.title});

//   factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
//   Map<String, dynamic> toJson() => _$MediaToJson(this);
// }

@JsonSerializable()
class PageResponse {
  final List<Media> media;

  PageResponse({required this.media});

  factory PageResponse.fromJson(Map<String, dynamic> json) =>
      _$PageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PageResponseToJson(this);
}

@JsonSerializable()
class SaveMediaListEntry {
  final int score;
  final int id;

  SaveMediaListEntry({required this.score, required this.id});

  factory SaveMediaListEntry.fromJson(Map<String, dynamic> json) =>
      _$SaveMediaListEntryFromJson(json);

  Map<String, dynamic> toJson() => _$SaveMediaListEntryToJson(this);
}
