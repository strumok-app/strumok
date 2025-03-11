// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_repository.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarMediaCollectionItemCollection on Isar {
  IsarCollection<IsarMediaCollectionItem> get isarMediaCollectionItems =>
      this.collection();
}

const IsarMediaCollectionItemSchema = CollectionSchema(
  name: r'MediaCollectionItem',
  id: -178774548625455057,
  properties: {
    r'currentItem': PropertySchema(
      id: 0,
      name: r'currentItem',
      type: IsarType.long,
    ),
    r'currentSourceName': PropertySchema(
      id: 1,
      name: r'currentSourceName',
      type: IsarType.string,
    ),
    r'currentSubtitleName': PropertySchema(
      id: 2,
      name: r'currentSubtitleName',
      type: IsarType.string,
    ),
    r'fts': PropertySchema(id: 3, name: r'fts', type: IsarType.stringList),
    r'id': PropertySchema(id: 4, name: r'id', type: IsarType.string),
    r'image': PropertySchema(id: 5, name: r'image', type: IsarType.string),
    r'lastSeen': PropertySchema(
      id: 6,
      name: r'lastSeen',
      type: IsarType.dateTime,
    ),
    r'mediaType': PropertySchema(
      id: 7,
      name: r'mediaType',
      type: IsarType.byte,
      enumMap: _IsarMediaCollectionItemmediaTypeEnumValueMap,
    ),
    r'positions': PropertySchema(
      id: 8,
      name: r'positions',
      type: IsarType.objectList,

      target: r'IsarMediaCollectionItemPosition',
    ),
    r'priority': PropertySchema(id: 9, name: r'priority', type: IsarType.long),
    r'secondaryTitle': PropertySchema(
      id: 10,
      name: r'secondaryTitle',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 11,
      name: r'status',
      type: IsarType.byte,
      enumMap: _IsarMediaCollectionItemstatusEnumValueMap,
    ),
    r'supplier': PropertySchema(
      id: 12,
      name: r'supplier',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 13, name: r'title', type: IsarType.string),
  },

  estimateSize: _isarMediaCollectionItemEstimateSize,
  serialize: _isarMediaCollectionItemSerialize,
  deserialize: _isarMediaCollectionItemDeserialize,
  deserializeProp: _isarMediaCollectionItemDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'supplierId': IndexSchema(
      id: -7509772217447508349,
      name: r'supplierId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'supplier',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
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
  embeddedSchemas: {
    r'IsarMediaCollectionItemPosition': IsarMediaItemPositionSchema,
  },

  getId: _isarMediaCollectionItemGetId,
  getLinks: _isarMediaCollectionItemGetLinks,
  attach: _isarMediaCollectionItemAttach,
  version: '3.1.8',
);

int _isarMediaCollectionItemEstimateSize(
  IsarMediaCollectionItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.currentSourceName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentSubtitleName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.fts.length * 3;
  {
    for (var i = 0; i < object.fts.length; i++) {
      final value = object.fts[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.image.length * 3;
  {
    final list = object.positions;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[IsarMediaItemPosition]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += IsarMediaItemPositionSchema.estimateSize(
            value,
            offsets,
            allOffsets,
          );
        }
      }
    }
  }
  {
    final value = object.secondaryTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.supplier.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _isarMediaCollectionItemSerialize(
  IsarMediaCollectionItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentItem);
  writer.writeString(offsets[1], object.currentSourceName);
  writer.writeString(offsets[2], object.currentSubtitleName);
  writer.writeStringList(offsets[3], object.fts);
  writer.writeString(offsets[4], object.id);
  writer.writeString(offsets[5], object.image);
  writer.writeDateTime(offsets[6], object.lastSeen);
  writer.writeByte(offsets[7], object.mediaType.index);
  writer.writeObjectList<IsarMediaItemPosition>(
    offsets[8],
    allOffsets,
    IsarMediaItemPositionSchema.serialize,
    object.positions,
  );
  writer.writeLong(offsets[9], object.priority);
  writer.writeString(offsets[10], object.secondaryTitle);
  writer.writeByte(offsets[11], object.status.index);
  writer.writeString(offsets[12], object.supplier);
  writer.writeString(offsets[13], object.title);
}

IsarMediaCollectionItem _isarMediaCollectionItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarMediaCollectionItem(
    currentItem: reader.readLongOrNull(offsets[0]),
    currentSourceName: reader.readStringOrNull(offsets[1]),
    currentSubtitleName: reader.readStringOrNull(offsets[2]),
    id: reader.readString(offsets[4]),
    image: reader.readString(offsets[5]),
    isarId: id,
    lastSeen: reader.readDateTimeOrNull(offsets[6]),
    mediaType:
        _IsarMediaCollectionItemmediaTypeValueEnumMap[reader.readByteOrNull(
          offsets[7],
        )] ??
        MediaType.video,
    positions: reader.readObjectList<IsarMediaItemPosition>(
      offsets[8],
      IsarMediaItemPositionSchema.deserialize,
      allOffsets,
      IsarMediaItemPosition(),
    ),
    priority: reader.readLongOrNull(offsets[9]),
    status:
        _IsarMediaCollectionItemstatusValueEnumMap[reader.readByteOrNull(
          offsets[11],
        )] ??
        MediaCollectionItemStatus.none,
    supplier: reader.readString(offsets[12]),
    title: reader.readString(offsets[13]),
  );
  object.secondaryTitle = reader.readStringOrNull(offsets[10]);
  return object;
}

P _isarMediaCollectionItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (_IsarMediaCollectionItemmediaTypeValueEnumMap[reader
                  .readByteOrNull(offset)] ??
              MediaType.video)
          as P;
    case 8:
      return (reader.readObjectList<IsarMediaItemPosition>(
            offset,
            IsarMediaItemPositionSchema.deserialize,
            allOffsets,
            IsarMediaItemPosition(),
          ))
          as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (_IsarMediaCollectionItemstatusValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              MediaCollectionItemStatus.none)
          as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IsarMediaCollectionItemmediaTypeEnumValueMap = {'video': 0, 'manga': 1};
const _IsarMediaCollectionItemmediaTypeValueEnumMap = {
  0: MediaType.video,
  1: MediaType.manga,
};
const _IsarMediaCollectionItemstatusEnumValueMap = {
  'none': 0,
  'latter': 1,
  'inProgress': 2,
  'complete': 3,
  'onHold': 4,
};
const _IsarMediaCollectionItemstatusValueEnumMap = {
  0: MediaCollectionItemStatus.none,
  1: MediaCollectionItemStatus.latter,
  2: MediaCollectionItemStatus.inProgress,
  3: MediaCollectionItemStatus.complete,
  4: MediaCollectionItemStatus.onHold,
};

Id _isarMediaCollectionItemGetId(IsarMediaCollectionItem object) {
  return object.isarId ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _isarMediaCollectionItemGetLinks(
  IsarMediaCollectionItem object,
) {
  return [];
}

void _isarMediaCollectionItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  IsarMediaCollectionItem object,
) {
  object.isarId = id;
}

extension IsarMediaCollectionItemByIndex
    on IsarCollection<IsarMediaCollectionItem> {
  Future<IsarMediaCollectionItem?> getBySupplierId(String supplier, String id) {
    return getByIndex(r'supplierId', [supplier, id]);
  }

  IsarMediaCollectionItem? getBySupplierIdSync(String supplier, String id) {
    return getByIndexSync(r'supplierId', [supplier, id]);
  }

  Future<bool> deleteBySupplierId(String supplier, String id) {
    return deleteByIndex(r'supplierId', [supplier, id]);
  }

  bool deleteBySupplierIdSync(String supplier, String id) {
    return deleteByIndexSync(r'supplierId', [supplier, id]);
  }

  Future<List<IsarMediaCollectionItem?>> getAllBySupplierId(
    List<String> supplierValues,
    List<String> idValues,
  ) {
    final len = supplierValues.length;
    assert(
      idValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([supplierValues[i], idValues[i]]);
    }

    return getAllByIndex(r'supplierId', values);
  }

  List<IsarMediaCollectionItem?> getAllBySupplierIdSync(
    List<String> supplierValues,
    List<String> idValues,
  ) {
    final len = supplierValues.length;
    assert(
      idValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([supplierValues[i], idValues[i]]);
    }

    return getAllByIndexSync(r'supplierId', values);
  }

  Future<int> deleteAllBySupplierId(
    List<String> supplierValues,
    List<String> idValues,
  ) {
    final len = supplierValues.length;
    assert(
      idValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([supplierValues[i], idValues[i]]);
    }

    return deleteAllByIndex(r'supplierId', values);
  }

  int deleteAllBySupplierIdSync(
    List<String> supplierValues,
    List<String> idValues,
  ) {
    final len = supplierValues.length;
    assert(
      idValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([supplierValues[i], idValues[i]]);
    }

    return deleteAllByIndexSync(r'supplierId', values);
  }

  Future<Id> putBySupplierId(IsarMediaCollectionItem object) {
    return putByIndex(r'supplierId', object);
  }

  Id putBySupplierIdSync(
    IsarMediaCollectionItem object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'supplierId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySupplierId(List<IsarMediaCollectionItem> objects) {
    return putAllByIndex(r'supplierId', objects);
  }

  List<Id> putAllBySupplierIdSync(
    List<IsarMediaCollectionItem> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'supplierId', objects, saveLinks: saveLinks);
  }
}

