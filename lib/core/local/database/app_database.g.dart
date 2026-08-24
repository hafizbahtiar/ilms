// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $KeyValueEntriesTable extends KeyValueEntries
    with TableInfo<$KeyValueEntriesTable, KeyValueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_value_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KeyValueEntriesTable createAlias(String alias) {
    return $KeyValueEntriesTable(attachedDatabase, alias);
  }
}

class KeyValueEntry extends DataClass implements Insertable<KeyValueEntry> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const KeyValueEntry({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  KeyValueEntriesCompanion toCompanion(bool nullToAbsent) {
    return KeyValueEntriesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory KeyValueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  KeyValueEntry copyWith({String? key, String? value, DateTime? updatedAt}) =>
      KeyValueEntry(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  KeyValueEntry copyWithCompanion(KeyValueEntriesCompanion data) {
    return KeyValueEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueEntry(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValueEntry &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class KeyValueEntriesCompanion extends UpdateCompanion<KeyValueEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const KeyValueEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValueEntriesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<KeyValueEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValueEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return KeyValueEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PremiseDraftEntriesTable extends PremiseDraftEntries
    with TableInfo<$PremiseDraftEntriesTable, PremiseDraftEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PremiseDraftEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _companyNameMeta = const VerificationMeta(
    'companyName',
  );
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
    'company_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _traderNameMeta = const VerificationMeta(
    'traderName',
  );
  @override
  late final GeneratedColumn<String> traderName = GeneratedColumn<String>(
    'trader_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isEditSessionMeta = const VerificationMeta(
    'isEditSession',
  );
  @override
  late final GeneratedColumn<bool> isEditSession = GeneratedColumn<bool>(
    'is_edit_session',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_edit_session" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _visitNoMeta = const VerificationMeta(
    'visitNo',
  );
  @override
  late final GeneratedColumn<String> visitNo = GeneratedColumn<String>(
    'visit_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _draftTypeMeta = const VerificationMeta(
    'draftType',
  );
  @override
  late final GeneratedColumn<String> draftType = GeneratedColumn<String>(
    'draft_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('newEntry'),
  );
  static const VerificationMeta _formPayloadMeta = const VerificationMeta(
    'formPayload',
  );
  @override
  late final GeneratedColumn<String> formPayload = GeneratedColumn<String>(
    'form_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyName,
    traderName,
    isSynced,
    isActive,
    isEditSession,
    visitNo,
    draftType,
    formPayload,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'premise_draft_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PremiseDraftEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_name')) {
      context.handle(
        _companyNameMeta,
        companyName.isAcceptableOrUnknown(
          data['company_name']!,
          _companyNameMeta,
        ),
      );
    }
    if (data.containsKey('trader_name')) {
      context.handle(
        _traderNameMeta,
        traderName.isAcceptableOrUnknown(data['trader_name']!, _traderNameMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_edit_session')) {
      context.handle(
        _isEditSessionMeta,
        isEditSession.isAcceptableOrUnknown(
          data['is_edit_session']!,
          _isEditSessionMeta,
        ),
      );
    }
    if (data.containsKey('visit_no')) {
      context.handle(
        _visitNoMeta,
        visitNo.isAcceptableOrUnknown(data['visit_no']!, _visitNoMeta),
      );
    }
    if (data.containsKey('draft_type')) {
      context.handle(
        _draftTypeMeta,
        draftType.isAcceptableOrUnknown(data['draft_type']!, _draftTypeMeta),
      );
    }
    if (data.containsKey('form_payload')) {
      context.handle(
        _formPayloadMeta,
        formPayload.isAcceptableOrUnknown(
          data['form_payload']!,
          _formPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formPayloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PremiseDraftEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PremiseDraftEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name'],
      )!,
      traderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trader_name'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isEditSession: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_edit_session'],
      )!,
      visitNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_no'],
      ),
      draftType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft_type'],
      )!,
      formPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PremiseDraftEntriesTable createAlias(String alias) {
    return $PremiseDraftEntriesTable(attachedDatabase, alias);
  }
}

class PremiseDraftEntry extends DataClass
    implements Insertable<PremiseDraftEntry> {
  final int id;
  final String companyName;
  final String traderName;
  final bool isSynced;
  final bool isActive;
  final bool isEditSession;
  final String? visitNo;

  /// [PremiseDraftType] name — how this draft came to be (new entry, vacant,
  /// or a duplicate of an existing record/draft).
  final String draftType;

  /// JSON payload — form fields + census images metadata.
  final String formPayload;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PremiseDraftEntry({
    required this.id,
    required this.companyName,
    required this.traderName,
    required this.isSynced,
    required this.isActive,
    required this.isEditSession,
    this.visitNo,
    required this.draftType,
    required this.formPayload,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_name'] = Variable<String>(companyName);
    map['trader_name'] = Variable<String>(traderName);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_active'] = Variable<bool>(isActive);
    map['is_edit_session'] = Variable<bool>(isEditSession);
    if (!nullToAbsent || visitNo != null) {
      map['visit_no'] = Variable<String>(visitNo);
    }
    map['draft_type'] = Variable<String>(draftType);
    map['form_payload'] = Variable<String>(formPayload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PremiseDraftEntriesCompanion toCompanion(bool nullToAbsent) {
    return PremiseDraftEntriesCompanion(
      id: Value(id),
      companyName: Value(companyName),
      traderName: Value(traderName),
      isSynced: Value(isSynced),
      isActive: Value(isActive),
      isEditSession: Value(isEditSession),
      visitNo: visitNo == null && nullToAbsent
          ? const Value.absent()
          : Value(visitNo),
      draftType: Value(draftType),
      formPayload: Value(formPayload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PremiseDraftEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PremiseDraftEntry(
      id: serializer.fromJson<int>(json['id']),
      companyName: serializer.fromJson<String>(json['companyName']),
      traderName: serializer.fromJson<String>(json['traderName']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isEditSession: serializer.fromJson<bool>(json['isEditSession']),
      visitNo: serializer.fromJson<String?>(json['visitNo']),
      draftType: serializer.fromJson<String>(json['draftType']),
      formPayload: serializer.fromJson<String>(json['formPayload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyName': serializer.toJson<String>(companyName),
      'traderName': serializer.toJson<String>(traderName),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isActive': serializer.toJson<bool>(isActive),
      'isEditSession': serializer.toJson<bool>(isEditSession),
      'visitNo': serializer.toJson<String?>(visitNo),
      'draftType': serializer.toJson<String>(draftType),
      'formPayload': serializer.toJson<String>(formPayload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PremiseDraftEntry copyWith({
    int? id,
    String? companyName,
    String? traderName,
    bool? isSynced,
    bool? isActive,
    bool? isEditSession,
    Value<String?> visitNo = const Value.absent(),
    String? draftType,
    String? formPayload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PremiseDraftEntry(
    id: id ?? this.id,
    companyName: companyName ?? this.companyName,
    traderName: traderName ?? this.traderName,
    isSynced: isSynced ?? this.isSynced,
    isActive: isActive ?? this.isActive,
    isEditSession: isEditSession ?? this.isEditSession,
    visitNo: visitNo.present ? visitNo.value : this.visitNo,
    draftType: draftType ?? this.draftType,
    formPayload: formPayload ?? this.formPayload,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PremiseDraftEntry copyWithCompanion(PremiseDraftEntriesCompanion data) {
    return PremiseDraftEntry(
      id: data.id.present ? data.id.value : this.id,
      companyName: data.companyName.present
          ? data.companyName.value
          : this.companyName,
      traderName: data.traderName.present
          ? data.traderName.value
          : this.traderName,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isEditSession: data.isEditSession.present
          ? data.isEditSession.value
          : this.isEditSession,
      visitNo: data.visitNo.present ? data.visitNo.value : this.visitNo,
      draftType: data.draftType.present ? data.draftType.value : this.draftType,
      formPayload: data.formPayload.present
          ? data.formPayload.value
          : this.formPayload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PremiseDraftEntry(')
          ..write('id: $id, ')
          ..write('companyName: $companyName, ')
          ..write('traderName: $traderName, ')
          ..write('isSynced: $isSynced, ')
          ..write('isActive: $isActive, ')
          ..write('isEditSession: $isEditSession, ')
          ..write('visitNo: $visitNo, ')
          ..write('draftType: $draftType, ')
          ..write('formPayload: $formPayload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyName,
    traderName,
    isSynced,
    isActive,
    isEditSession,
    visitNo,
    draftType,
    formPayload,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PremiseDraftEntry &&
          other.id == this.id &&
          other.companyName == this.companyName &&
          other.traderName == this.traderName &&
          other.isSynced == this.isSynced &&
          other.isActive == this.isActive &&
          other.isEditSession == this.isEditSession &&
          other.visitNo == this.visitNo &&
          other.draftType == this.draftType &&
          other.formPayload == this.formPayload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PremiseDraftEntriesCompanion extends UpdateCompanion<PremiseDraftEntry> {
  final Value<int> id;
  final Value<String> companyName;
  final Value<String> traderName;
  final Value<bool> isSynced;
  final Value<bool> isActive;
  final Value<bool> isEditSession;
  final Value<String?> visitNo;
  final Value<String> draftType;
  final Value<String> formPayload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PremiseDraftEntriesCompanion({
    this.id = const Value.absent(),
    this.companyName = const Value.absent(),
    this.traderName = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isEditSession = const Value.absent(),
    this.visitNo = const Value.absent(),
    this.draftType = const Value.absent(),
    this.formPayload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PremiseDraftEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.companyName = const Value.absent(),
    this.traderName = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isEditSession = const Value.absent(),
    this.visitNo = const Value.absent(),
    this.draftType = const Value.absent(),
    required String formPayload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : formPayload = Value(formPayload),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PremiseDraftEntry> custom({
    Expression<int>? id,
    Expression<String>? companyName,
    Expression<String>? traderName,
    Expression<bool>? isSynced,
    Expression<bool>? isActive,
    Expression<bool>? isEditSession,
    Expression<String>? visitNo,
    Expression<String>? draftType,
    Expression<String>? formPayload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyName != null) 'company_name': companyName,
      if (traderName != null) 'trader_name': traderName,
      if (isSynced != null) 'is_synced': isSynced,
      if (isActive != null) 'is_active': isActive,
      if (isEditSession != null) 'is_edit_session': isEditSession,
      if (visitNo != null) 'visit_no': visitNo,
      if (draftType != null) 'draft_type': draftType,
      if (formPayload != null) 'form_payload': formPayload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PremiseDraftEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? companyName,
    Value<String>? traderName,
    Value<bool>? isSynced,
    Value<bool>? isActive,
    Value<bool>? isEditSession,
    Value<String?>? visitNo,
    Value<String>? draftType,
    Value<String>? formPayload,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PremiseDraftEntriesCompanion(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      traderName: traderName ?? this.traderName,
      isSynced: isSynced ?? this.isSynced,
      isActive: isActive ?? this.isActive,
      isEditSession: isEditSession ?? this.isEditSession,
      visitNo: visitNo ?? this.visitNo,
      draftType: draftType ?? this.draftType,
      formPayload: formPayload ?? this.formPayload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (traderName.present) {
      map['trader_name'] = Variable<String>(traderName.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isEditSession.present) {
      map['is_edit_session'] = Variable<bool>(isEditSession.value);
    }
    if (visitNo.present) {
      map['visit_no'] = Variable<String>(visitNo.value);
    }
    if (draftType.present) {
      map['draft_type'] = Variable<String>(draftType.value);
    }
    if (formPayload.present) {
      map['form_payload'] = Variable<String>(formPayload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PremiseDraftEntriesCompanion(')
          ..write('id: $id, ')
          ..write('companyName: $companyName, ')
          ..write('traderName: $traderName, ')
          ..write('isSynced: $isSynced, ')
          ..write('isActive: $isActive, ')
          ..write('isEditSession: $isEditSession, ')
          ..write('visitNo: $visitNo, ')
          ..write('draftType: $draftType, ')
          ..write('formPayload: $formPayload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CrashLogEntriesTable extends CrashLogEntries
    with TableInfo<$CrashLogEntriesTable, CrashLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrashLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    payload,
    status,
    errorMessage,
    retryCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crash_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CrashLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CrashLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CrashLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CrashLogEntriesTable createAlias(String alias) {
    return $CrashLogEntriesTable(attachedDatabase, alias);
  }
}

class CrashLogEntry extends DataClass implements Insertable<CrashLogEntry> {
  final int id;
  final String payload;
  final String status;
  final String? errorMessage;
  final int retryCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CrashLogEntry({
    required this.id,
    required this.payload,
    required this.status,
    this.errorMessage,
    required this.retryCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CrashLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return CrashLogEntriesCompanion(
      id: Value(id),
      payload: Value(payload),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CrashLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CrashLogEntry(
      id: serializer.fromJson<int>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CrashLogEntry copyWith({
    int? id,
    String? payload,
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    int? retryCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CrashLogEntry(
    id: id ?? this.id,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CrashLogEntry copyWithCompanion(CrashLogEntriesCompanion data) {
    return CrashLogEntry(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CrashLogEntry(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    payload,
    status,
    errorMessage,
    retryCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CrashLogEntry &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CrashLogEntriesCompanion extends UpdateCompanion<CrashLogEntry> {
  final Value<int> id;
  final Value<String> payload;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CrashLogEntriesCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CrashLogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : payload = Value(payload);
  static Insertable<CrashLogEntry> custom({
    Expression<int>? id,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CrashLogEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? payload,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CrashLogEntriesCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CrashLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KeyValueEntriesTable keyValueEntries = $KeyValueEntriesTable(
    this,
  );
  late final $PremiseDraftEntriesTable premiseDraftEntries =
      $PremiseDraftEntriesTable(this);
  late final $CrashLogEntriesTable crashLogEntries = $CrashLogEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    keyValueEntries,
    premiseDraftEntries,
    crashLogEntries,
  ];
}

typedef $$KeyValueEntriesTableCreateCompanionBuilder =
    KeyValueEntriesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$KeyValueEntriesTableUpdateCompanionBuilder =
    KeyValueEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$KeyValueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValueEntriesTable> {
  $$KeyValueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeyValueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValueEntriesTable> {
  $$KeyValueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeyValueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValueEntriesTable> {
  $$KeyValueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KeyValueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValueEntriesTable,
          KeyValueEntry,
          $$KeyValueEntriesTableFilterComposer,
          $$KeyValueEntriesTableOrderingComposer,
          $$KeyValueEntriesTableAnnotationComposer,
          $$KeyValueEntriesTableCreateCompanionBuilder,
          $$KeyValueEntriesTableUpdateCompanionBuilder,
          (
            KeyValueEntry,
            BaseReferences<_$AppDatabase, $KeyValueEntriesTable, KeyValueEntry>,
          ),
          KeyValueEntry,
          PrefetchHooks Function()
        > {
  $$KeyValueEntriesTableTableManager(
    _$AppDatabase db,
    $KeyValueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValueEntriesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => KeyValueEntriesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValueEntriesTable,
      KeyValueEntry,
      $$KeyValueEntriesTableFilterComposer,
      $$KeyValueEntriesTableOrderingComposer,
      $$KeyValueEntriesTableAnnotationComposer,
      $$KeyValueEntriesTableCreateCompanionBuilder,
      $$KeyValueEntriesTableUpdateCompanionBuilder,
      (
        KeyValueEntry,
        BaseReferences<_$AppDatabase, $KeyValueEntriesTable, KeyValueEntry>,
      ),
      KeyValueEntry,
      PrefetchHooks Function()
    >;
typedef $$PremiseDraftEntriesTableCreateCompanionBuilder =
    PremiseDraftEntriesCompanion Function({
      Value<int> id,
      Value<String> companyName,
      Value<String> traderName,
      Value<bool> isSynced,
      Value<bool> isActive,
      Value<bool> isEditSession,
      Value<String?> visitNo,
      Value<String> draftType,
      required String formPayload,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PremiseDraftEntriesTableUpdateCompanionBuilder =
    PremiseDraftEntriesCompanion Function({
      Value<int> id,
      Value<String> companyName,
      Value<String> traderName,
      Value<bool> isSynced,
      Value<bool> isActive,
      Value<bool> isEditSession,
      Value<String?> visitNo,
      Value<String> draftType,
      Value<String> formPayload,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$PremiseDraftEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PremiseDraftEntriesTable> {
  $$PremiseDraftEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get traderName => $composableBuilder(
    column: $table.traderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEditSession => $composableBuilder(
    column: $table.isEditSession,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitNo => $composableBuilder(
    column: $table.visitNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draftType => $composableBuilder(
    column: $table.draftType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formPayload => $composableBuilder(
    column: $table.formPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PremiseDraftEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PremiseDraftEntriesTable> {
  $$PremiseDraftEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get traderName => $composableBuilder(
    column: $table.traderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEditSession => $composableBuilder(
    column: $table.isEditSession,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitNo => $composableBuilder(
    column: $table.visitNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draftType => $composableBuilder(
    column: $table.draftType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formPayload => $composableBuilder(
    column: $table.formPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PremiseDraftEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PremiseDraftEntriesTable> {
  $$PremiseDraftEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get traderName => $composableBuilder(
    column: $table.traderName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isEditSession => $composableBuilder(
    column: $table.isEditSession,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visitNo =>
      $composableBuilder(column: $table.visitNo, builder: (column) => column);

  GeneratedColumn<String> get draftType =>
      $composableBuilder(column: $table.draftType, builder: (column) => column);

  GeneratedColumn<String> get formPayload => $composableBuilder(
    column: $table.formPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PremiseDraftEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PremiseDraftEntriesTable,
          PremiseDraftEntry,
          $$PremiseDraftEntriesTableFilterComposer,
          $$PremiseDraftEntriesTableOrderingComposer,
          $$PremiseDraftEntriesTableAnnotationComposer,
          $$PremiseDraftEntriesTableCreateCompanionBuilder,
          $$PremiseDraftEntriesTableUpdateCompanionBuilder,
          (
            PremiseDraftEntry,
            BaseReferences<
              _$AppDatabase,
              $PremiseDraftEntriesTable,
              PremiseDraftEntry
            >,
          ),
          PremiseDraftEntry,
          PrefetchHooks Function()
        > {
  $$PremiseDraftEntriesTableTableManager(
    _$AppDatabase db,
    $PremiseDraftEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PremiseDraftEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PremiseDraftEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PremiseDraftEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> companyName = const Value.absent(),
                Value<String> traderName = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isEditSession = const Value.absent(),
                Value<String?> visitNo = const Value.absent(),
                Value<String> draftType = const Value.absent(),
                Value<String> formPayload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PremiseDraftEntriesCompanion(
                id: id,
                companyName: companyName,
                traderName: traderName,
                isSynced: isSynced,
                isActive: isActive,
                isEditSession: isEditSession,
                visitNo: visitNo,
                draftType: draftType,
                formPayload: formPayload,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> companyName = const Value.absent(),
                Value<String> traderName = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isEditSession = const Value.absent(),
                Value<String?> visitNo = const Value.absent(),
                Value<String> draftType = const Value.absent(),
                required String formPayload,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PremiseDraftEntriesCompanion.insert(
                id: id,
                companyName: companyName,
                traderName: traderName,
                isSynced: isSynced,
                isActive: isActive,
                isEditSession: isEditSession,
                visitNo: visitNo,
                draftType: draftType,
                formPayload: formPayload,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PremiseDraftEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PremiseDraftEntriesTable,
      PremiseDraftEntry,
      $$PremiseDraftEntriesTableFilterComposer,
      $$PremiseDraftEntriesTableOrderingComposer,
      $$PremiseDraftEntriesTableAnnotationComposer,
      $$PremiseDraftEntriesTableCreateCompanionBuilder,
      $$PremiseDraftEntriesTableUpdateCompanionBuilder,
      (
        PremiseDraftEntry,
        BaseReferences<
          _$AppDatabase,
          $PremiseDraftEntriesTable,
          PremiseDraftEntry
        >,
      ),
      PremiseDraftEntry,
      PrefetchHooks Function()
    >;
typedef $$CrashLogEntriesTableCreateCompanionBuilder =
    CrashLogEntriesCompanion Function({
      Value<int> id,
      required String payload,
      Value<String> status,
      Value<String?> errorMessage,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CrashLogEntriesTableUpdateCompanionBuilder =
    CrashLogEntriesCompanion Function({
      Value<int> id,
      Value<String> payload,
      Value<String> status,
      Value<String?> errorMessage,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CrashLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CrashLogEntriesTable> {
  $$CrashLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CrashLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CrashLogEntriesTable> {
  $$CrashLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CrashLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CrashLogEntriesTable> {
  $$CrashLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CrashLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CrashLogEntriesTable,
          CrashLogEntry,
          $$CrashLogEntriesTableFilterComposer,
          $$CrashLogEntriesTableOrderingComposer,
          $$CrashLogEntriesTableAnnotationComposer,
          $$CrashLogEntriesTableCreateCompanionBuilder,
          $$CrashLogEntriesTableUpdateCompanionBuilder,
          (
            CrashLogEntry,
            BaseReferences<_$AppDatabase, $CrashLogEntriesTable, CrashLogEntry>,
          ),
          CrashLogEntry,
          PrefetchHooks Function()
        > {
  $$CrashLogEntriesTableTableManager(
    _$AppDatabase db,
    $CrashLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CrashLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CrashLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CrashLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CrashLogEntriesCompanion(
                id: id,
                payload: payload,
                status: status,
                errorMessage: errorMessage,
                retryCount: retryCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String payload,
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CrashLogEntriesCompanion.insert(
                id: id,
                payload: payload,
                status: status,
                errorMessage: errorMessage,
                retryCount: retryCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CrashLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CrashLogEntriesTable,
      CrashLogEntry,
      $$CrashLogEntriesTableFilterComposer,
      $$CrashLogEntriesTableOrderingComposer,
      $$CrashLogEntriesTableAnnotationComposer,
      $$CrashLogEntriesTableCreateCompanionBuilder,
      $$CrashLogEntriesTableUpdateCompanionBuilder,
      (
        CrashLogEntry,
        BaseReferences<_$AppDatabase, $CrashLogEntriesTable, CrashLogEntry>,
      ),
      CrashLogEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KeyValueEntriesTableTableManager get keyValueEntries =>
      $$KeyValueEntriesTableTableManager(_db, _db.keyValueEntries);
  $$PremiseDraftEntriesTableTableManager get premiseDraftEntries =>
      $$PremiseDraftEntriesTableTableManager(_db, _db.premiseDraftEntries);
  $$CrashLogEntriesTableTableManager get crashLogEntries =>
      $$CrashLogEntriesTableTableManager(_db, _db.crashLogEntries);
}
