import 'package:json_annotation/json_annotation.dart';
part 'anilist_collection.g.dart';

@JsonSerializable()
class MediaListCollection {
  final String userId;
  final String type;
  final List<MediaList> lists;
  final User user;

  MediaListCollection({
    required this.userId,
    required this.type,
    required this.lists,
    required this.user,
  });

  factory MediaListCollection.fromJson(Map<String, dynamic> json) =>
      _$MediaListCollectionFromJson(json);
}

@JsonSerializable()
class MediaList {
  final String name;
  final List<MediaEntry> entries;

  MediaList({
    required this.name,
    required this.entries,
  });

  factory MediaList.fromJson(Map<String, dynamic> json) =>
      _$MediaListFromJson(json);
}

@JsonSerializable()
class MediaEntry {
  final String status;
  final int progress;
  final int? score;
  final Media media;
  final bool? isFavourite;

  MediaEntry({
    required this.status,
    required this.progress,
    this.score,
    required this.media,
    this.isFavourite,
  });

  factory MediaEntry.fromJson(Map<String, dynamic> json) =>
      _$MediaEntryFromJson(json);
}

@JsonSerializable()
class Media {
  final String id;
  final bool isAdult;
  final String status;
  final int? chapters;
  final int? episodes;
  final int? nextAiringEpisode;
  final String bannerImage;
  final double meanScore;
  final String? coverImageMedium;
  final Title title;

  Media({
    required this.id,
    required this.isAdult,
    required this.status,
    this.chapters,
    this.episodes,
    this.nextAiringEpisode,
    required this.bannerImage,
    required this.meanScore,
    this.coverImageMedium,
    required this.title,
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}

@JsonSerializable()
class Title {
  final String? english;
  final String romaji;
  final String? userPreferred;

  Title({
    this.english,
    required this.romaji,
    this.userPreferred,
  });

  factory Title.fromJson(Map<String, dynamic> json) => _$TitleFromJson(json);
}

@JsonSerializable()
class User {
  final MediaListOptions mediaListOptions;

  User({required this.mediaListOptions});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@JsonSerializable()
class MediaListOptions {
  final List<String> rowOrder;
  final AnimeListSectionOrder animeList;
  final MangaListSectionOrder mangaList;

  MediaListOptions({
    required this.rowOrder,
    required this.animeList,
    required this.mangaList,
  });

  factory MediaListOptions.fromJson(Map<String, dynamic> json) =>
      _$MediaListOptionsFromJson(json);
}

@JsonSerializable()
class AnimeListSectionOrder {
  final List<String> sectionOrder;

  AnimeListSectionOrder({required this.sectionOrder});

  factory AnimeListSectionOrder.fromJson(Map<String, dynamic> json) =>
      _$AnimeListSectionOrderFromJson(json);
}

@JsonSerializable()
class MangaListSectionOrder {
  final List<String> sectionOrder;

  MangaListSectionOrder({required this.sectionOrder});

  factory MangaListSectionOrder.fromJson(Map<String, dynamic> json) =>
      _$MangaListSectionOrderFromJson(json);
}