extension IsarMediaCollectionItemQueryWhereSort
    on QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QWhere> {
  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterWhere>
  anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterWhere>
  anyFtsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'fts'),
      );
    });
  }
}

extension IsarMediaCollectionItemQueryWhere
    on
        QueryBuilder<
          IsarMediaCollectionItem,
          IsarMediaCollectionItem,
          QWhereClause
        > {
  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  supplierEqualToAnyId(String supplier) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'supplierId', value: [supplier]),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  supplierNotEqualToAnyId(String supplier) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'supplierId',
                lower: [],
                upper: [supplier],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'supplierId',
                lower: [supplier],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'supplierId',
                lower: [supplier],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'supplierId',
                lower: [],
                upper: [supplier],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  supplierIdEqualTo(String supplier, String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'supplierId',
          value: [supplier, id],
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  supplierEqualToIdNotEqualTo(String supplier, String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'supplierId',
                lower: [supplier],
                upper: [supplier, id],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'supplierId',
                lower: [supplier, id],
                includeLower: false,
                upper: [supplier],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'supplierId',
                lower: [supplier, id],
                includeLower: false,
                upper: [supplier],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'supplierId',
                lower: [supplier],
                upper: [supplier, id],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  ftsElementEqualTo(String ftsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'fts', value: [ftsElement]),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
  ftsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'fts', value: ['']),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterWhereClause
  >
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

extension IsarMediaCollectionItemQueryFilter
    on
        QueryBuilder<
          IsarMediaCollectionItem,
          IsarMediaCollectionItem,
          QFilterCondition
        > {
  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentItemIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentItem'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentItemIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentItem'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentItemEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentItem', value: value),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentItemGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentItem',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentItemLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentItem',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentItemBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentItem',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentSourceName'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentSourceName'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentSourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentSourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentSourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentSourceName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentSourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentSourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentSourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentSourceName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentSourceName', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSourceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currentSourceName', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentSubtitleName'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentSubtitleName'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentSubtitleName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentSubtitleName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentSubtitleName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentSubtitleName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentSubtitleName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentSubtitleName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentSubtitleName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentSubtitleName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentSubtitleName', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  currentSubtitleNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'currentSubtitleName',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  ftsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fts', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  ftsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fts', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  ftsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', length, true, length, true);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  ftsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', 0, true, 0, true);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  ftsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  ftsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', 0, true, length, include);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  ftsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fts', length, include, 999999, true);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'id',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'image',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'image',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'image', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  imageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'image', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  isarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'isarId'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  isarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'isarId'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  isarIdEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  isarIdGreaterThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  isarIdLessThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  isarIdBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  lastSeenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSeen'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  lastSeenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSeen'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  lastSeenEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSeen', value: value),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  lastSeenGreaterThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  lastSeenLessThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  lastSeenBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  mediaTypeEqualTo(MediaType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediaType', value: value),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  mediaTypeGreaterThan(MediaType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mediaType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  mediaTypeLessThan(MediaType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mediaType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  mediaTypeBetween(
    MediaType lower,
    MediaType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mediaType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  positionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'positions'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  positionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'positions'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  positionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', length, true, length, true);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  positionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', 0, true, 0, true);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  positionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  positionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', 0, true, length, include);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  positionsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', length, include, 999999, true);
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  positionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'positions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  priorityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'priority'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  priorityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'priority'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  priorityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'priority', value: value),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  priorityGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'priority',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  priorityLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'priority',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  priorityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'priority',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'secondaryTitle'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'secondaryTitle'),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'secondaryTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'secondaryTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'secondaryTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'secondaryTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'secondaryTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'secondaryTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'secondaryTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'secondaryTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'secondaryTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  secondaryTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'secondaryTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  statusEqualTo(MediaCollectionItemStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  statusGreaterThan(MediaCollectionItemStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  statusLessThan(MediaCollectionItemStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  statusBetween(
    MediaCollectionItemStatus lower,
    MediaCollectionItemStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'supplier',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'supplier',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'supplier', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  supplierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'supplier', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension IsarMediaCollectionItemQueryObject
    on
        QueryBuilder<
          IsarMediaCollectionItem,
          IsarMediaCollectionItem,
          QFilterCondition
        > {
  QueryBuilder<
    IsarMediaCollectionItem,
    IsarMediaCollectionItem,
    QAfterFilterCondition
  >
  positionsElement(FilterQuery<IsarMediaItemPosition> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'positions');
    });
  }
}

