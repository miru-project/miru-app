// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTMDBCollection on Isar {
  IsarCollection<TMDB> get tMDBs => this.collection();
}

const TMDBSchema = CollectionSchema(
  name: r'TMDB',
  id: -4342917064049127585,
  properties: {
    r'data': PropertySchema(
      id: 0,
      name: r'data',
      type: IsarType.string,
    ),
    r'mediaType': PropertySchema(
      id: 1,
      name: r'mediaType',
      type: IsarType.string,
    ),
    r'tmdbID': PropertySchema(
      id: 2,
      name: r'tmdbID',
      type: IsarType.long,
    )
  },
  estimateSize: _tMDBEstimateSize,
  serialize: _tMDBSerialize,
  deserialize: _tMDBDeserialize,
  deserializeProp: _tMDBDeserializeProp,
  idName: r'id',
  indexes: {
    r'tmdbID': IndexSchema(
      id: 8362136059549777794,
      name: r'tmdbID',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tmdbID',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _tMDBGetId,
  getLinks: _tMDBGetLinks,
  attach: _tMDBAttach,
  version: '3.1.0+1',
);

int _tMDBEstimateSize(
  TMDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.data.length * 3;
  bytesCount += 3 + object.mediaType.length * 3;
  return bytesCount;
}

void _tMDBSerialize(
  TMDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.data);
  writer.writeString(offsets[1], object.mediaType);
  writer.writeLong(offsets[2], object.tmdbID);
}

TMDB _tMDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TMDB();
  object.data = reader.readString(offsets[0]);
  object.id = id;
  object.mediaType = reader.readString(offsets[1]);
  object.tmdbID = reader.readLong(offsets[2]);
  return object;
}

P _tMDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tMDBGetId(TMDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tMDBGetLinks(TMDB object) {
  return [];
}

void _tMDBAttach(IsarCollection<dynamic> col, Id id, TMDB object) {
  object.id = id;
}

extension TMDBByIndex on IsarCollection<TMDB> {
  Future<TMDB?> getByTmdbID(int tmdbID) {
    return getByIndex(r'tmdbID', [tmdbID]);
  }

  TMDB? getByTmdbIDSync(int tmdbID) {
    return getByIndexSync(r'tmdbID', [tmdbID]);
  }

  Future<bool> deleteByTmdbID(int tmdbID) {
    return deleteByIndex(r'tmdbID', [tmdbID]);
  }

  bool deleteByTmdbIDSync(int tmdbID) {
    return deleteByIndexSync(r'tmdbID', [tmdbID]);
  }

  Future<List<TMDB?>> getAllByTmdbID(List<int> tmdbIDValues) {
    final values = tmdbIDValues.map((e) => [e]).toList();
    return getAllByIndex(r'tmdbID', values);
  }

  List<TMDB?> getAllByTmdbIDSync(List<int> tmdbIDValues) {
    final values = tmdbIDValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'tmdbID', values);
  }

  Future<int> deleteAllByTmdbID(List<int> tmdbIDValues) {
    final values = tmdbIDValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'tmdbID', values);
  }

  int deleteAllByTmdbIDSync(List<int> tmdbIDValues) {
    final values = tmdbIDValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'tmdbID', values);
  }

  Future<Id> putByTmdbID(TMDB object) {
    return putByIndex(r'tmdbID', object);
  }

  Id putByTmdbIDSync(TMDB object, {bool saveLinks = true}) {
    return putByIndexSync(r'tmdbID', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTmdbID(List<TMDB> objects) {
    return putAllByIndex(r'tmdbID', objects);
  }

  List<Id> putAllByTmdbIDSync(List<TMDB> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'tmdbID', objects, saveLinks: saveLinks);
  }
}

extension TMDBQueryWhereSort on QueryBuilder<TMDB, TMDB, QWhere> {
  QueryBuilder<TMDB, TMDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhere> anyTmdbID() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'tmdbID'),
      );
    });
  }
}

