// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anilist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Viewer _$ViewerFromJson(Map<String, dynamic> json) => Viewer(
      name: json['name'] as String,
      id: json['id'] as String,
      avatar: Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
      statistics:
          Statistics.fromJson(json['statistics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ViewerToJson(Viewer instance) => <String, dynamic>{
      'name': instance.name,
      'avatar': instance.avatar,
      'id': instance.id,
      'statistics': instance.statistics,
    };

Avatar _$AvatarFromJson(Map<String, dynamic> json) => Avatar(
      medium: json['medium'] as String,
    );

Map<String, dynamic> _$AvatarToJson(Avatar instance) => <String, dynamic>{
      'medium': instance.medium,
    };

Statistics _$StatisticsFromJson(Map<String, dynamic> json) => Statistics(
      anime: AnimeStatistics.fromJson(json['anime'] as Map<String, dynamic>),
      manga: MangaStatistics.fromJson(json['manga'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StatisticsToJson(Statistics instance) =>
    <String, dynamic>{
      'anime': instance.anime,
      'manga': instance.manga,
    };

AnimeStatistics _$AnimeStatisticsFromJson(Map<String, dynamic> json) =>
    AnimeStatistics(
      episodesWatched: json['episodesWatched'] as int,
    );

Map<String, dynamic> _$AnimeStatisticsToJson(AnimeStatistics instance) =>
    <String, dynamic>{
      'episodesWatched': instance.episodesWatched,
    };

MangaStatistics _$MangaStatisticsFromJson(Map<String, dynamic> json) =>
    MangaStatistics(
      chaptersRead: json['chaptersRead'] as int,
    );

Map<String, dynamic> _$MangaStatisticsToJson(MangaStatistics instance) =>
    <String, dynamic>{
      'chaptersRead': instance.chaptersRead,
    };

MediaListCollection _$MediaListCollectionFromJson(Map<String, dynamic> json) =>
    MediaListCollection(
      lists: (json['lists'] as List<dynamic>)
          .map((e) => MediaList.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MediaListCollectionToJson(
        MediaListCollection instance) =>
    <String, dynamic>{
      'lists': instance.lists,
    };

MediaList _$MediaListFromJson(Map<String, dynamic> json) => MediaList(
      name: json['name'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => Entry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MediaListToJson(MediaList instance) => <String, dynamic>{
      'name': instance.name,
      'entries': instance.entries,
    };

Entry _$EntryFromJson(Map<String, dynamic> json) => Entry(
      status: json['status'] as String,
      progress: json['progress'] as int,
      score: (json['score'] as num).toDouble(),
      media: Media.fromJson(json['media'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
      'status': instance.status,
      'progress': instance.progress,
      'score': instance.score,
      'media': instance.media,
    };

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
      endDate: StartDate.fromJson(json['endDate'] as Map<String, dynamic>),
      description: json['description'] as String,
      isAdult: json['isAdult'] as bool,
      season: json['season'] as String,
      type: json['type'] as String,
      startDate: StartDate.fromJson(json['startDate'] as Map<String, dynamic>),
      id: json['id'] as String,
      status: json['status'] as String,
      chapters: json['chapters'] as int,
      episodes: json['episodes'] as int,
      meanScore: (json['meanScore'] as num).toDouble(),
      isFavourite: json['isFavourite'] as bool,
      coverImage:
          CoverImage.fromJson(json['coverImage'] as Map<String, dynamic>),
      title: Title.fromJson(json['title'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'chapters': instance.chapters,
      'episodes': instance.episodes,
      'meanScore': instance.meanScore,
      'season': instance.season,
      'description': instance.description,
      'isFavourite': instance.isFavourite,
      'isAdult': instance.isAdult,
      'coverImage': instance.coverImage,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'title': instance.title,
      'type': instance.type,
    };

StartDate _$StartDateFromJson(Map<String, dynamic> json) => StartDate(
      year: json['year'] as int,
      month: json['month'] as int,
      day: json['day'] as int,
    );

Map<String, dynamic> _$StartDateToJson(StartDate instance) => <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
    };

CoverImage _$CoverImageFromJson(Map<String, dynamic> json) => CoverImage(
      large: json['large'] as String,
    );

Map<String, dynamic> _$CoverImageToJson(CoverImage instance) =>
    <String, dynamic>{
      'large': instance.large,
    };

Title _$TitleFromJson(Map<String, dynamic> json) => Title(
      romaji: json['romaji'] as String,
      english: json['english'] as String,
      native: json['native'] as String,
      userPreferred: json['userPreferred'] as String,
    );

Map<String, dynamic> _$TitleToJson(Title instance) => <String, dynamic>{
      'romaji': instance.romaji,
      'english': instance.english,
      'native': instance.native,
      'userPreferred': instance.userPreferred,
    };

PageResponse _$PageResponseFromJson(Map<String, dynamic> json) => PageResponse(
      media: (json['media'] as List<dynamic>)
          .map((e) => Media.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PageResponseToJson(PageResponse instance) =>
    <String, dynamic>{
      'media': instance.media,
    };

SaveMediaListEntry _$SaveMediaListEntryFromJson(Map<String, dynamic> json) =>
    SaveMediaListEntry(
      score: json['score'] as int,
      id: json['id'] as String,
    );

Map<String, dynamic> _$SaveMediaListEntryToJson(SaveMediaListEntry instance) =>
    <String, dynamic>{
      'score': instance.score,
      'id': instance.id,
    };

DeleteMediaListEntry _$DeleteMediaListEntryFromJson(
        Map<String, dynamic> json) =>
    DeleteMediaListEntry(
      deleted: json['deleted'] as bool,
    );

Map<String, dynamic> _$DeleteMediaListEntryToJson(
        DeleteMediaListEntry instance) =>
    <String, dynamic>{
      'deleted': instance.deleted,
    };