extension IsarMediaCollectionItemQueryLinks
    on
        QueryBuilder<
          IsarMediaCollectionItem,
          IsarMediaCollectionItem,
          QFilterCondition
        > {}

extension IsarMediaCollectionItemQuerySortBy
    on QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QSortBy> {
  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByCurrentItem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentItem', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByCurrentItemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentItem', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByCurrentSourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSourceName', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByCurrentSourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSourceName', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByCurrentSubtitleName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSubtitleName', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByCurrentSubtitleNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSubtitleName', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortBySecondaryTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryTitle', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortBySecondaryTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryTitle', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortBySupplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortBySupplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension IsarMediaCollectionItemQuerySortThenBy
    on
        QueryBuilder<
          IsarMediaCollectionItem,
          IsarMediaCollectionItem,
          QSortThenBy
        > {
  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByCurrentItem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentItem', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByCurrentItemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentItem', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByCurrentSourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSourceName', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByCurrentSourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSourceName', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByCurrentSubtitleName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSubtitleName', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByCurrentSubtitleNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSubtitleName', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenBySecondaryTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryTitle', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenBySecondaryTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryTitle', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenBySupplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenBySupplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.desc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension IsarMediaCollectionItemQueryWhereDistinct
    on
        QueryBuilder<
          IsarMediaCollectionItem,
          IsarMediaCollectionItem,
          QDistinct
        > {
  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByCurrentItem() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentItem');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByCurrentSourceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'currentSourceName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByCurrentSubtitleName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'currentSubtitleName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByFts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fts');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByImage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'image', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeen');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaType');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctBySecondaryTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'secondaryTitle',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctBySupplier({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarMediaCollectionItem, IsarMediaCollectionItem, QDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension IsarMediaCollectionItemQueryProperty
    on
        QueryBuilder<
          IsarMediaCollectionItem,
          IsarMediaCollectionItem,
          QQueryProperty
        > {
  QueryBuilder<IsarMediaCollectionItem, int, QQueryOperations>
  isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, int?, QQueryOperations>
  currentItemProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentItem');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, String?, QQueryOperations>
  currentSourceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentSourceName');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, String?, QQueryOperations>
  currentSubtitleNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentSubtitleName');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, List<String>, QQueryOperations>
  ftsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fts');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, String, QQueryOperations>
  imageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'image');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, DateTime?, QQueryOperations>
  lastSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeen');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, MediaType, QQueryOperations>
  mediaTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaType');
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    List<IsarMediaItemPosition>?,
    QQueryOperations
  >
  positionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positions');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, int?, QQueryOperations>
  priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, String?, QQueryOperations>
  secondaryTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secondaryTitle');
    });
  }

  QueryBuilder<
    IsarMediaCollectionItem,
    MediaCollectionItemStatus,
    QQueryOperations
  >
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, String, QQueryOperations>
  supplierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplier');
    });
  }

  QueryBuilder<IsarMediaCollectionItem, String, QQueryOperations>
  titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarMediaItemPositionSchema = Schema(
  name: r'IsarMediaCollectionItemPosition',
  id: -2122285338101174364,
  properties: {
    r'length': PropertySchema(id: 0, name: r'length', type: IsarType.long),
    r'number': PropertySchema(id: 1, name: r'number', type: IsarType.long),
    r'position': PropertySchema(id: 2, name: r'position', type: IsarType.long),
  },

  estimateSize: _isarMediaItemPositionEstimateSize,
  serialize: _isarMediaItemPositionSerialize,
  deserialize: _isarMediaItemPositionDeserialize,
  deserializeProp: _isarMediaItemPositionDeserializeProp,
);

int _isarMediaItemPositionEstimateSize(
  IsarMediaItemPosition object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _isarMediaItemPositionSerialize(
  IsarMediaItemPosition object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.length);
  writer.writeLong(offsets[1], object.number);
  writer.writeLong(offsets[2], object.position);
}

IsarMediaItemPosition _isarMediaItemPositionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarMediaItemPosition();
  object.length = reader.readLong(offsets[0]);
  object.number = reader.readLong(offsets[1]);
  object.position = reader.readLong(offsets[2]);
  return object;
}

P _isarMediaItemPositionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarMediaItemPositionQueryFilter
    on
        QueryBuilder<
          IsarMediaItemPosition,
          IsarMediaItemPosition,
          QFilterCondition
        > {
  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  lengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'length', value: value),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  lengthGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'length',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  lengthLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'length',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  lengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'length',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  numberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'number', value: value),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  numberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'number',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  numberLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'number',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  numberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'number',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  positionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'position', value: value),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  positionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  positionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarMediaItemPosition,
    IsarMediaItemPosition,
    QAfterFilterCondition
  >
  positionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'position',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IsarMediaItemPositionQueryObject
    on
        QueryBuilder<
          IsarMediaItemPosition,
          IsarMediaItemPosition,
          QFilterCondition
        > {}