extension TMDBQueryWhere on QueryBuilder<TMDB, TMDB, QWhereClause> {
  QueryBuilder<TMDB, TMDB, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhereClause> tmdbIDEqualTo(int tmdbID) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tmdbID',
        value: [tmdbID],
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhereClause> tmdbIDNotEqualTo(int tmdbID) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tmdbID',
              lower: [],
              upper: [tmdbID],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tmdbID',
              lower: [tmdbID],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tmdbID',
              lower: [tmdbID],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tmdbID',
              lower: [],
              upper: [tmdbID],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhereClause> tmdbIDGreaterThan(
    int tmdbID, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tmdbID',
        lower: [tmdbID],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhereClause> tmdbIDLessThan(
    int tmdbID, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tmdbID',
        lower: [],
        upper: [tmdbID],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterWhereClause> tmdbIDBetween(
    int lowerTmdbID,
    int upperTmdbID, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tmdbID',
        lower: [lowerTmdbID],
        includeLower: includeLower,
        upper: [upperTmdbID],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TMDBQueryFilter on QueryBuilder<TMDB, TMDB, QFilterCondition> {
  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> dataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaType',
        value: '',
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> mediaTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaType',
        value: '',
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> tmdbIDEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbID',
        value: value,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> tmdbIDGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tmdbID',
        value: value,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> tmdbIDLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tmdbID',
        value: value,
      ));
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterFilterCondition> tmdbIDBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tmdbID',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TMDBQueryObject on QueryBuilder<TMDB, TMDB, QFilterCondition> {}

extension TMDBQueryLinks on QueryBuilder<TMDB, TMDB, QFilterCondition> {}

extension TMDBQuerySortBy on QueryBuilder<TMDB, TMDB, QSortBy> {
  QueryBuilder<TMDB, TMDB, QAfterSortBy> sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> sortByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> sortByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> sortByTmdbID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbID', Sort.asc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> sortByTmdbIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbID', Sort.desc);
    });
  }
}

extension TMDBQuerySortThenBy on QueryBuilder<TMDB, TMDB, QSortThenBy> {
  QueryBuilder<TMDB, TMDB, QAfterSortBy> thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> thenByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> thenByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> thenByTmdbID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbID', Sort.asc);
    });
  }

  QueryBuilder<TMDB, TMDB, QAfterSortBy> thenByTmdbIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbID', Sort.desc);
    });
  }
}

extension TMDBQueryWhereDistinct on QueryBuilder<TMDB, TMDB, QDistinct> {
  QueryBuilder<TMDB, TMDB, QDistinct> distinctByData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TMDB, TMDB, QDistinct> distinctByMediaType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TMDB, TMDB, QDistinct> distinctByTmdbID() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbID');
    });
  }
}

extension TMDBQueryProperty on QueryBuilder<TMDB, TMDB, QQueryProperty> {
  QueryBuilder<TMDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TMDB, String, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<TMDB, String, QQueryOperations> mediaTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaType');
    });
  }

  QueryBuilder<TMDB, int, QQueryOperations> tmdbIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbID');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TMDBDetail _$TMDBDetailFromJson(Map<String, dynamic> json) => TMDBDetail(
      id: json['id'] as int,
      mediaType: json['mediaType'] as String,
      title: json['title'] as String,
      cover: json['cover'] as String,
      backdrop: json['backdrop'] as String?,
      genres:
          (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      overview: json['overview'] as String?,
      status: json['status'] as String,
      casts: (json['casts'] as List<dynamic>)
          .map((e) => TMDBCast.fromJson(e as Map<String, dynamic>))
          .toList(),
      releaseDate: json['releaseDate'] as String,
      runtime: json['runtime'] as int,
      originalTitle: json['originalTitle'] as String,
    );

Map<String, dynamic> _$TMDBDetailToJson(TMDBDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mediaType': instance.mediaType,
      'title': instance.title,
      'cover': instance.cover,
      'backdrop': instance.backdrop,
      'genres': instance.genres,
      'languages': instance.languages,
      'images': instance.images,
      'overview': instance.overview,
      'status': instance.status,
      'casts': instance.casts,
      'releaseDate': instance.releaseDate,
      'runtime': instance.runtime,
      'originalTitle': instance.originalTitle,
    };

TMDBCast _$TMDBCastFromJson(Map<String, dynamic> json) => TMDBCast(
      id: json['id'] as int,
      name: json['name'] as String,
      profilePath: json['profilePath'] as String?,
      character: json['character'] as String,
    );

Map<String, dynamic> _$TMDBCastToJson(TMDBCast instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profilePath': instance.profilePath,
      'character': instance.character,
    };
