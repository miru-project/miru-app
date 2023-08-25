import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tmdb.g.dart';

@collection
class TMDB {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late int tmdbID;
  late String data;
  late String mediaType;
}

@JsonSerializable()
class TMDBDetail {
  TMDBDetail({
    required this.id,
    required this.mediaType,
    required this.title,
    required this.cover,
    this.backdrop,
    required this.genres,
    required this.languages,
    required this.images,
    this.overview,
    required this.status,
    required this.casts,
    required this.releaseDate,
    required this.runtime,
    required this.originalTitle,
  });
  final int id;
  final String mediaType;
  final String title;
  final String cover;
  String? backdrop;
  final List<String> genres;
  final List<String> languages;
  final List<String> images;
  String? overview;
  final String status;
  final List<TMDBCast> casts;
  final String releaseDate;
  final int runtime;
  final String originalTitle;

  factory TMDBDetail.fromJson(Map<String, dynamic> json) =>
      _$TMDBDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TMDBDetailToJson(this);
}

@JsonSerializable()
class TMDBCast {
  TMDBCast({
    required this.id,
    required this.name,
    this.profilePath,
    required this.character,
  });
  final int id;
  final String name;
  String? profilePath;
  final String character;

  factory TMDBCast.fromJson(Map<String, dynamic> json) =>
      _$TMDBCastFromJson(json);

  Map<String, dynamic> toJson() => _$TMDBCastToJson(this);
}
