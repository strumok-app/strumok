// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestion_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSearchSuggestionCollection on Isar {
  IsarCollection<SearchSuggestion> get searchSuggestions => this.collection();
}

const SearchSuggestionSchema = CollectionSchema(
  name: r'SearchSuggestion',
  id: -8732962765611758593,
  properties: {
    r'fts': PropertySchema(id: 0, name: r'fts', type: IsarType.stringList),
    r'lastSeen': PropertySchema(
      id: 1,
      name: r'lastSeen',
      type: IsarType.dateTime,
    ),
    r'text': PropertySchema(id: 2, name: r'text', type: IsarType.string),
  },

  estimateSize: _searchSuggestionEstimateSize,
  serialize: _searchSuggestionSerialize,
  deserialize: _searchSuggestionDeserialize,
  deserializeProp: _searchSuggestionDeserializeProp,
  idName: r'id',
  indexes: {
    r'fts': IndexSchema(
      id: -5788315140141019102,
      name: r'fts',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fts',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _searchSuggestionGetId,
  getLinks: _searchSuggestionGetLinks,
  attach: _searchSuggestionAttach,
  version: '3.1.8',
);

int _searchSuggestionEstimateSize(
  SearchSuggestion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fts.length * 3;
  {
    for (var i = 0; i < object.fts.length; i++) {
      final value = object.fts[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _searchSuggestionSerialize(
  SearchSuggestion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.fts);
  writer.writeDateTime(offsets[1], object.lastSeen);
  writer.writeString(offsets[2], object.text);
}

SearchSuggestion _searchSuggestionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SearchSuggestion(
    id: id,
    lastSeen: reader.readDateTime(offsets[1]),
    text: reader.readString(offsets[2]),
  );
  return object;
}

P _searchSuggestionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _searchSuggestionGetId(SearchSuggestion object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _searchSuggestionGetLinks(SearchSuggestion object) {
  return [];
}

void _searchSuggestionAttach(
  IsarCollection<dynamic> col,
  Id id,
  SearchSuggestion object,
) {}

extension SearchSuggestionQueryWhereSort
    on QueryBuilder<SearchSuggestion, SearchSuggestion, QWhere> {
  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhere>
  anyFtsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'fts'),
      );
    });
  }
}

extension SearchSuggestionQueryWhere
    on QueryBuilder<SearchSuggestion, SearchSuggestion, QWhereClause> {
  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  ftsElementEqualTo(String ftsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'fts', value: [ftsElement]),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  ftsElementNotEqualTo(String ftsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fts',
                lower: [],
                upper: [ftsElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fts',
                lower: [ftsElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fts',
                lower: [ftsElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fts',
                lower: [],
                upper: [ftsElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  ftsElementGreaterThan(String ftsElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'fts',
          lower: [ftsElement],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  ftsElementLessThan(String ftsElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'fts',
          lower: [],
          upper: [ftsElement],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  ftsElementBetween(
    String lowerFtsElement,
    String upperFtsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'fts',
          lower: [lowerFtsElement],
          includeLower: includeLower,
          upper: [upperFtsElement],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  ftsElementStartsWith(String FtsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'fts',
          lower: [FtsElementPrefix],
          upper: ['$FtsElementPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  ftsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'fts', value: ['']),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterWhereClause>
  ftsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'fts', upper: ['']),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'fts', lower: ['']),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'fts', lower: ['']),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'fts', upper: ['']),
            );
      }
    });
  }
}

extension SearchSuggestionQueryFilter
    on QueryBuilder<SearchSuggestion, SearchSuggestion, QFilterCondition> {
  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fts',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fts',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fts', value: ''),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fts', value: ''),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', length, true, length, true);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', 0, true, 0, true);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', 0, false, 999999, true);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', 0, true, length, include);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', length, include, 999999, true);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  ftsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  idGreaterThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  idLessThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  lastSeenEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSeen', value: value),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  lastSeenGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSeen',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  lastSeenLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSeen',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  lastSeenBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSeen',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'text',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'text',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterFilterCondition>
  textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'text', value: ''),
      );
    });
  }
}

extension SearchSuggestionQueryObject
    on QueryBuilder<SearchSuggestion, SearchSuggestion, QFilterCondition> {}

extension SearchSuggestionQueryLinks
    on QueryBuilder<SearchSuggestion, SearchSuggestion, QFilterCondition> {}

extension SearchSuggestionQuerySortBy
    on QueryBuilder<SearchSuggestion, SearchSuggestion, QSortBy> {
  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy>
  sortByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy>
  sortByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy>
  sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }
}

extension SearchSuggestionQuerySortThenBy
    on QueryBuilder<SearchSuggestion, SearchSuggestion, QSortThenBy> {
  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy>
  thenByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy>
  thenByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QAfterSortBy>
  thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }
}

extension SearchSuggestionQueryWhereDistinct
    on QueryBuilder<SearchSuggestion, SearchSuggestion, QDistinct> {
  QueryBuilder<SearchSuggestion, SearchSuggestion, QDistinct> distinctByFts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fts');
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QDistinct>
  distinctByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeen');
    });
  }

  QueryBuilder<SearchSuggestion, SearchSuggestion, QDistinct> distinctByText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }
}

extension SearchSuggestionQueryProperty
    on QueryBuilder<SearchSuggestion, SearchSuggestion, QQueryProperty> {
  QueryBuilder<SearchSuggestion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SearchSuggestion, List<String>, QQueryOperations> ftsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fts');
    });
  }

  QueryBuilder<SearchSuggestion, DateTime, QQueryOperations>
  lastSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeen');
    });
  }

  QueryBuilder<SearchSuggestion, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }
}
