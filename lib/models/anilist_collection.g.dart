// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anilist_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaListCollection _$MediaListCollectionFromJson(Map<String, dynamic> json) =>
    MediaListCollection(
      userId: json['userId'] as String,
      type: json['type'] as String,
      lists: (json['lists'] as List<dynamic>)
          .map((e) => MediaList.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MediaListCollectionToJson(
        MediaListCollection instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'type': instance.type,
      'lists': instance.lists,
      'user': instance.user,
    };

MediaList _$MediaListFromJson(Map<String, dynamic> json) => MediaList(
      name: json['name'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => MediaEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MediaListToJson(MediaList instance) => <String, dynamic>{
      'name': instance.name,
      'entries': instance.entries,
    };

MediaEntry _$MediaEntryFromJson(Map<String, dynamic> json) => MediaEntry(
      status: json['status'] as String,
      progress: json['progress'] as int,
      score: json['score'] as int?,
      media: Media.fromJson(json['media'] as Map<String, dynamic>),
      isFavourite: json['isFavourite'] as bool?,
    );

Map<String, dynamic> _$MediaEntryToJson(MediaEntry instance) =>
    <String, dynamic>{
      'status': instance.status,
      'progress': instance.progress,
      'score': instance.score,
      'media': instance.media,
      'isFavourite': instance.isFavourite,
    };

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
      id: json['id'] as String,
      isAdult: json['isAdult'] as bool,
      status: json['status'] as String,
      chapters: json['chapters'] as int?,
      episodes: json['episodes'] as int?,
      nextAiringEpisode: json['nextAiringEpisode'] as int?,
      bannerImage: json['bannerImage'] as String,
      meanScore: (json['meanScore'] as num).toDouble(),
      coverImageMedium: json['coverImageMedium'] as String?,
      title: Title.fromJson(json['title'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
      'id': instance.id,
      'isAdult': instance.isAdult,
      'status': instance.status,
      'chapters': instance.chapters,
      'episodes': instance.episodes,
      'nextAiringEpisode': instance.nextAiringEpisode,
      'bannerImage': instance.bannerImage,
      'meanScore': instance.meanScore,
      'coverImageMedium': instance.coverImageMedium,
      'title': instance.title,
    };

Title _$TitleFromJson(Map<String, dynamic> json) => Title(
      english: json['english'] as String?,
      romaji: json['romaji'] as String,
      userPreferred: json['userPreferred'] as String?,
    );

Map<String, dynamic> _$TitleToJson(Title instance) => <String, dynamic>{
      'english': instance.english,
      'romaji': instance.romaji,
      'userPreferred': instance.userPreferred,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      mediaListOptions: MediaListOptions.fromJson(
          json['mediaListOptions'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'mediaListOptions': instance.mediaListOptions,
    };

MediaListOptions _$MediaListOptionsFromJson(Map<String, dynamic> json) =>
    MediaListOptions(
      rowOrder:
          (json['rowOrder'] as List<dynamic>).map((e) => e as String).toList(),
      animeList: AnimeListSectionOrder.fromJson(
          json['animeList'] as Map<String, dynamic>),
      mangaList: MangaListSectionOrder.fromJson(
          json['mangaList'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MediaListOptionsToJson(MediaListOptions instance) =>
    <String, dynamic>{
      'rowOrder': instance.rowOrder,
      'animeList': instance.animeList,
      'mangaList': instance.mangaList,
    };

AnimeListSectionOrder _$AnimeListSectionOrderFromJson(
        Map<String, dynamic> json) =>
    AnimeListSectionOrder(
      sectionOrder: (json['sectionOrder'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AnimeListSectionOrderToJson(
        AnimeListSectionOrder instance) =>
    <String, dynamic>{
      'sectionOrder': instance.sectionOrder,
    };

MangaListSectionOrder _$MangaListSectionOrderFromJson(
        Map<String, dynamic> json) =>
    MangaListSectionOrder(
      sectionOrder: (json['sectionOrder'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MangaListSectionOrderToJson(
        MangaListSectionOrder instance) =>
    <String, dynamic>{
      'sectionOrder': instance.sectionOrder,
    };
