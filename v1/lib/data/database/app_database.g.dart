// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<int> dayKey = GeneratedColumn<int>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta('durationMin');
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, dayKey, note, durationMin, createdAt, updatedAt, startedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta, dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('duration_min')) {
      context.handle(_durationMinMeta, durationMin.isAcceptableOrUnknown(data['duration_min']!, _durationMinMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta, startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dayKey: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day_key'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      durationMin: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}duration_min']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      startedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final int dayKey;
  final String? note;
  final int? durationMin;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// When the session started (schema v3). Optional: typed in, or taken from
  /// a watch workout. With the duration it frames heart rate and calories.
  final DateTime? startedAt;
  const Session({
    required this.id,
    required this.dayKey,
    this.note,
    this.durationMin,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_key'] = Variable<int>(dayKey);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      dayKey: Value(dayKey),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      durationMin: durationMin == null && nullToAbsent ? const Value.absent() : Value(durationMin),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      startedAt: startedAt == null && nullToAbsent ? const Value.absent() : Value(startedAt),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      dayKey: serializer.fromJson<int>(json['dayKey']),
      note: serializer.fromJson<String?>(json['note']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayKey': serializer.toJson<int>(dayKey),
      'note': serializer.toJson<String?>(note),
      'durationMin': serializer.toJson<int?>(durationMin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
    };
  }

  Session copyWith({
    int? id,
    int? dayKey,
    Value<String?> note = const Value.absent(),
    Value<int?> durationMin = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> startedAt = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    dayKey: dayKey ?? this.dayKey,
    note: note.present ? note.value : this.note,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      note: data.note.present ? data.note.value : this.note,
      durationMin: data.durationMin.present ? data.durationMin.value : this.durationMin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('note: $note, ')
          ..write('durationMin: $durationMin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('startedAt: $startedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayKey, note, durationMin, createdAt, updatedAt, startedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.dayKey == this.dayKey &&
          other.note == this.note &&
          other.durationMin == this.durationMin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.startedAt == this.startedAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> dayKey;
  final Value<String?> note;
  final Value<int?> durationMin;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> startedAt;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.note = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int dayKey,
    this.note = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
  }) : dayKey = Value(dayKey);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? dayKey,
    Expression<String>? note,
    Expression<int>? durationMin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? startedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayKey != null) 'day_key': dayKey,
      if (note != null) 'note': note,
      if (durationMin != null) 'duration_min': durationMin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (startedAt != null) 'started_at': startedAt,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? dayKey,
    Value<String?>? note,
    Value<int?>? durationMin,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? startedAt,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      dayKey: dayKey ?? this.dayKey,
      note: note ?? this.note,
      durationMin: durationMin ?? this.durationMin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<int>(dayKey.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('note: $note, ')
          ..write('durationMin: $durationMin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('startedAt: $startedAt')
          ..write(')'))
        .toString();
  }
}

class $MuscleGroupsTable extends MuscleGroups with TableInfo<$MuscleGroupsTable, MuscleGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MuscleGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("hidden" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, slug, sortOrder, hidden, isCustom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muscle_groups';
  @override
  VerificationContext validateIntegrity(Insertable<MuscleGroup> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(_slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta, sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('hidden')) {
      context.handle(_hiddenMeta, hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta, isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MuscleGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MuscleGroup(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      slug: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}slug']),
      sortOrder: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      hidden: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}hidden'])!,
      isCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
    );
  }

  @override
  $MuscleGroupsTable createAlias(String alias) {
    return $MuscleGroupsTable(attachedDatabase, alias);
  }
}

class MuscleGroup extends DataClass implements Insertable<MuscleGroup> {
  final int id;
  final String name;

  /// Stable identifier for seeded groups (drives the body map); null for custom ones.
  final String? slug;
  final int sortOrder;
  final bool hidden;
  final bool isCustom;
  const MuscleGroup({
    required this.id,
    required this.name,
    this.slug,
    required this.sortOrder,
    required this.hidden,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || slug != null) {
      map['slug'] = Variable<String>(slug);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['hidden'] = Variable<bool>(hidden);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  MuscleGroupsCompanion toCompanion(bool nullToAbsent) {
    return MuscleGroupsCompanion(
      id: Value(id),
      name: Value(name),
      slug: slug == null && nullToAbsent ? const Value.absent() : Value(slug),
      sortOrder: Value(sortOrder),
      hidden: Value(hidden),
      isCustom: Value(isCustom),
    );
  }

  factory MuscleGroup.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MuscleGroup(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      slug: serializer.fromJson<String?>(json['slug']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'slug': serializer.toJson<String?>(slug),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'hidden': serializer.toJson<bool>(hidden),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  MuscleGroup copyWith({
    int? id,
    String? name,
    Value<String?> slug = const Value.absent(),
    int? sortOrder,
    bool? hidden,
    bool? isCustom,
  }) => MuscleGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    slug: slug.present ? slug.value : this.slug,
    sortOrder: sortOrder ?? this.sortOrder,
    hidden: hidden ?? this.hidden,
    isCustom: isCustom ?? this.isCustom,
  );
  MuscleGroup copyWithCompanion(MuscleGroupsCompanion data) {
    return MuscleGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      slug: data.slug.present ? data.slug.value : this.slug,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('hidden: $hidden, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, slug, sortOrder, hidden, isCustom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MuscleGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.slug == this.slug &&
          other.sortOrder == this.sortOrder &&
          other.hidden == this.hidden &&
          other.isCustom == this.isCustom);
}

class MuscleGroupsCompanion extends UpdateCompanion<MuscleGroup> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> slug;
  final Value<int> sortOrder;
  final Value<bool> hidden;
  final Value<bool> isCustom;
  const MuscleGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.slug = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.hidden = const Value.absent(),
    this.isCustom = const Value.absent(),
  });
  MuscleGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.slug = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.hidden = const Value.absent(),
    this.isCustom = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MuscleGroup> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? slug,
    Expression<int>? sortOrder,
    Expression<bool>? hidden,
    Expression<bool>? isCustom,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (slug != null) 'slug': slug,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (hidden != null) 'hidden': hidden,
      if (isCustom != null) 'is_custom': isCustom,
    });
  }

  MuscleGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? slug,
    Value<int>? sortOrder,
    Value<bool>? hidden,
    Value<bool>? isCustom,
  }) {
    return MuscleGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      sortOrder: sortOrder ?? this.sortOrder,
      hidden: hidden ?? this.hidden,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('hidden: $hidden, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }
}

class $SessionGroupsTable extends SessionGroups with TableInfo<$SessionGroupsTable, SessionGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES sessions (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES muscle_groups (id) ON DELETE CASCADE'),
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, groupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_groups';
  @override
  VerificationContext validateIntegrity(Insertable<SessionGroup> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta, sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta, groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, groupId};
  @override
  SessionGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionGroup(
      sessionId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
    );
  }

  @override
  $SessionGroupsTable createAlias(String alias) {
    return $SessionGroupsTable(attachedDatabase, alias);
  }
}

class SessionGroup extends DataClass implements Insertable<SessionGroup> {
  final int sessionId;
  final int groupId;
  const SessionGroup({required this.sessionId, required this.groupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['group_id'] = Variable<int>(groupId);
    return map;
  }

  SessionGroupsCompanion toCompanion(bool nullToAbsent) {
    return SessionGroupsCompanion(sessionId: Value(sessionId), groupId: Value(groupId));
  }

  factory SessionGroup.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionGroup(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      groupId: serializer.fromJson<int>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'groupId': serializer.toJson<int>(groupId),
    };
  }

  SessionGroup copyWith({int? sessionId, int? groupId}) =>
      SessionGroup(sessionId: sessionId ?? this.sessionId, groupId: groupId ?? this.groupId);
  SessionGroup copyWithCompanion(SessionGroupsCompanion data) {
    return SessionGroup(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionGroup(')
          ..write('sessionId: $sessionId, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionGroup && other.sessionId == this.sessionId && other.groupId == this.groupId);
}

class SessionGroupsCompanion extends UpdateCompanion<SessionGroup> {
  final Value<int> sessionId;
  final Value<int> groupId;
  final Value<int> rowid;
  const SessionGroupsCompanion({
    this.sessionId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionGroupsCompanion.insert({required int sessionId, required int groupId, this.rowid = const Value.absent()})
    : sessionId = Value(sessionId),
      groupId = Value(groupId);
  static Insertable<SessionGroup> custom({
    Expression<int>? sessionId,
    Expression<int>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionGroupsCompanion copyWith({Value<int>? sessionId, Value<int>? groupId, Value<int>? rowid}) {
    return SessionGroupsCompanion(
      sessionId: sessionId ?? this.sessionId,
      groupId: groupId ?? this.groupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionGroupsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES muscle_groups (id) ON DELETE SET NULL'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseKind, int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<ExerciseKind>($ExercisesTable.$converterkind);
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("hidden" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _guideIdMeta = const VerificationMeta('guideId');
  @override
  late final GeneratedColumn<String> guideId = GeneratedColumn<String>(
    'guide_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, groupId, kind, hidden, isCustom, guideId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<Exercise> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta, groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('hidden')) {
      context.handle(_hiddenMeta, hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta, isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('guide_id')) {
      context.handle(_guideIdMeta, guideId.isAcceptableOrUnknown(data['guide_id']!, _guideIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}group_id']),
      kind: $ExercisesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}kind'])!,
      ),
      hidden: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}hidden'])!,
      isCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      guideId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}guide_id']),
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExerciseKind, int, int> $converterkind = const EnumIndexConverter<ExerciseKind>(
    ExerciseKind.values,
  );
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String name;
  final int? groupId;
  final ExerciseKind kind;
  final bool hidden;
  final bool isCustom;

  /// The exercise guide entry this exercise shows (schema v3); null = none.
  final String? guideId;
  const Exercise({
    required this.id,
    required this.name,
    this.groupId,
    required this.kind,
    required this.hidden,
    required this.isCustom,
    this.guideId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<int>(groupId);
    }
    {
      map['kind'] = Variable<int>($ExercisesTable.$converterkind.toSql(kind));
    }
    map['hidden'] = Variable<bool>(hidden);
    map['is_custom'] = Variable<bool>(isCustom);
    if (!nullToAbsent || guideId != null) {
      map['guide_id'] = Variable<String>(guideId);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      groupId: groupId == null && nullToAbsent ? const Value.absent() : Value(groupId),
      kind: Value(kind),
      hidden: Value(hidden),
      isCustom: Value(isCustom),
      guideId: guideId == null && nullToAbsent ? const Value.absent() : Value(guideId),
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      groupId: serializer.fromJson<int?>(json['groupId']),
      kind: $ExercisesTable.$converterkind.fromJson(serializer.fromJson<int>(json['kind'])),
      hidden: serializer.fromJson<bool>(json['hidden']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      guideId: serializer.fromJson<String?>(json['guideId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'groupId': serializer.toJson<int?>(groupId),
      'kind': serializer.toJson<int>($ExercisesTable.$converterkind.toJson(kind)),
      'hidden': serializer.toJson<bool>(hidden),
      'isCustom': serializer.toJson<bool>(isCustom),
      'guideId': serializer.toJson<String?>(guideId),
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    Value<int?> groupId = const Value.absent(),
    ExerciseKind? kind,
    bool? hidden,
    bool? isCustom,
    Value<String?> guideId = const Value.absent(),
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    groupId: groupId.present ? groupId.value : this.groupId,
    kind: kind ?? this.kind,
    hidden: hidden ?? this.hidden,
    isCustom: isCustom ?? this.isCustom,
    guideId: guideId.present ? guideId.value : this.guideId,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      kind: data.kind.present ? data.kind.value : this.kind,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      guideId: data.guideId.present ? data.guideId.value : this.guideId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('kind: $kind, ')
          ..write('hidden: $hidden, ')
          ..write('isCustom: $isCustom, ')
          ..write('guideId: $guideId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, groupId, kind, hidden, isCustom, guideId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.groupId == this.groupId &&
          other.kind == this.kind &&
          other.hidden == this.hidden &&
          other.isCustom == this.isCustom &&
          other.guideId == this.guideId);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> groupId;
  final Value<ExerciseKind> kind;
  final Value<bool> hidden;
  final Value<bool> isCustom;
  final Value<String?> guideId;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.groupId = const Value.absent(),
    this.kind = const Value.absent(),
    this.hidden = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.guideId = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.groupId = const Value.absent(),
    required ExerciseKind kind,
    this.hidden = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.guideId = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? groupId,
    Expression<int>? kind,
    Expression<bool>? hidden,
    Expression<bool>? isCustom,
    Expression<String>? guideId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (groupId != null) 'group_id': groupId,
      if (kind != null) 'kind': kind,
      if (hidden != null) 'hidden': hidden,
      if (isCustom != null) 'is_custom': isCustom,
      if (guideId != null) 'guide_id': guideId,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? groupId,
    Value<ExerciseKind>? kind,
    Value<bool>? hidden,
    Value<bool>? isCustom,
    Value<String?>? guideId,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      kind: kind ?? this.kind,
      hidden: hidden ?? this.hidden,
      isCustom: isCustom ?? this.isCustom,
      guideId: guideId ?? this.guideId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>($ExercisesTable.$converterkind.toSql(kind.value));
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (guideId.present) {
      map['guide_id'] = Variable<String>(guideId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('kind: $kind, ')
          ..write('hidden: $hidden, ')
          ..write('isCustom: $isCustom, ')
          ..write('guideId: $guideId')
          ..write(')'))
        .toString();
  }
}

class $SessionExercisesTable extends SessionExercises with TableInfo<$SessionExercisesTable, SessionExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES sessions (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES exercises (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, exerciseId, position, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<SessionExercise> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta, sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(_exerciseIdMeta, exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExercise(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      exerciseId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}exercise_id'])!,
      position: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $SessionExercisesTable createAlias(String alias) {
    return $SessionExercisesTable(attachedDatabase, alias);
  }
}

class SessionExercise extends DataClass implements Insertable<SessionExercise> {
  final int id;
  final int sessionId;
  final int exerciseId;
  final int position;
  final String? note;
  const SessionExercise({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.position,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return SessionExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory SessionExercise.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExercise(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'position': serializer.toJson<int>(position),
      'note': serializer.toJson<String?>(note),
    };
  }

  SessionExercise copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    int? position,
    Value<String?> note = const Value.absent(),
  }) => SessionExercise(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    note: note.present ? note.value : this.note,
  );
  SessionExercise copyWithCompanion(SessionExercisesCompanion data) {
    return SessionExercise(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercise(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, exerciseId, position, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExercise &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.note == this.note);
}

class SessionExercisesCompanion extends UpdateCompanion<SessionExercise> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> exerciseId;
  final Value<int> position;
  final Value<String?> note;
  const SessionExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.note = const Value.absent(),
  });
  SessionExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int exerciseId,
    required int position,
    this.note = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<SessionExercise> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? exerciseId,
    Expression<int>? position,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (note != null) 'note': note,
    });
  }

  SessionExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? exerciseId,
    Value<int>? position,
    Value<String?>? note,
  }) {
    return SessionExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $ExerciseSetsTable extends ExerciseSets with TableInfo<$ExerciseSetsTable, ExerciseSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _sessionExerciseIdMeta = const VerificationMeta('sessionExerciseId');
  @override
  late final GeneratedColumn<int> sessionExerciseId = GeneratedColumn<int>(
    'session_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES session_exercises (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta('durationSec');
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta('distanceKm');
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionExerciseId, position, weightKg, reps, durationSec, distanceKm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_sets';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseSet> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_exercise_id')) {
      context.handle(
        _sessionExerciseIdMeta,
        sessionExerciseId.isAcceptableOrUnknown(data['session_exercise_id']!, _sessionExerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta, weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(_repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('duration_sec')) {
      context.handle(_durationSecMeta, durationSec.isAcceptableOrUnknown(data['duration_sec']!, _durationSecMeta));
    }
    if (data.containsKey('distance_km')) {
      context.handle(_distanceKmMeta, distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseSet(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      weightKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      reps: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reps']),
      durationSec: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}duration_sec']),
      distanceKm: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}distance_km']),
    );
  }

  @override
  $ExerciseSetsTable createAlias(String alias) {
    return $ExerciseSetsTable(attachedDatabase, alias);
  }
}

class ExerciseSet extends DataClass implements Insertable<ExerciseSet> {
  final int id;
  final int sessionExerciseId;
  final int position;
  final double? weightKg;
  final int? reps;
  final int? durationSec;
  final double? distanceKm;
  const ExerciseSet({
    required this.id,
    required this.sessionExerciseId,
    required this.position,
    this.weightKg,
    this.reps,
    this.durationSec,
    this.distanceKm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_exercise_id'] = Variable<int>(sessionExerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || durationSec != null) {
      map['duration_sec'] = Variable<int>(durationSec);
    }
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<double>(distanceKm);
    }
    return map;
  }

  ExerciseSetsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseSetsCompanion(
      id: Value(id),
      sessionExerciseId: Value(sessionExerciseId),
      position: Value(position),
      weightKg: weightKg == null && nullToAbsent ? const Value.absent() : Value(weightKg),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      durationSec: durationSec == null && nullToAbsent ? const Value.absent() : Value(durationSec),
      distanceKm: distanceKm == null && nullToAbsent ? const Value.absent() : Value(distanceKm),
    );
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseSet(
      id: serializer.fromJson<int>(json['id']),
      sessionExerciseId: serializer.fromJson<int>(json['sessionExerciseId']),
      position: serializer.fromJson<int>(json['position']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      reps: serializer.fromJson<int?>(json['reps']),
      durationSec: serializer.fromJson<int?>(json['durationSec']),
      distanceKm: serializer.fromJson<double?>(json['distanceKm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionExerciseId': serializer.toJson<int>(sessionExerciseId),
      'position': serializer.toJson<int>(position),
      'weightKg': serializer.toJson<double?>(weightKg),
      'reps': serializer.toJson<int?>(reps),
      'durationSec': serializer.toJson<int?>(durationSec),
      'distanceKm': serializer.toJson<double?>(distanceKm),
    };
  }

  ExerciseSet copyWith({
    int? id,
    int? sessionExerciseId,
    int? position,
    Value<double?> weightKg = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> durationSec = const Value.absent(),
    Value<double?> distanceKm = const Value.absent(),
  }) => ExerciseSet(
    id: id ?? this.id,
    sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
    position: position ?? this.position,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    reps: reps.present ? reps.value : this.reps,
    durationSec: durationSec.present ? durationSec.value : this.durationSec,
    distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
  );
  ExerciseSet copyWithCompanion(ExerciseSetsCompanion data) {
    return ExerciseSet(
      id: data.id.present ? data.id.value : this.id,
      sessionExerciseId: data.sessionExerciseId.present ? data.sessionExerciseId.value : this.sessionExerciseId,
      position: data.position.present ? data.position.value : this.position,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      durationSec: data.durationSec.present ? data.durationSec.value : this.durationSec,
      distanceKm: data.distanceKm.present ? data.distanceKm.value : this.distanceKm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSet(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('durationSec: $durationSec, ')
          ..write('distanceKm: $distanceKm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionExerciseId, position, weightKg, reps, durationSec, distanceKm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseSet &&
          other.id == this.id &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.position == this.position &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.durationSec == this.durationSec &&
          other.distanceKm == this.distanceKm);
}

class ExerciseSetsCompanion extends UpdateCompanion<ExerciseSet> {
  final Value<int> id;
  final Value<int> sessionExerciseId;
  final Value<int> position;
  final Value<double?> weightKg;
  final Value<int?> reps;
  final Value<int?> durationSec;
  final Value<double?> distanceKm;
  const ExerciseSetsCompanion({
    this.id = const Value.absent(),
    this.sessionExerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.distanceKm = const Value.absent(),
  });
  ExerciseSetsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionExerciseId,
    required int position,
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.distanceKm = const Value.absent(),
  }) : sessionExerciseId = Value(sessionExerciseId),
       position = Value(position);
  static Insertable<ExerciseSet> custom({
    Expression<int>? id,
    Expression<int>? sessionExerciseId,
    Expression<int>? position,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<int>? durationSec,
    Expression<double>? distanceKm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (position != null) 'position': position,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (durationSec != null) 'duration_sec': durationSec,
      if (distanceKm != null) 'distance_km': distanceKm,
    });
  }

  ExerciseSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionExerciseId,
    Value<int>? position,
    Value<double?>? weightKg,
    Value<int?>? reps,
    Value<int?>? durationSec,
    Value<double?>? distanceKm,
  }) {
    return ExerciseSetsCompanion(
      id: id ?? this.id,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      position: position ?? this.position,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      durationSec: durationSec ?? this.durationSec,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<int>(sessionExerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('durationSec: $durationSec, ')
          ..write('distanceKm: $distanceKm')
          ..write(')'))
        .toString();
  }
}

class $BodyWeightsTable extends BodyWeights with TableInfo<$BodyWeightsTable, BodyWeight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyWeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<int> dayKey = GeneratedColumn<int>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [dayKey, weightKg, recordedAt, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_weights';
  @override
  VerificationContext validateIntegrity(Insertable<BodyWeight> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta, dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta, weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(_recordedAtMeta, recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayKey};
  @override
  BodyWeight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyWeight(
      dayKey: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day_key'])!,
      weightKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      recordedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source']),
    );
  }

  @override
  $BodyWeightsTable createAlias(String alias) {
    return $BodyWeightsTable(attachedDatabase, alias);
  }
}

class BodyWeight extends DataClass implements Insertable<BodyWeight> {
  final int dayKey;
  final double weightKg;
  final DateTime recordedAt;

  /// Where it came from (schema v3): null = typed in GYMTRX, otherwise the
  /// package of the app that wrote it to Health Connect (e.g. a smart scale).
  final String? source;
  const BodyWeight({required this.dayKey, required this.weightKg, required this.recordedAt, this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_key'] = Variable<int>(dayKey);
    map['weight_kg'] = Variable<double>(weightKg);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    return map;
  }

  BodyWeightsCompanion toCompanion(bool nullToAbsent) {
    return BodyWeightsCompanion(
      dayKey: Value(dayKey),
      weightKg: Value(weightKg),
      recordedAt: Value(recordedAt),
      source: source == null && nullToAbsent ? const Value.absent() : Value(source),
    );
  }

  factory BodyWeight.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyWeight(
      dayKey: serializer.fromJson<int>(json['dayKey']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      source: serializer.fromJson<String?>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayKey': serializer.toJson<int>(dayKey),
      'weightKg': serializer.toJson<double>(weightKg),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'source': serializer.toJson<String?>(source),
    };
  }

  BodyWeight copyWith({
    int? dayKey,
    double? weightKg,
    DateTime? recordedAt,
    Value<String?> source = const Value.absent(),
  }) => BodyWeight(
    dayKey: dayKey ?? this.dayKey,
    weightKg: weightKg ?? this.weightKg,
    recordedAt: recordedAt ?? this.recordedAt,
    source: source.present ? source.value : this.source,
  );
  BodyWeight copyWithCompanion(BodyWeightsCompanion data) {
    return BodyWeight(
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      recordedAt: data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeight(')
          ..write('dayKey: $dayKey, ')
          ..write('weightKg: $weightKg, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayKey, weightKg, recordedAt, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyWeight &&
          other.dayKey == this.dayKey &&
          other.weightKg == this.weightKg &&
          other.recordedAt == this.recordedAt &&
          other.source == this.source);
}

class BodyWeightsCompanion extends UpdateCompanion<BodyWeight> {
  final Value<int> dayKey;
  final Value<double> weightKg;
  final Value<DateTime> recordedAt;
  final Value<String?> source;
  const BodyWeightsCompanion({
    this.dayKey = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.source = const Value.absent(),
  });
  BodyWeightsCompanion.insert({
    this.dayKey = const Value.absent(),
    required double weightKg,
    this.recordedAt = const Value.absent(),
    this.source = const Value.absent(),
  }) : weightKg = Value(weightKg);
  static Insertable<BodyWeight> custom({
    Expression<int>? dayKey,
    Expression<double>? weightKg,
    Expression<DateTime>? recordedAt,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (dayKey != null) 'day_key': dayKey,
      if (weightKg != null) 'weight_kg': weightKg,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (source != null) 'source': source,
    });
  }

  BodyWeightsCompanion copyWith({
    Value<int>? dayKey,
    Value<double>? weightKg,
    Value<DateTime>? recordedAt,
    Value<String?>? source,
  }) {
    return BodyWeightsCompanion(
      dayKey: dayKey ?? this.dayKey,
      weightKg: weightKg ?? this.weightKg,
      recordedAt: recordedAt ?? this.recordedAt,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayKey.present) {
      map['day_key'] = Variable<int>(dayKey.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightsCompanion(')
          ..write('dayKey: $dayKey, ')
          ..write('weightKg: $weightKg, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $ProgressPhotosTable extends ProgressPhotos with TableInfo<$ProgressPhotosTable, ProgressPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<int> dayKey = GeneratedColumn<int>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, dayKey, fileName, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_photos';
  @override
  VerificationContext validateIntegrity(Insertable<ProgressPhoto> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta, dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta, fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressPhoto(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dayKey: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day_key'])!,
      fileName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ProgressPhotosTable createAlias(String alias) {
    return $ProgressPhotosTable(attachedDatabase, alias);
  }
}

class ProgressPhoto extends DataClass implements Insertable<ProgressPhoto> {
  final int id;
  final int dayKey;
  final String fileName;
  final String? note;
  final DateTime createdAt;
  const ProgressPhoto({
    required this.id,
    required this.dayKey,
    required this.fileName,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_key'] = Variable<int>(dayKey);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProgressPhotosCompanion toCompanion(bool nullToAbsent) {
    return ProgressPhotosCompanion(
      id: Value(id),
      dayKey: Value(dayKey),
      fileName: Value(fileName),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory ProgressPhoto.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressPhoto(
      id: serializer.fromJson<int>(json['id']),
      dayKey: serializer.fromJson<int>(json['dayKey']),
      fileName: serializer.fromJson<String>(json['fileName']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayKey': serializer.toJson<int>(dayKey),
      'fileName': serializer.toJson<String>(fileName),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProgressPhoto copyWith({
    int? id,
    int? dayKey,
    String? fileName,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => ProgressPhoto(
    id: id ?? this.id,
    dayKey: dayKey ?? this.dayKey,
    fileName: fileName ?? this.fileName,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  ProgressPhoto copyWithCompanion(ProgressPhotosCompanion data) {
    return ProgressPhoto(
      id: data.id.present ? data.id.value : this.id,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressPhoto(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('fileName: $fileName, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayKey, fileName, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressPhoto &&
          other.id == this.id &&
          other.dayKey == this.dayKey &&
          other.fileName == this.fileName &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class ProgressPhotosCompanion extends UpdateCompanion<ProgressPhoto> {
  final Value<int> id;
  final Value<int> dayKey;
  final Value<String> fileName;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const ProgressPhotosCompanion({
    this.id = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.fileName = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProgressPhotosCompanion.insert({
    this.id = const Value.absent(),
    required int dayKey,
    required String fileName,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : dayKey = Value(dayKey),
       fileName = Value(fileName);
  static Insertable<ProgressPhoto> custom({
    Expression<int>? id,
    Expression<int>? dayKey,
    Expression<String>? fileName,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayKey != null) 'day_key': dayKey,
      if (fileName != null) 'file_name': fileName,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProgressPhotosCompanion copyWith({
    Value<int>? id,
    Value<int>? dayKey,
    Value<String>? fileName,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return ProgressPhotosCompanion(
      id: id ?? this.id,
      dayKey: dayKey ?? this.dayKey,
      fileName: fileName ?? this.fileName,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<int>(dayKey.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressPhotosCompanion(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('fileName: $fileName, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<GoalKind, int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<GoalKind>($GoalsTable.$converterkind);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES exercises (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _targetKgMeta = const VerificationMeta('targetKg');
  @override
  late final GeneratedColumn<double> targetKg = GeneratedColumn<double>(
    'target_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta('targetReps');
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startKgMeta = const VerificationMeta('startKg');
  @override
  late final GeneratedColumn<double> startKg = GeneratedColumn<double>(
    'start_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdDayKeyMeta = const VerificationMeta('createdDayKey');
  @override
  late final GeneratedColumn<int> createdDayKey = GeneratedColumn<int>(
    'created_day_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _achievedDayKeyMeta = const VerificationMeta('achievedDayKey');
  @override
  late final GeneratedColumn<int> achievedDayKey = GeneratedColumn<int>(
    'achieved_day_key',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    exerciseId,
    targetKg,
    targetReps,
    startKg,
    createdDayKey,
    createdAt,
    achievedDayKey,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(_exerciseIdMeta, exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta));
    }
    if (data.containsKey('target_kg')) {
      context.handle(_targetKgMeta, targetKg.isAcceptableOrUnknown(data['target_kg']!, _targetKgMeta));
    } else if (isInserting) {
      context.missing(_targetKgMeta);
    }
    if (data.containsKey('target_reps')) {
      context.handle(_targetRepsMeta, targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta));
    }
    if (data.containsKey('start_kg')) {
      context.handle(_startKgMeta, startKg.isAcceptableOrUnknown(data['start_kg']!, _startKgMeta));
    }
    if (data.containsKey('created_day_key')) {
      context.handle(
        _createdDayKeyMeta,
        createdDayKey.isAcceptableOrUnknown(data['created_day_key']!, _createdDayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_createdDayKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('achieved_day_key')) {
      context.handle(
        _achievedDayKeyMeta,
        achievedDayKey.isAcceptableOrUnknown(data['achieved_day_key']!, _achievedDayKeyMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta, sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: $GoalsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}kind'])!,
      ),
      exerciseId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}exercise_id']),
      targetKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}target_kg'])!,
      targetReps: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}target_reps']),
      startKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}start_kg']),
      createdDayKey: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_day_key'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      achievedDayKey: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}achieved_day_key']),
      sortOrder: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GoalKind, int, int> $converterkind = const EnumIndexConverter<GoalKind>(GoalKind.values);
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final GoalKind kind;
  final int? exerciseId;
  final double targetKg;

  /// Lift goals: reps the target weight must be lifted for; null = 1.
  final int? targetReps;

  /// Body-weight goals: the weight when the goal was set, for progress.
  final double? startKg;
  final int createdDayKey;
  final DateTime createdAt;

  /// Set once, the first time the goal is reached.
  final int? achievedDayKey;
  final int sortOrder;
  const Goal({
    required this.id,
    required this.kind,
    this.exerciseId,
    required this.targetKg,
    this.targetReps,
    this.startKg,
    required this.createdDayKey,
    required this.createdAt,
    this.achievedDayKey,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<int>($GoalsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<int>(exerciseId);
    }
    map['target_kg'] = Variable<double>(targetKg);
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    if (!nullToAbsent || startKg != null) {
      map['start_kg'] = Variable<double>(startKg);
    }
    map['created_day_key'] = Variable<int>(createdDayKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || achievedDayKey != null) {
      map['achieved_day_key'] = Variable<int>(achievedDayKey);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      kind: Value(kind),
      exerciseId: exerciseId == null && nullToAbsent ? const Value.absent() : Value(exerciseId),
      targetKg: Value(targetKg),
      targetReps: targetReps == null && nullToAbsent ? const Value.absent() : Value(targetReps),
      startKg: startKg == null && nullToAbsent ? const Value.absent() : Value(startKg),
      createdDayKey: Value(createdDayKey),
      createdAt: Value(createdAt),
      achievedDayKey: achievedDayKey == null && nullToAbsent ? const Value.absent() : Value(achievedDayKey),
      sortOrder: Value(sortOrder),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      kind: $GoalsTable.$converterkind.fromJson(serializer.fromJson<int>(json['kind'])),
      exerciseId: serializer.fromJson<int?>(json['exerciseId']),
      targetKg: serializer.fromJson<double>(json['targetKg']),
      targetReps: serializer.fromJson<int?>(json['targetReps']),
      startKg: serializer.fromJson<double?>(json['startKg']),
      createdDayKey: serializer.fromJson<int>(json['createdDayKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      achievedDayKey: serializer.fromJson<int?>(json['achievedDayKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<int>($GoalsTable.$converterkind.toJson(kind)),
      'exerciseId': serializer.toJson<int?>(exerciseId),
      'targetKg': serializer.toJson<double>(targetKg),
      'targetReps': serializer.toJson<int?>(targetReps),
      'startKg': serializer.toJson<double?>(startKg),
      'createdDayKey': serializer.toJson<int>(createdDayKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'achievedDayKey': serializer.toJson<int?>(achievedDayKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Goal copyWith({
    int? id,
    GoalKind? kind,
    Value<int?> exerciseId = const Value.absent(),
    double? targetKg,
    Value<int?> targetReps = const Value.absent(),
    Value<double?> startKg = const Value.absent(),
    int? createdDayKey,
    DateTime? createdAt,
    Value<int?> achievedDayKey = const Value.absent(),
    int? sortOrder,
  }) => Goal(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    targetKg: targetKg ?? this.targetKg,
    targetReps: targetReps.present ? targetReps.value : this.targetReps,
    startKg: startKg.present ? startKg.value : this.startKg,
    createdDayKey: createdDayKey ?? this.createdDayKey,
    createdAt: createdAt ?? this.createdAt,
    achievedDayKey: achievedDayKey.present ? achievedDayKey.value : this.achievedDayKey,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      targetKg: data.targetKg.present ? data.targetKg.value : this.targetKg,
      targetReps: data.targetReps.present ? data.targetReps.value : this.targetReps,
      startKg: data.startKg.present ? data.startKg.value : this.startKg,
      createdDayKey: data.createdDayKey.present ? data.createdDayKey.value : this.createdDayKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      achievedDayKey: data.achievedDayKey.present ? data.achievedDayKey.value : this.achievedDayKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('targetKg: $targetKg, ')
          ..write('targetReps: $targetReps, ')
          ..write('startKg: $startKg, ')
          ..write('createdDayKey: $createdDayKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('achievedDayKey: $achievedDayKey, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    exerciseId,
    targetKg,
    targetReps,
    startKg,
    createdDayKey,
    createdAt,
    achievedDayKey,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.exerciseId == this.exerciseId &&
          other.targetKg == this.targetKg &&
          other.targetReps == this.targetReps &&
          other.startKg == this.startKg &&
          other.createdDayKey == this.createdDayKey &&
          other.createdAt == this.createdAt &&
          other.achievedDayKey == this.achievedDayKey &&
          other.sortOrder == this.sortOrder);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<GoalKind> kind;
  final Value<int?> exerciseId;
  final Value<double> targetKg;
  final Value<int?> targetReps;
  final Value<double?> startKg;
  final Value<int> createdDayKey;
  final Value<DateTime> createdAt;
  final Value<int?> achievedDayKey;
  final Value<int> sortOrder;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.targetKg = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.startKg = const Value.absent(),
    this.createdDayKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.achievedDayKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required GoalKind kind,
    this.exerciseId = const Value.absent(),
    required double targetKg,
    this.targetReps = const Value.absent(),
    this.startKg = const Value.absent(),
    required int createdDayKey,
    this.createdAt = const Value.absent(),
    this.achievedDayKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : kind = Value(kind),
       targetKg = Value(targetKg),
       createdDayKey = Value(createdDayKey);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<int>? kind,
    Expression<int>? exerciseId,
    Expression<double>? targetKg,
    Expression<int>? targetReps,
    Expression<double>? startKg,
    Expression<int>? createdDayKey,
    Expression<DateTime>? createdAt,
    Expression<int>? achievedDayKey,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (targetKg != null) 'target_kg': targetKg,
      if (targetReps != null) 'target_reps': targetReps,
      if (startKg != null) 'start_kg': startKg,
      if (createdDayKey != null) 'created_day_key': createdDayKey,
      if (createdAt != null) 'created_at': createdAt,
      if (achievedDayKey != null) 'achieved_day_key': achievedDayKey,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<GoalKind>? kind,
    Value<int?>? exerciseId,
    Value<double>? targetKg,
    Value<int?>? targetReps,
    Value<double?>? startKg,
    Value<int>? createdDayKey,
    Value<DateTime>? createdAt,
    Value<int?>? achievedDayKey,
    Value<int>? sortOrder,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      exerciseId: exerciseId ?? this.exerciseId,
      targetKg: targetKg ?? this.targetKg,
      targetReps: targetReps ?? this.targetReps,
      startKg: startKg ?? this.startKg,
      createdDayKey: createdDayKey ?? this.createdDayKey,
      createdAt: createdAt ?? this.createdAt,
      achievedDayKey: achievedDayKey ?? this.achievedDayKey,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>($GoalsTable.$converterkind.toSql(kind.value));
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (targetKg.present) {
      map['target_kg'] = Variable<double>(targetKg.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (startKg.present) {
      map['start_kg'] = Variable<double>(startKg.value);
    }
    if (createdDayKey.present) {
      map['created_day_key'] = Variable<int>(createdDayKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (achievedDayKey.present) {
      map['achieved_day_key'] = Variable<int>(achievedDayKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('targetKg: $targetKg, ')
          ..write('targetReps: $targetReps, ')
          ..write('startKg: $startKg, ')
          ..write('createdDayKey: $createdDayKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('achievedDayKey: $achievedDayKey, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ProgramDaysTable extends ProgramDays with TableInfo<$ProgramDaysTable, ProgramDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekdayMeta = const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [weekday, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_days';
  @override
  VerificationContext validateIntegrity(Insertable<ProgramDay> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta, weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekday};
  @override
  ProgramDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramDay(
      weekday: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}weekday'])!,
      label: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}label'])!,
    );
  }

  @override
  $ProgramDaysTable createAlias(String alias) {
    return $ProgramDaysTable(attachedDatabase, alias);
  }
}

class ProgramDay extends DataClass implements Insertable<ProgramDay> {
  /// ISO weekday, 1 = Monday … 7 = Sunday.
  final int weekday;
  final String label;
  const ProgramDay({required this.weekday, required this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['weekday'] = Variable<int>(weekday);
    map['label'] = Variable<String>(label);
    return map;
  }

  ProgramDaysCompanion toCompanion(bool nullToAbsent) {
    return ProgramDaysCompanion(weekday: Value(weekday), label: Value(label));
  }

  factory ProgramDay.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramDay(
      weekday: serializer.fromJson<int>(json['weekday']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'weekday': serializer.toJson<int>(weekday), 'label': serializer.toJson<String>(label)};
  }

  ProgramDay copyWith({int? weekday, String? label}) =>
      ProgramDay(weekday: weekday ?? this.weekday, label: label ?? this.label);
  ProgramDay copyWithCompanion(ProgramDaysCompanion data) {
    return ProgramDay(
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDay(')
          ..write('weekday: $weekday, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekday, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ProgramDay && other.weekday == this.weekday && other.label == this.label);
}

class ProgramDaysCompanion extends UpdateCompanion<ProgramDay> {
  final Value<int> weekday;
  final Value<String> label;
  const ProgramDaysCompanion({this.weekday = const Value.absent(), this.label = const Value.absent()});
  ProgramDaysCompanion.insert({this.weekday = const Value.absent(), required String label}) : label = Value(label);
  static Insertable<ProgramDay> custom({Expression<int>? weekday, Expression<String>? label}) {
    return RawValuesInsertable({if (weekday != null) 'weekday': weekday, if (label != null) 'label': label});
  }

  ProgramDaysCompanion copyWith({Value<int>? weekday, Value<String>? label}) {
    return ProgramDaysCompanion(weekday: weekday ?? this.weekday, label: label ?? this.label);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDaysCompanion(')
          ..write('weekday: $weekday, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }
}

class $ProgramDayGroupsTable extends ProgramDayGroups with TableInfo<$ProgramDayGroupsTable, ProgramDayGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramDayGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekdayMeta = const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES program_days (weekday) ON DELETE CASCADE'),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES muscle_groups (id) ON DELETE CASCADE'),
  );
  @override
  List<GeneratedColumn> get $columns => [weekday, groupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_day_groups';
  @override
  VerificationContext validateIntegrity(Insertable<ProgramDayGroup> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta, weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta, groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekday, groupId};
  @override
  ProgramDayGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramDayGroup(
      weekday: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}weekday'])!,
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
    );
  }

  @override
  $ProgramDayGroupsTable createAlias(String alias) {
    return $ProgramDayGroupsTable(attachedDatabase, alias);
  }
}

class ProgramDayGroup extends DataClass implements Insertable<ProgramDayGroup> {
  final int weekday;
  final int groupId;
  const ProgramDayGroup({required this.weekday, required this.groupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['weekday'] = Variable<int>(weekday);
    map['group_id'] = Variable<int>(groupId);
    return map;
  }

  ProgramDayGroupsCompanion toCompanion(bool nullToAbsent) {
    return ProgramDayGroupsCompanion(weekday: Value(weekday), groupId: Value(groupId));
  }

  factory ProgramDayGroup.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramDayGroup(
      weekday: serializer.fromJson<int>(json['weekday']),
      groupId: serializer.fromJson<int>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'weekday': serializer.toJson<int>(weekday), 'groupId': serializer.toJson<int>(groupId)};
  }

  ProgramDayGroup copyWith({int? weekday, int? groupId}) =>
      ProgramDayGroup(weekday: weekday ?? this.weekday, groupId: groupId ?? this.groupId);
  ProgramDayGroup copyWithCompanion(ProgramDayGroupsCompanion data) {
    return ProgramDayGroup(
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDayGroup(')
          ..write('weekday: $weekday, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekday, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramDayGroup && other.weekday == this.weekday && other.groupId == this.groupId);
}

class ProgramDayGroupsCompanion extends UpdateCompanion<ProgramDayGroup> {
  final Value<int> weekday;
  final Value<int> groupId;
  final Value<int> rowid;
  const ProgramDayGroupsCompanion({
    this.weekday = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramDayGroupsCompanion.insert({required int weekday, required int groupId, this.rowid = const Value.absent()})
    : weekday = Value(weekday),
      groupId = Value(groupId);
  static Insertable<ProgramDayGroup> custom({
    Expression<int>? weekday,
    Expression<int>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (weekday != null) 'weekday': weekday,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramDayGroupsCompanion copyWith({Value<int>? weekday, Value<int>? groupId, Value<int>? rowid}) {
    return ProgramDayGroupsCompanion(
      weekday: weekday ?? this.weekday,
      groupId: groupId ?? this.groupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDayGroupsCompanion(')
          ..write('weekday: $weekday, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramDayExercisesTable extends ProgramDayExercises
    with TableInfo<$ProgramDayExercisesTable, ProgramDayExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramDayExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekdayMeta = const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES program_days (weekday) ON DELETE CASCADE'),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES exercises (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [weekday, exerciseId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_day_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<ProgramDayExercise> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta, weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(_exerciseIdMeta, exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekday, exerciseId};
  @override
  ProgramDayExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramDayExercise(
      weekday: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}weekday'])!,
      exerciseId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}exercise_id'])!,
      position: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $ProgramDayExercisesTable createAlias(String alias) {
    return $ProgramDayExercisesTable(attachedDatabase, alias);
  }
}

class ProgramDayExercise extends DataClass implements Insertable<ProgramDayExercise> {
  final int weekday;
  final int exerciseId;
  final int position;
  const ProgramDayExercise({required this.weekday, required this.exerciseId, required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['weekday'] = Variable<int>(weekday);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['position'] = Variable<int>(position);
    return map;
  }

  ProgramDayExercisesCompanion toCompanion(bool nullToAbsent) {
    return ProgramDayExercisesCompanion(
      weekday: Value(weekday),
      exerciseId: Value(exerciseId),
      position: Value(position),
    );
  }

  factory ProgramDayExercise.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramDayExercise(
      weekday: serializer.fromJson<int>(json['weekday']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekday': serializer.toJson<int>(weekday),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'position': serializer.toJson<int>(position),
    };
  }

  ProgramDayExercise copyWith({int? weekday, int? exerciseId, int? position}) => ProgramDayExercise(
    weekday: weekday ?? this.weekday,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
  );
  ProgramDayExercise copyWithCompanion(ProgramDayExercisesCompanion data) {
    return ProgramDayExercise(
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDayExercise(')
          ..write('weekday: $weekday, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekday, exerciseId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramDayExercise &&
          other.weekday == this.weekday &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position);
}

class ProgramDayExercisesCompanion extends UpdateCompanion<ProgramDayExercise> {
  final Value<int> weekday;
  final Value<int> exerciseId;
  final Value<int> position;
  final Value<int> rowid;
  const ProgramDayExercisesCompanion({
    this.weekday = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramDayExercisesCompanion.insert({
    required int weekday,
    required int exerciseId,
    required int position,
    this.rowid = const Value.absent(),
  }) : weekday = Value(weekday),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<ProgramDayExercise> custom({
    Expression<int>? weekday,
    Expression<int>? exerciseId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (weekday != null) 'weekday': weekday,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramDayExercisesCompanion copyWith({
    Value<int>? weekday,
    Value<int>? exerciseId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return ProgramDayExercisesCompanion(
      weekday: weekday ?? this.weekday,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDayExercisesCompanion(')
          ..write('weekday: $weekday, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionHealthTable extends SessionHealth with TableInfo<$SessionHealthTable, SessionHealthData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionHealthTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES sessions (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgHrMeta = const VerificationMeta('avgHr');
  @override
  late final GeneratedColumn<int> avgHr = GeneratedColumn<int>(
    'avg_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHrMeta = const VerificationMeta('maxHr');
  @override
  late final GeneratedColumn<int> maxHr = GeneratedColumn<int>(
    'max_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeKcalMeta = const VerificationMeta('activeKcal');
  @override
  late final GeneratedColumn<int> activeKcal = GeneratedColumn<int>(
    'active_kcal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, startAt, endAt, avgHr, maxHr, activeKcal, source, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_health';
  @override
  VerificationContext validateIntegrity(Insertable<SessionHealthData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta, sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta, startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(_endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('avg_hr')) {
      context.handle(_avgHrMeta, avgHr.isAcceptableOrUnknown(data['avg_hr']!, _avgHrMeta));
    }
    if (data.containsKey('max_hr')) {
      context.handle(_maxHrMeta, maxHr.isAcceptableOrUnknown(data['max_hr']!, _maxHrMeta));
    }
    if (data.containsKey('active_kcal')) {
      context.handle(_activeKcalMeta, activeKcal.isAcceptableOrUnknown(data['active_kcal']!, _activeKcalMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta, fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  SessionHealthData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionHealthData(
      sessionId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      startAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_at'])!,
      endAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_at'])!,
      avgHr: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}avg_hr']),
      maxHr: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}max_hr']),
      activeKcal: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}active_kcal']),
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source']),
      fetchedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $SessionHealthTable createAlias(String alias) {
    return $SessionHealthTable(attachedDatabase, alias);
  }
}

class SessionHealthData extends DataClass implements Insertable<SessionHealthData> {
  final int sessionId;

  /// The window the numbers cover.
  final DateTime startAt;
  final DateTime endAt;
  final int? avgHr;
  final int? maxHr;
  final int? activeKcal;

  /// Package of the app whose workout set the window; null = the session's own start time.
  final String? source;
  final DateTime fetchedAt;
  const SessionHealthData({
    required this.sessionId,
    required this.startAt,
    required this.endAt,
    this.avgHr,
    this.maxHr,
    this.activeKcal,
    this.source,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    if (!nullToAbsent || avgHr != null) {
      map['avg_hr'] = Variable<int>(avgHr);
    }
    if (!nullToAbsent || maxHr != null) {
      map['max_hr'] = Variable<int>(maxHr);
    }
    if (!nullToAbsent || activeKcal != null) {
      map['active_kcal'] = Variable<int>(activeKcal);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  SessionHealthCompanion toCompanion(bool nullToAbsent) {
    return SessionHealthCompanion(
      sessionId: Value(sessionId),
      startAt: Value(startAt),
      endAt: Value(endAt),
      avgHr: avgHr == null && nullToAbsent ? const Value.absent() : Value(avgHr),
      maxHr: maxHr == null && nullToAbsent ? const Value.absent() : Value(maxHr),
      activeKcal: activeKcal == null && nullToAbsent ? const Value.absent() : Value(activeKcal),
      source: source == null && nullToAbsent ? const Value.absent() : Value(source),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory SessionHealthData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionHealthData(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      avgHr: serializer.fromJson<int?>(json['avgHr']),
      maxHr: serializer.fromJson<int?>(json['maxHr']),
      activeKcal: serializer.fromJson<int?>(json['activeKcal']),
      source: serializer.fromJson<String?>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'avgHr': serializer.toJson<int?>(avgHr),
      'maxHr': serializer.toJson<int?>(maxHr),
      'activeKcal': serializer.toJson<int?>(activeKcal),
      'source': serializer.toJson<String?>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  SessionHealthData copyWith({
    int? sessionId,
    DateTime? startAt,
    DateTime? endAt,
    Value<int?> avgHr = const Value.absent(),
    Value<int?> maxHr = const Value.absent(),
    Value<int?> activeKcal = const Value.absent(),
    Value<String?> source = const Value.absent(),
    DateTime? fetchedAt,
  }) => SessionHealthData(
    sessionId: sessionId ?? this.sessionId,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    avgHr: avgHr.present ? avgHr.value : this.avgHr,
    maxHr: maxHr.present ? maxHr.value : this.maxHr,
    activeKcal: activeKcal.present ? activeKcal.value : this.activeKcal,
    source: source.present ? source.value : this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  SessionHealthData copyWithCompanion(SessionHealthCompanion data) {
    return SessionHealthData(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      avgHr: data.avgHr.present ? data.avgHr.value : this.avgHr,
      maxHr: data.maxHr.present ? data.maxHr.value : this.maxHr,
      activeKcal: data.activeKcal.present ? data.activeKcal.value : this.activeKcal,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionHealthData(')
          ..write('sessionId: $sessionId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('avgHr: $avgHr, ')
          ..write('maxHr: $maxHr, ')
          ..write('activeKcal: $activeKcal, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, startAt, endAt, avgHr, maxHr, activeKcal, source, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionHealthData &&
          other.sessionId == this.sessionId &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.avgHr == this.avgHr &&
          other.maxHr == this.maxHr &&
          other.activeKcal == this.activeKcal &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt);
}

class SessionHealthCompanion extends UpdateCompanion<SessionHealthData> {
  final Value<int> sessionId;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<int?> avgHr;
  final Value<int?> maxHr;
  final Value<int?> activeKcal;
  final Value<String?> source;
  final Value<DateTime> fetchedAt;
  const SessionHealthCompanion({
    this.sessionId = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.avgHr = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.activeKcal = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  SessionHealthCompanion.insert({
    this.sessionId = const Value.absent(),
    required DateTime startAt,
    required DateTime endAt,
    this.avgHr = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.activeKcal = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  }) : startAt = Value(startAt),
       endAt = Value(endAt);
  static Insertable<SessionHealthData> custom({
    Expression<int>? sessionId,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<int>? avgHr,
    Expression<int>? maxHr,
    Expression<int>? activeKcal,
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (avgHr != null) 'avg_hr': avgHr,
      if (maxHr != null) 'max_hr': maxHr,
      if (activeKcal != null) 'active_kcal': activeKcal,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  SessionHealthCompanion copyWith({
    Value<int>? sessionId,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<int?>? avgHr,
    Value<int?>? maxHr,
    Value<int?>? activeKcal,
    Value<String?>? source,
    Value<DateTime>? fetchedAt,
  }) {
    return SessionHealthCompanion(
      sessionId: sessionId ?? this.sessionId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      avgHr: avgHr ?? this.avgHr,
      maxHr: maxHr ?? this.maxHr,
      activeKcal: activeKcal ?? this.activeKcal,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (avgHr.present) {
      map['avg_hr'] = Variable<int>(avgHr.value);
    }
    if (maxHr.present) {
      map['max_hr'] = Variable<int>(maxHr.value);
    }
    if (activeKcal.present) {
      map['active_kcal'] = Variable<int>(activeKcal.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionHealthCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('avgHr: $avgHr, ')
          ..write('maxHr: $maxHr, ')
          ..write('activeKcal: $activeKcal, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $DailyHealthTable extends DailyHealth with TableInfo<$DailyHealthTable, DailyHealthData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyHealthTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<int> dayKey = GeneratedColumn<int>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepMinMeta = const VerificationMeta('sleepMin');
  @override
  late final GeneratedColumn<int> sleepMin = GeneratedColumn<int>(
    'sleep_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [dayKey, steps, sleepMin, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_health';
  @override
  VerificationContext validateIntegrity(Insertable<DailyHealthData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta, dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    }
    if (data.containsKey('steps')) {
      context.handle(_stepsMeta, steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta));
    }
    if (data.containsKey('sleep_min')) {
      context.handle(_sleepMinMeta, sleepMin.isAcceptableOrUnknown(data['sleep_min']!, _sleepMinMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta, fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayKey};
  @override
  DailyHealthData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyHealthData(
      dayKey: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day_key'])!,
      steps: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}steps']),
      sleepMin: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sleep_min']),
      fetchedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $DailyHealthTable createAlias(String alias) {
    return $DailyHealthTable(attachedDatabase, alias);
  }
}

class DailyHealthData extends DataClass implements Insertable<DailyHealthData> {
  final int dayKey;
  final int? steps;
  final int? sleepMin;
  final DateTime fetchedAt;
  const DailyHealthData({required this.dayKey, this.steps, this.sleepMin, required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_key'] = Variable<int>(dayKey);
    if (!nullToAbsent || steps != null) {
      map['steps'] = Variable<int>(steps);
    }
    if (!nullToAbsent || sleepMin != null) {
      map['sleep_min'] = Variable<int>(sleepMin);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  DailyHealthCompanion toCompanion(bool nullToAbsent) {
    return DailyHealthCompanion(
      dayKey: Value(dayKey),
      steps: steps == null && nullToAbsent ? const Value.absent() : Value(steps),
      sleepMin: sleepMin == null && nullToAbsent ? const Value.absent() : Value(sleepMin),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory DailyHealthData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyHealthData(
      dayKey: serializer.fromJson<int>(json['dayKey']),
      steps: serializer.fromJson<int?>(json['steps']),
      sleepMin: serializer.fromJson<int?>(json['sleepMin']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayKey': serializer.toJson<int>(dayKey),
      'steps': serializer.toJson<int?>(steps),
      'sleepMin': serializer.toJson<int?>(sleepMin),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  DailyHealthData copyWith({
    int? dayKey,
    Value<int?> steps = const Value.absent(),
    Value<int?> sleepMin = const Value.absent(),
    DateTime? fetchedAt,
  }) => DailyHealthData(
    dayKey: dayKey ?? this.dayKey,
    steps: steps.present ? steps.value : this.steps,
    sleepMin: sleepMin.present ? sleepMin.value : this.sleepMin,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  DailyHealthData copyWithCompanion(DailyHealthCompanion data) {
    return DailyHealthData(
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      steps: data.steps.present ? data.steps.value : this.steps,
      sleepMin: data.sleepMin.present ? data.sleepMin.value : this.sleepMin,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthData(')
          ..write('dayKey: $dayKey, ')
          ..write('steps: $steps, ')
          ..write('sleepMin: $sleepMin, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayKey, steps, sleepMin, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyHealthData &&
          other.dayKey == this.dayKey &&
          other.steps == this.steps &&
          other.sleepMin == this.sleepMin &&
          other.fetchedAt == this.fetchedAt);
}

class DailyHealthCompanion extends UpdateCompanion<DailyHealthData> {
  final Value<int> dayKey;
  final Value<int?> steps;
  final Value<int?> sleepMin;
  final Value<DateTime> fetchedAt;
  const DailyHealthCompanion({
    this.dayKey = const Value.absent(),
    this.steps = const Value.absent(),
    this.sleepMin = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  DailyHealthCompanion.insert({
    this.dayKey = const Value.absent(),
    this.steps = const Value.absent(),
    this.sleepMin = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  static Insertable<DailyHealthData> custom({
    Expression<int>? dayKey,
    Expression<int>? steps,
    Expression<int>? sleepMin,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (dayKey != null) 'day_key': dayKey,
      if (steps != null) 'steps': steps,
      if (sleepMin != null) 'sleep_min': sleepMin,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  DailyHealthCompanion copyWith({
    Value<int>? dayKey,
    Value<int?>? steps,
    Value<int?>? sleepMin,
    Value<DateTime>? fetchedAt,
  }) {
    return DailyHealthCompanion(
      dayKey: dayKey ?? this.dayKey,
      steps: steps ?? this.steps,
      sleepMin: sleepMin ?? this.sleepMin,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayKey.present) {
      map['day_key'] = Variable<int>(dayKey.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (sleepMin.present) {
      map['sleep_min'] = Variable<int>(sleepMin.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthCompanion(')
          ..write('dayKey: $dayKey, ')
          ..write('steps: $steps, ')
          ..write('sleepMin: $sleepMin, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $MuscleGroupsTable muscleGroups = $MuscleGroupsTable(this);
  late final $SessionGroupsTable sessionGroups = $SessionGroupsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $SessionExercisesTable sessionExercises = $SessionExercisesTable(this);
  late final $ExerciseSetsTable exerciseSets = $ExerciseSetsTable(this);
  late final $BodyWeightsTable bodyWeights = $BodyWeightsTable(this);
  late final $ProgressPhotosTable progressPhotos = $ProgressPhotosTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $ProgramDaysTable programDays = $ProgramDaysTable(this);
  late final $ProgramDayGroupsTable programDayGroups = $ProgramDayGroupsTable(this);
  late final $ProgramDayExercisesTable programDayExercises = $ProgramDayExercisesTable(this);
  late final $SessionHealthTable sessionHealth = $SessionHealthTable(this);
  late final $DailyHealthTable dailyHealth = $DailyHealthTable(this);
  late final Index idxSessionGroupsGroup = Index(
    'idx_session_groups_group',
    'CREATE INDEX idx_session_groups_group ON session_groups (group_id)',
  );
  late final Index idxSessionExercisesSession = Index(
    'idx_session_exercises_session',
    'CREATE INDEX idx_session_exercises_session ON session_exercises (session_id)',
  );
  late final Index idxSessionExercisesExercise = Index(
    'idx_session_exercises_exercise',
    'CREATE INDEX idx_session_exercises_exercise ON session_exercises (exercise_id)',
  );
  late final Index idxExerciseSetsEntry = Index(
    'idx_exercise_sets_entry',
    'CREATE INDEX idx_exercise_sets_entry ON exercise_sets (session_exercise_id)',
  );
  late final Index idxProgressPhotosDay = Index(
    'idx_progress_photos_day',
    'CREATE INDEX idx_progress_photos_day ON progress_photos (day_key)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    muscleGroups,
    sessionGroups,
    exercises,
    sessionExercises,
    exerciseSets,
    bodyWeights,
    progressPhotos,
    goals,
    programDays,
    programDayGroups,
    programDayExercises,
    sessionHealth,
    dailyHealth,
    idxSessionGroupsGroup,
    idxSessionExercisesSession,
    idxSessionExercisesExercise,
    idxExerciseSetsEntry,
    idxProgressPhotosDay,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('sessions', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('session_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('muscle_groups', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('session_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('muscle_groups', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('exercises', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('sessions', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('session_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('exercises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('session_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('session_exercises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('exercise_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('exercises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('goals', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('program_days', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('program_day_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('muscle_groups', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('program_day_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('program_days', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('program_day_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('exercises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('program_day_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('sessions', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('session_health', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required int dayKey,
      Value<String?> note,
      Value<int?> durationMin,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> startedAt,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<int> dayKey,
      Value<String?> note,
      Value<int?> durationMin,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> startedAt,
    });

final class $$SessionsTableReferences extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionGroupsTable, List<SessionGroup>> _sessionGroupsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionGroups,
        aliasName: $_aliasNameGenerator(db.sessions.id, db.sessionGroups.sessionId),
      );

  $$SessionGroupsTableProcessedTableManager get sessionGroupsRefs {
    final manager = $$SessionGroupsTableTableManager(
      $_db,
      $_db.sessionGroups,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionGroupsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExercise>> _sessionExercisesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessionExercises,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.sessionExercises.sessionId),
  );

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SessionHealthTable, List<SessionHealthData>> _sessionHealthRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionHealth,
        aliasName: $_aliasNameGenerator(db.sessions.id, db.sessionHealth.sessionId),
      );

  $$SessionHealthTableProcessedTableManager get sessionHealthRefs {
    final manager = $$SessionHealthTableTableManager(
      $_db,
      $_db.sessionHealth,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionHealthRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionsTableFilterComposer extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMin =>
      $composableBuilder(column: $table.durationMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> sessionGroupsRefs(Expression<bool> Function($$SessionGroupsTableFilterComposer f) f) {
    final $$SessionGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionGroups,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionGroupsTableFilterComposer(
            $db: $db,
            $table: $db.sessionGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionExercisesRefs(Expression<bool> Function($$SessionExercisesTableFilterComposer f) f) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionHealthRefs(Expression<bool> Function($$SessionHealthTableFilterComposer f) f) {
    final $$SessionHealthTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionHealth,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionHealthTableFilterComposer(
            $db: $db,
            $table: $db.sessionHealth,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMin =>
      $composableBuilder(column: $table.durationMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayKey => $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(column: $table.durationMin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt => $composableBuilder(column: $table.startedAt, builder: (column) => column);

  Expression<T> sessionGroupsRefs<T extends Object>(
    Expression<T> Function($$SessionGroupsTableAnnotationComposer a) f,
  ) {
    final $$SessionGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionGroups,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionExercisesRefs<T extends Object>(
    Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f,
  ) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionHealthRefs<T extends Object>(
    Expression<T> Function($$SessionHealthTableAnnotationComposer a) f,
  ) {
    final $$SessionHealthTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionHealth,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionHealthTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionHealth,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool sessionGroupsRefs, bool sessionExercisesRefs, bool sessionHealthRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayKey = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                dayKey: dayKey,
                note: note,
                durationMin: durationMin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                startedAt: startedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayKey,
                Value<String?> note = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                dayKey: dayKey,
                note: note,
                durationMin: durationMin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                startedAt: startedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$SessionsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback:
              ({sessionGroupsRefs = false, sessionExercisesRefs = false, sessionHealthRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionGroupsRefs) db.sessionGroups,
                    if (sessionExercisesRefs) db.sessionExercises,
                    if (sessionHealthRefs) db.sessionHealth,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionGroupsRefs)
                        await $_getPrefetchedData<Session, $SessionsTable, SessionGroup>(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences._sessionGroupsRefsTable(db),
                          managerFromTypedResult: (p0) => $$SessionsTableReferences(db, table, p0).sessionGroupsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.sessionId == item.id),
                          typedResults: items,
                        ),
                      if (sessionExercisesRefs)
                        await $_getPrefetchedData<Session, $SessionsTable, SessionExercise>(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences._sessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) => $$SessionsTableReferences(db, table, p0).sessionExercisesRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.sessionId == item.id),
                          typedResults: items,
                        ),
                      if (sessionHealthRefs)
                        await $_getPrefetchedData<Session, $SessionsTable, SessionHealthData>(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences._sessionHealthRefsTable(db),
                          managerFromTypedResult: (p0) => $$SessionsTableReferences(db, table, p0).sessionHealthRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.sessionId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool sessionGroupsRefs, bool sessionExercisesRefs, bool sessionHealthRefs})
    >;
typedef $$MuscleGroupsTableCreateCompanionBuilder =
    MuscleGroupsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> slug,
      Value<int> sortOrder,
      Value<bool> hidden,
      Value<bool> isCustom,
    });
typedef $$MuscleGroupsTableUpdateCompanionBuilder =
    MuscleGroupsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> slug,
      Value<int> sortOrder,
      Value<bool> hidden,
      Value<bool> isCustom,
    });

final class $$MuscleGroupsTableReferences extends BaseReferences<_$AppDatabase, $MuscleGroupsTable, MuscleGroup> {
  $$MuscleGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionGroupsTable, List<SessionGroup>> _sessionGroupsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionGroups,
        aliasName: $_aliasNameGenerator(db.muscleGroups.id, db.sessionGroups.groupId),
      );

  $$SessionGroupsTableProcessedTableManager get sessionGroupsRefs {
    final manager = $$SessionGroupsTableTableManager(
      $_db,
      $_db.sessionGroups,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionGroupsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>> _exercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exercises,
        aliasName: $_aliasNameGenerator(db.muscleGroups.id, db.exercises.groupId),
      );

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProgramDayGroupsTable, List<ProgramDayGroup>> _programDayGroupsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.programDayGroups,
    aliasName: $_aliasNameGenerator(db.muscleGroups.id, db.programDayGroups.groupId),
  );

  $$ProgramDayGroupsTableProcessedTableManager get programDayGroupsRefs {
    final manager = $$ProgramDayGroupsTableTableManager(
      $_db,
      $_db.programDayGroups,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_programDayGroupsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MuscleGroupsTableFilterComposer extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug => $composableBuilder(column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => ColumnFilters(column));

  Expression<bool> sessionGroupsRefs(Expression<bool> Function($$SessionGroupsTableFilterComposer f) f) {
    final $$SessionGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionGroups,
      getReferencedColumn: (t) => t.groupId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionGroupsTableFilterComposer(
            $db: $db,
            $table: $db.sessionGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exercisesRefs(Expression<bool> Function($$ExercisesTableFilterComposer f) f) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.groupId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> programDayGroupsRefs(Expression<bool> Function($$ProgramDayGroupsTableFilterComposer f) f) {
    final $$ProgramDayGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programDayGroups,
      getReferencedColumn: (t) => t.groupId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDayGroupsTableFilterComposer(
            $db: $db,
            $table: $db.programDayGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MuscleGroupsTableOrderingComposer extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => ColumnOrderings(column));
}

class $$MuscleGroupsTableAnnotationComposer extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get slug => $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<int> get sortOrder => $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get hidden => $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<bool> get isCustom => $composableBuilder(column: $table.isCustom, builder: (column) => column);

  Expression<T> sessionGroupsRefs<T extends Object>(
    Expression<T> Function($$SessionGroupsTableAnnotationComposer a) f,
  ) {
    final $$SessionGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionGroups,
      getReferencedColumn: (t) => t.groupId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exercisesRefs<T extends Object>(Expression<T> Function($$ExercisesTableAnnotationComposer a) f) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.groupId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> programDayGroupsRefs<T extends Object>(
    Expression<T> Function($$ProgramDayGroupsTableAnnotationComposer a) f,
  ) {
    final $$ProgramDayGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programDayGroups,
      getReferencedColumn: (t) => t.groupId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDayGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.programDayGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MuscleGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MuscleGroupsTable,
          MuscleGroup,
          $$MuscleGroupsTableFilterComposer,
          $$MuscleGroupsTableOrderingComposer,
          $$MuscleGroupsTableAnnotationComposer,
          $$MuscleGroupsTableCreateCompanionBuilder,
          $$MuscleGroupsTableUpdateCompanionBuilder,
          (MuscleGroup, $$MuscleGroupsTableReferences),
          MuscleGroup,
          PrefetchHooks Function({bool sessionGroupsRefs, bool exercisesRefs, bool programDayGroupsRefs})
        > {
  $$MuscleGroupsTableTableManager(_$AppDatabase db, $MuscleGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MuscleGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MuscleGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MuscleGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> slug = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => MuscleGroupsCompanion(
                id: id,
                name: name,
                slug: slug,
                sortOrder: sortOrder,
                hidden: hidden,
                isCustom: isCustom,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> slug = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => MuscleGroupsCompanion.insert(
                id: id,
                name: name,
                slug: slug,
                sortOrder: sortOrder,
                hidden: hidden,
                isCustom: isCustom,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$MuscleGroupsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({sessionGroupsRefs = false, exercisesRefs = false, programDayGroupsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionGroupsRefs) db.sessionGroups,
                if (exercisesRefs) db.exercises,
                if (programDayGroupsRefs) db.programDayGroups,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionGroupsRefs)
                    await $_getPrefetchedData<MuscleGroup, $MuscleGroupsTable, SessionGroup>(
                      currentTable: table,
                      referencedTable: $$MuscleGroupsTableReferences._sessionGroupsRefsTable(db),
                      managerFromTypedResult: (p0) => $$MuscleGroupsTableReferences(db, table, p0).sessionGroupsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupId == item.id),
                      typedResults: items,
                    ),
                  if (exercisesRefs)
                    await $_getPrefetchedData<MuscleGroup, $MuscleGroupsTable, Exercise>(
                      currentTable: table,
                      referencedTable: $$MuscleGroupsTableReferences._exercisesRefsTable(db),
                      managerFromTypedResult: (p0) => $$MuscleGroupsTableReferences(db, table, p0).exercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupId == item.id),
                      typedResults: items,
                    ),
                  if (programDayGroupsRefs)
                    await $_getPrefetchedData<MuscleGroup, $MuscleGroupsTable, ProgramDayGroup>(
                      currentTable: table,
                      referencedTable: $$MuscleGroupsTableReferences._programDayGroupsRefsTable(db),
                      managerFromTypedResult: (p0) => $$MuscleGroupsTableReferences(db, table, p0).programDayGroupsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MuscleGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MuscleGroupsTable,
      MuscleGroup,
      $$MuscleGroupsTableFilterComposer,
      $$MuscleGroupsTableOrderingComposer,
      $$MuscleGroupsTableAnnotationComposer,
      $$MuscleGroupsTableCreateCompanionBuilder,
      $$MuscleGroupsTableUpdateCompanionBuilder,
      (MuscleGroup, $$MuscleGroupsTableReferences),
      MuscleGroup,
      PrefetchHooks Function({bool sessionGroupsRefs, bool exercisesRefs, bool programDayGroupsRefs})
    >;
typedef $$SessionGroupsTableCreateCompanionBuilder =
    SessionGroupsCompanion Function({required int sessionId, required int groupId, Value<int> rowid});
typedef $$SessionGroupsTableUpdateCompanionBuilder =
    SessionGroupsCompanion Function({Value<int> sessionId, Value<int> groupId, Value<int> rowid});

final class $$SessionGroupsTableReferences extends BaseReferences<_$AppDatabase, $SessionGroupsTable, SessionGroup> {
  $$SessionGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias($_aliasNameGenerator(db.sessionGroups.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MuscleGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.muscleGroups.createAlias($_aliasNameGenerator(db.sessionGroups.groupId, db.muscleGroups.id));

  $$MuscleGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$MuscleGroupsTableTableManager($_db, $_db.muscleGroups).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SessionGroupsTableFilterComposer extends Composer<_$AppDatabase, $SessionGroupsTable> {
  $$SessionGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableFilterComposer get groupId {
    final $$MuscleGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MuscleGroupsTableFilterComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionGroupsTableOrderingComposer extends Composer<_$AppDatabase, $SessionGroupsTable> {
  $$SessionGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableOrderingComposer get groupId {
    final $$MuscleGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MuscleGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionGroupsTableAnnotationComposer extends Composer<_$AppDatabase, $SessionGroupsTable> {
  $$SessionGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableAnnotationComposer get groupId {
    final $$MuscleGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MuscleGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionGroupsTable,
          SessionGroup,
          $$SessionGroupsTableFilterComposer,
          $$SessionGroupsTableOrderingComposer,
          $$SessionGroupsTableAnnotationComposer,
          $$SessionGroupsTableCreateCompanionBuilder,
          $$SessionGroupsTableUpdateCompanionBuilder,
          (SessionGroup, $$SessionGroupsTableReferences),
          SessionGroup,
          PrefetchHooks Function({bool sessionId, bool groupId})
        > {
  $$SessionGroupsTableTableManager(_$AppDatabase db, $SessionGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sessionId = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionGroupsCompanion(sessionId: sessionId, groupId: groupId, rowid: rowid),
          createCompanionCallback:
              ({required int sessionId, required int groupId, Value<int> rowid = const Value.absent()}) =>
                  SessionGroupsCompanion.insert(sessionId: sessionId, groupId: groupId, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$SessionGroupsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({sessionId = false, groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SessionGroupsTableReferences._sessionIdTable(db),
                                referencedColumn: $$SessionGroupsTableReferences._sessionIdTable(db).id,
                              )
                              as T;
                    }
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable: $$SessionGroupsTableReferences._groupIdTable(db),
                                referencedColumn: $$SessionGroupsTableReferences._groupIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionGroupsTable,
      SessionGroup,
      $$SessionGroupsTableFilterComposer,
      $$SessionGroupsTableOrderingComposer,
      $$SessionGroupsTableAnnotationComposer,
      $$SessionGroupsTableCreateCompanionBuilder,
      $$SessionGroupsTableUpdateCompanionBuilder,
      (SessionGroup, $$SessionGroupsTableReferences),
      SessionGroup,
      PrefetchHooks Function({bool sessionId, bool groupId})
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> groupId,
      required ExerciseKind kind,
      Value<bool> hidden,
      Value<bool> isCustom,
      Value<String?> guideId,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> groupId,
      Value<ExerciseKind> kind,
      Value<bool> hidden,
      Value<bool> isCustom,
      Value<String?> guideId,
    });

final class $$ExercisesTableReferences extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MuscleGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.muscleGroups.createAlias($_aliasNameGenerator(db.exercises.groupId, db.muscleGroups.id));

  $$MuscleGroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<int>('group_id');
    if ($_column == null) return null;
    final manager = $$MuscleGroupsTableTableManager($_db, $_db.muscleGroups).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExercise>> _sessionExercisesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessionExercises,
    aliasName: $_aliasNameGenerator(db.exercises.id, db.sessionExercises.exerciseId),
  );

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GoalsTable, List<Goal>> _goalsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.goals, aliasName: $_aliasNameGenerator(db.exercises.id, db.goals.exerciseId));

  $$GoalsTableProcessedTableManager get goalsRefs {
    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProgramDayExercisesTable, List<ProgramDayExercise>> _programDayExercisesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.programDayExercises,
    aliasName: $_aliasNameGenerator(db.exercises.id, db.programDayExercises.exerciseId),
  );

  $$ProgramDayExercisesTableProcessedTableManager get programDayExercisesRefs {
    final manager = $$ProgramDayExercisesTableTableManager(
      $_db,
      $_db.programDayExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_programDayExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExercisesTableFilterComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ExerciseKind, ExerciseKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guideId =>
      $composableBuilder(column: $table.guideId, builder: (column) => ColumnFilters(column));

  $$MuscleGroupsTableFilterComposer get groupId {
    final $$MuscleGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MuscleGroupsTableFilterComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionExercisesRefs(Expression<bool> Function($$SessionExercisesTableFilterComposer f) f) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalsRefs(Expression<bool> Function($$GoalsTableFilterComposer f) f) {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> programDayExercisesRefs(Expression<bool> Function($$ProgramDayExercisesTableFilterComposer f) f) {
    final $$ProgramDayExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programDayExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDayExercisesTableFilterComposer(
            $db: $db,
            $table: $db.programDayExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guideId =>
      $composableBuilder(column: $table.guideId, builder: (column) => ColumnOrderings(column));

  $$MuscleGroupsTableOrderingComposer get groupId {
    final $$MuscleGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MuscleGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableAnnotationComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExerciseKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get hidden => $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<bool> get isCustom => $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get guideId => $composableBuilder(column: $table.guideId, builder: (column) => column);

  $$MuscleGroupsTableAnnotationComposer get groupId {
    final $$MuscleGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MuscleGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionExercisesRefs<T extends Object>(
    Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f,
  ) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalsRefs<T extends Object>(Expression<T> Function($$GoalsTableAnnotationComposer a) f) {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> programDayExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramDayExercisesTableAnnotationComposer a) f,
  ) {
    final $$ProgramDayExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programDayExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDayExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.programDayExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool groupId,
            bool sessionExercisesRefs,
            bool goalsRefs,
            bool programDayExercisesRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> groupId = const Value.absent(),
                Value<ExerciseKind> kind = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> guideId = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                groupId: groupId,
                kind: kind,
                hidden: hidden,
                isCustom: isCustom,
                guideId: guideId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> groupId = const Value.absent(),
                required ExerciseKind kind,
                Value<bool> hidden = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> guideId = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                groupId: groupId,
                kind: kind,
                hidden: hidden,
                isCustom: isCustom,
                guideId: guideId,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$ExercisesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback:
              ({groupId = false, sessionExercisesRefs = false, goalsRefs = false, programDayExercisesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionExercisesRefs) db.sessionExercises,
                    if (goalsRefs) db.goals,
                    if (programDayExercisesRefs) db.programDayExercises,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.groupId,
                                    referencedTable: $$ExercisesTableReferences._groupIdTable(db),
                                    referencedColumn: $$ExercisesTableReferences._groupIdTable(db).id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionExercisesRefs)
                        await $_getPrefetchedData<Exercise, $ExercisesTable, SessionExercise>(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences._sessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(db, table, p0).sessionExercisesRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.exerciseId == item.id),
                          typedResults: items,
                        ),
                      if (goalsRefs)
                        await $_getPrefetchedData<Exercise, $ExercisesTable, Goal>(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences._goalsRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExercisesTableReferences(db, table, p0).goalsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.exerciseId == item.id),
                          typedResults: items,
                        ),
                      if (programDayExercisesRefs)
                        await $_getPrefetchedData<Exercise, $ExercisesTable, ProgramDayExercise>(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences._programDayExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(db, table, p0).programDayExercisesRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.exerciseId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({bool groupId, bool sessionExercisesRefs, bool goalsRefs, bool programDayExercisesRefs})
    >;
typedef $$SessionExercisesTableCreateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<int> id,
      required int sessionId,
      required int exerciseId,
      required int position,
      Value<String?> note,
    });
typedef $$SessionExercisesTableUpdateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> exerciseId,
      Value<int> position,
      Value<String?> note,
    });

final class $$SessionExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $SessionExercisesTable, SessionExercise> {
  $$SessionExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias($_aliasNameGenerator(db.sessionExercises.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias($_aliasNameGenerator(db.sessionExercises.exerciseId, db.exercises.id));

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ExerciseSetsTable, List<ExerciseSet>> _exerciseSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseSets,
        aliasName: $_aliasNameGenerator(db.sessionExercises.id, db.exerciseSets.sessionExerciseId),
      );

  $$ExerciseSetsTableProcessedTableManager get exerciseSetsRefs {
    final manager = $$ExerciseSetsTableTableManager(
      $_db,
      $_db.exerciseSets,
    ).filter((f) => f.sessionExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseSetsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionExercisesTableFilterComposer extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseSetsRefs(Expression<bool> Function($$ExerciseSetsTableFilterComposer f) f) {
    final $$ExerciseSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExerciseSetsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionExercisesTableOrderingComposer extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableAnnotationComposer extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position => $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseSetsRefs<T extends Object>(Expression<T> Function($$ExerciseSetsTableAnnotationComposer a) f) {
    final $$ExerciseSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExerciseSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionExercisesTable,
          SessionExercise,
          $$SessionExercisesTableFilterComposer,
          $$SessionExercisesTableOrderingComposer,
          $$SessionExercisesTableAnnotationComposer,
          $$SessionExercisesTableCreateCompanionBuilder,
          $$SessionExercisesTableUpdateCompanionBuilder,
          (SessionExercise, $$SessionExercisesTableReferences),
          SessionExercise,
          PrefetchHooks Function({bool sessionId, bool exerciseId, bool exerciseSetsRefs})
        > {
  $$SessionExercisesTableTableManager(_$AppDatabase db, $SessionExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => SessionExercisesCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int exerciseId,
                required int position,
                Value<String?> note = const Value.absent(),
              }) => SessionExercisesCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                note: note,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$SessionExercisesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({sessionId = false, exerciseId = false, exerciseSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (exerciseSetsRefs) db.exerciseSets],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SessionExercisesTableReferences._sessionIdTable(db),
                                referencedColumn: $$SessionExercisesTableReferences._sessionIdTable(db).id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$SessionExercisesTableReferences._exerciseIdTable(db),
                                referencedColumn: $$SessionExercisesTableReferences._exerciseIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseSetsRefs)
                    await $_getPrefetchedData<SessionExercise, $SessionExercisesTable, ExerciseSet>(
                      currentTable: table,
                      referencedTable: $$SessionExercisesTableReferences._exerciseSetsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SessionExercisesTableReferences(db, table, p0).exerciseSetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionExerciseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionExercisesTable,
      SessionExercise,
      $$SessionExercisesTableFilterComposer,
      $$SessionExercisesTableOrderingComposer,
      $$SessionExercisesTableAnnotationComposer,
      $$SessionExercisesTableCreateCompanionBuilder,
      $$SessionExercisesTableUpdateCompanionBuilder,
      (SessionExercise, $$SessionExercisesTableReferences),
      SessionExercise,
      PrefetchHooks Function({bool sessionId, bool exerciseId, bool exerciseSetsRefs})
    >;
typedef $$ExerciseSetsTableCreateCompanionBuilder =
    ExerciseSetsCompanion Function({
      Value<int> id,
      required int sessionExerciseId,
      required int position,
      Value<double?> weightKg,
      Value<int?> reps,
      Value<int?> durationSec,
      Value<double?> distanceKm,
    });
typedef $$ExerciseSetsTableUpdateCompanionBuilder =
    ExerciseSetsCompanion Function({
      Value<int> id,
      Value<int> sessionExerciseId,
      Value<int> position,
      Value<double?> weightKg,
      Value<int?> reps,
      Value<int?> durationSec,
      Value<double?> distanceKm,
    });

final class $$ExerciseSetsTableReferences extends BaseReferences<_$AppDatabase, $ExerciseSetsTable, ExerciseSet> {
  $$ExerciseSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionExercisesTable _sessionExerciseIdTable(_$AppDatabase db) =>
      db.sessionExercises.createAlias($_aliasNameGenerator(db.exerciseSets.sessionExerciseId, db.sessionExercises.id));

  $$SessionExercisesTableProcessedTableManager get sessionExerciseId {
    final $_column = $_itemColumn<int>('session_exercise_id')!;

    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExerciseSetsTableFilterComposer extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSec =>
      $composableBuilder(column: $table.durationSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distanceKm =>
      $composableBuilder(column: $table.distanceKm, builder: (column) => ColumnFilters(column));

  $$SessionExercisesTableFilterComposer get sessionExerciseId {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableOrderingComposer extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSec =>
      $composableBuilder(column: $table.durationSec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distanceKm =>
      $composableBuilder(column: $table.distanceKm, builder: (column) => ColumnOrderings(column));

  $$SessionExercisesTableOrderingComposer get sessionExerciseId {
    final $$SessionExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableAnnotationComposer extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position => $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<double> get weightKg => $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps => $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(column: $table.durationSec, builder: (column) => column);

  GeneratedColumn<double> get distanceKm => $composableBuilder(column: $table.distanceKm, builder: (column) => column);

  $$SessionExercisesTableAnnotationComposer get sessionExerciseId {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseSetsTable,
          ExerciseSet,
          $$ExerciseSetsTableFilterComposer,
          $$ExerciseSetsTableOrderingComposer,
          $$ExerciseSetsTableAnnotationComposer,
          $$ExerciseSetsTableCreateCompanionBuilder,
          $$ExerciseSetsTableUpdateCompanionBuilder,
          (ExerciseSet, $$ExerciseSetsTableReferences),
          ExerciseSet,
          PrefetchHooks Function({bool sessionExerciseId})
        > {
  $$ExerciseSetsTableTableManager(_$AppDatabase db, $ExerciseSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExerciseSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExerciseSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExerciseSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionExerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
              }) => ExerciseSetsCompanion(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                weightKg: weightKg,
                reps: reps,
                durationSec: durationSec,
                distanceKm: distanceKm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionExerciseId,
                required int position,
                Value<double?> weightKg = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
              }) => ExerciseSetsCompanion.insert(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                weightKg: weightKg,
                reps: reps,
                durationSec: durationSec,
                distanceKm: distanceKm,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$ExerciseSetsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({sessionExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionExerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionExerciseId,
                                referencedTable: $$ExerciseSetsTableReferences._sessionExerciseIdTable(db),
                                referencedColumn: $$ExerciseSetsTableReferences._sessionExerciseIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseSetsTable,
      ExerciseSet,
      $$ExerciseSetsTableFilterComposer,
      $$ExerciseSetsTableOrderingComposer,
      $$ExerciseSetsTableAnnotationComposer,
      $$ExerciseSetsTableCreateCompanionBuilder,
      $$ExerciseSetsTableUpdateCompanionBuilder,
      (ExerciseSet, $$ExerciseSetsTableReferences),
      ExerciseSet,
      PrefetchHooks Function({bool sessionExerciseId})
    >;
typedef $$BodyWeightsTableCreateCompanionBuilder =
    BodyWeightsCompanion Function({
      Value<int> dayKey,
      required double weightKg,
      Value<DateTime> recordedAt,
      Value<String?> source,
    });
typedef $$BodyWeightsTableUpdateCompanionBuilder =
    BodyWeightsCompanion Function({
      Value<int> dayKey,
      Value<double> weightKg,
      Value<DateTime> recordedAt,
      Value<String?> source,
    });

class $$BodyWeightsTableFilterComposer extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt =>
      $composableBuilder(column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$BodyWeightsTableOrderingComposer extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt =>
      $composableBuilder(column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$BodyWeightsTableAnnotationComposer extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dayKey => $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<double> get weightKg => $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt =>
      $composableBuilder(column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<String> get source => $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$BodyWeightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyWeightsTable,
          BodyWeight,
          $$BodyWeightsTableFilterComposer,
          $$BodyWeightsTableOrderingComposer,
          $$BodyWeightsTableAnnotationComposer,
          $$BodyWeightsTableCreateCompanionBuilder,
          $$BodyWeightsTableUpdateCompanionBuilder,
          (BodyWeight, BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>),
          BodyWeight,
          PrefetchHooks Function()
        > {
  $$BodyWeightsTableTableManager(_$AppDatabase db, $BodyWeightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$BodyWeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$BodyWeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$BodyWeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> dayKey = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String?> source = const Value.absent(),
              }) => BodyWeightsCompanion(dayKey: dayKey, weightKg: weightKg, recordedAt: recordedAt, source: source),
          createCompanionCallback:
              ({
                Value<int> dayKey = const Value.absent(),
                required double weightKg,
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String?> source = const Value.absent(),
              }) => BodyWeightsCompanion.insert(
                dayKey: dayKey,
                weightKg: weightKg,
                recordedAt: recordedAt,
                source: source,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyWeightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyWeightsTable,
      BodyWeight,
      $$BodyWeightsTableFilterComposer,
      $$BodyWeightsTableOrderingComposer,
      $$BodyWeightsTableAnnotationComposer,
      $$BodyWeightsTableCreateCompanionBuilder,
      $$BodyWeightsTableUpdateCompanionBuilder,
      (BodyWeight, BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>),
      BodyWeight,
      PrefetchHooks Function()
    >;
typedef $$ProgressPhotosTableCreateCompanionBuilder =
    ProgressPhotosCompanion Function({
      Value<int> id,
      required int dayKey,
      required String fileName,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$ProgressPhotosTableUpdateCompanionBuilder =
    ProgressPhotosCompanion Function({
      Value<int> id,
      Value<int> dayKey,
      Value<String> fileName,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

class $$ProgressPhotosTableFilterComposer extends Composer<_$AppDatabase, $ProgressPhotosTable> {
  $$ProgressPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ProgressPhotosTableOrderingComposer extends Composer<_$AppDatabase, $ProgressPhotosTable> {
  $$ProgressPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ProgressPhotosTableAnnotationComposer extends Composer<_$AppDatabase, $ProgressPhotosTable> {
  $$ProgressPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayKey => $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<String> get fileName => $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProgressPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressPhotosTable,
          ProgressPhoto,
          $$ProgressPhotosTableFilterComposer,
          $$ProgressPhotosTableOrderingComposer,
          $$ProgressPhotosTableAnnotationComposer,
          $$ProgressPhotosTableCreateCompanionBuilder,
          $$ProgressPhotosTableUpdateCompanionBuilder,
          (ProgressPhoto, BaseReferences<_$AppDatabase, $ProgressPhotosTable, ProgressPhoto>),
          ProgressPhoto,
          PrefetchHooks Function()
        > {
  $$ProgressPhotosTableTableManager(_$AppDatabase db, $ProgressPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProgressPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProgressPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProgressPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayKey = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) =>
                  ProgressPhotosCompanion(id: id, dayKey: dayKey, fileName: fileName, note: note, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayKey,
                required String fileName,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProgressPhotosCompanion.insert(
                id: id,
                dayKey: dayKey,
                fileName: fileName,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressPhotosTable,
      ProgressPhoto,
      $$ProgressPhotosTableFilterComposer,
      $$ProgressPhotosTableOrderingComposer,
      $$ProgressPhotosTableAnnotationComposer,
      $$ProgressPhotosTableCreateCompanionBuilder,
      $$ProgressPhotosTableUpdateCompanionBuilder,
      (ProgressPhoto, BaseReferences<_$AppDatabase, $ProgressPhotosTable, ProgressPhoto>),
      ProgressPhoto,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required GoalKind kind,
      Value<int?> exerciseId,
      required double targetKg,
      Value<int?> targetReps,
      Value<double?> startKg,
      required int createdDayKey,
      Value<DateTime> createdAt,
      Value<int?> achievedDayKey,
      Value<int> sortOrder,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<GoalKind> kind,
      Value<int?> exerciseId,
      Value<double> targetKg,
      Value<int?> targetReps,
      Value<double?> startKg,
      Value<int> createdDayKey,
      Value<DateTime> createdAt,
      Value<int?> achievedDayKey,
      Value<int> sortOrder,
    });

final class $$GoalsTableReferences extends BaseReferences<_$AppDatabase, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias($_aliasNameGenerator(db.goals.exerciseId, db.exercises.id));

  $$ExercisesTableProcessedTableManager? get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id');
    if ($_column == null) return null;
    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<GoalKind, GoalKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get targetKg =>
      $composableBuilder(column: $table.targetKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetReps =>
      $composableBuilder(column: $table.targetReps, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get startKg =>
      $composableBuilder(column: $table.startKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdDayKey =>
      $composableBuilder(column: $table.createdDayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get achievedDayKey =>
      $composableBuilder(column: $table.achievedDayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalsTableOrderingComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetKg =>
      $composableBuilder(column: $table.targetKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetReps =>
      $composableBuilder(column: $table.targetReps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get startKg =>
      $composableBuilder(column: $table.startKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdDayKey =>
      $composableBuilder(column: $table.createdDayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get achievedDayKey =>
      $composableBuilder(column: $table.achievedDayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalsTableAnnotationComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get targetKg => $composableBuilder(column: $table.targetKg, builder: (column) => column);

  GeneratedColumn<int> get targetReps => $composableBuilder(column: $table.targetReps, builder: (column) => column);

  GeneratedColumn<double> get startKg => $composableBuilder(column: $table.startKg, builder: (column) => column);

  GeneratedColumn<int> get createdDayKey =>
      $composableBuilder(column: $table.createdDayKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get achievedDayKey =>
      $composableBuilder(column: $table.achievedDayKey, builder: (column) => column);

  GeneratedColumn<int> get sortOrder => $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, $$GoalsTableReferences),
          Goal,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<GoalKind> kind = const Value.absent(),
                Value<int?> exerciseId = const Value.absent(),
                Value<double> targetKg = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<double?> startKg = const Value.absent(),
                Value<int> createdDayKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> achievedDayKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                kind: kind,
                exerciseId: exerciseId,
                targetKg: targetKg,
                targetReps: targetReps,
                startKg: startKg,
                createdDayKey: createdDayKey,
                createdAt: createdAt,
                achievedDayKey: achievedDayKey,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required GoalKind kind,
                Value<int?> exerciseId = const Value.absent(),
                required double targetKg,
                Value<int?> targetReps = const Value.absent(),
                Value<double?> startKg = const Value.absent(),
                required int createdDayKey,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> achievedDayKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                kind: kind,
                exerciseId: exerciseId,
                targetKg: targetKg,
                targetReps: targetReps,
                startKg: startKg,
                createdDayKey: createdDayKey,
                createdAt: createdAt,
                achievedDayKey: achievedDayKey,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$GoalsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$GoalsTableReferences._exerciseIdTable(db),
                                referencedColumn: $$GoalsTableReferences._exerciseIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, $$GoalsTableReferences),
      Goal,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$ProgramDaysTableCreateCompanionBuilder =
    ProgramDaysCompanion Function({Value<int> weekday, required String label});
typedef $$ProgramDaysTableUpdateCompanionBuilder =
    ProgramDaysCompanion Function({Value<int> weekday, Value<String> label});

final class $$ProgramDaysTableReferences extends BaseReferences<_$AppDatabase, $ProgramDaysTable, ProgramDay> {
  $$ProgramDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProgramDayGroupsTable, List<ProgramDayGroup>> _programDayGroupsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.programDayGroups,
    aliasName: $_aliasNameGenerator(db.programDays.weekday, db.programDayGroups.weekday),
  );

  $$ProgramDayGroupsTableProcessedTableManager get programDayGroupsRefs {
    final manager = $$ProgramDayGroupsTableTableManager(
      $_db,
      $_db.programDayGroups,
    ).filter((f) => f.weekday.weekday.sqlEquals($_itemColumn<int>('weekday')!));

    final cache = $_typedResult.readTableOrNull(_programDayGroupsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProgramDayExercisesTable, List<ProgramDayExercise>> _programDayExercisesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.programDayExercises,
    aliasName: $_aliasNameGenerator(db.programDays.weekday, db.programDayExercises.weekday),
  );

  $$ProgramDayExercisesTableProcessedTableManager get programDayExercisesRefs {
    final manager = $$ProgramDayExercisesTableTableManager(
      $_db,
      $_db.programDayExercises,
    ).filter((f) => f.weekday.weekday.sqlEquals($_itemColumn<int>('weekday')!));

    final cache = $_typedResult.readTableOrNull(_programDayExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProgramDaysTableFilterComposer extends Composer<_$AppDatabase, $ProgramDaysTable> {
  $$ProgramDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  Expression<bool> programDayGroupsRefs(Expression<bool> Function($$ProgramDayGroupsTableFilterComposer f) f) {
    final $$ProgramDayGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDayGroups,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDayGroupsTableFilterComposer(
            $db: $db,
            $table: $db.programDayGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> programDayExercisesRefs(Expression<bool> Function($$ProgramDayExercisesTableFilterComposer f) f) {
    final $$ProgramDayExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDayExercises,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDayExercisesTableFilterComposer(
            $db: $db,
            $table: $db.programDayExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramDaysTableOrderingComposer extends Composer<_$AppDatabase, $ProgramDaysTable> {
  $$ProgramDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));
}

class $$ProgramDaysTableAnnotationComposer extends Composer<_$AppDatabase, $ProgramDaysTable> {
  $$ProgramDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get weekday => $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);

  Expression<T> programDayGroupsRefs<T extends Object>(
    Expression<T> Function($$ProgramDayGroupsTableAnnotationComposer a) f,
  ) {
    final $$ProgramDayGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDayGroups,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDayGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.programDayGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> programDayExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramDayExercisesTableAnnotationComposer a) f,
  ) {
    final $$ProgramDayExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDayExercises,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDayExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.programDayExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramDaysTable,
          ProgramDay,
          $$ProgramDaysTableFilterComposer,
          $$ProgramDaysTableOrderingComposer,
          $$ProgramDaysTableAnnotationComposer,
          $$ProgramDaysTableCreateCompanionBuilder,
          $$ProgramDaysTableUpdateCompanionBuilder,
          (ProgramDay, $$ProgramDaysTableReferences),
          ProgramDay,
          PrefetchHooks Function({bool programDayGroupsRefs, bool programDayExercisesRefs})
        > {
  $$ProgramDaysTableTableManager(_$AppDatabase db, $ProgramDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProgramDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProgramDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProgramDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({Value<int> weekday = const Value.absent(), Value<String> label = const Value.absent()}) =>
                  ProgramDaysCompanion(weekday: weekday, label: label),
          createCompanionCallback: ({Value<int> weekday = const Value.absent(), required String label}) =>
              ProgramDaysCompanion.insert(weekday: weekday, label: label),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$ProgramDaysTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({programDayGroupsRefs = false, programDayExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (programDayGroupsRefs) db.programDayGroups,
                if (programDayExercisesRefs) db.programDayExercises,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (programDayGroupsRefs)
                    await $_getPrefetchedData<ProgramDay, $ProgramDaysTable, ProgramDayGroup>(
                      currentTable: table,
                      referencedTable: $$ProgramDaysTableReferences._programDayGroupsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProgramDaysTableReferences(db, table, p0).programDayGroupsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.weekday == item.weekday),
                      typedResults: items,
                    ),
                  if (programDayExercisesRefs)
                    await $_getPrefetchedData<ProgramDay, $ProgramDaysTable, ProgramDayExercise>(
                      currentTable: table,
                      referencedTable: $$ProgramDaysTableReferences._programDayExercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProgramDaysTableReferences(db, table, p0).programDayExercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.weekday == item.weekday),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProgramDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramDaysTable,
      ProgramDay,
      $$ProgramDaysTableFilterComposer,
      $$ProgramDaysTableOrderingComposer,
      $$ProgramDaysTableAnnotationComposer,
      $$ProgramDaysTableCreateCompanionBuilder,
      $$ProgramDaysTableUpdateCompanionBuilder,
      (ProgramDay, $$ProgramDaysTableReferences),
      ProgramDay,
      PrefetchHooks Function({bool programDayGroupsRefs, bool programDayExercisesRefs})
    >;
typedef $$ProgramDayGroupsTableCreateCompanionBuilder =
    ProgramDayGroupsCompanion Function({required int weekday, required int groupId, Value<int> rowid});
typedef $$ProgramDayGroupsTableUpdateCompanionBuilder =
    ProgramDayGroupsCompanion Function({Value<int> weekday, Value<int> groupId, Value<int> rowid});

final class $$ProgramDayGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $ProgramDayGroupsTable, ProgramDayGroup> {
  $$ProgramDayGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProgramDaysTable _weekdayTable(_$AppDatabase db) =>
      db.programDays.createAlias($_aliasNameGenerator(db.programDayGroups.weekday, db.programDays.weekday));

  $$ProgramDaysTableProcessedTableManager get weekday {
    final $_column = $_itemColumn<int>('weekday')!;

    final manager = $$ProgramDaysTableTableManager($_db, $_db.programDays).filter((f) => f.weekday.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_weekdayTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MuscleGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.muscleGroups.createAlias($_aliasNameGenerator(db.programDayGroups.groupId, db.muscleGroups.id));

  $$MuscleGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$MuscleGroupsTableTableManager($_db, $_db.muscleGroups).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProgramDayGroupsTableFilterComposer extends Composer<_$AppDatabase, $ProgramDayGroupsTable> {
  $$ProgramDayGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ProgramDaysTableFilterComposer get weekday {
    final $$ProgramDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDays,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDaysTableFilterComposer(
            $db: $db,
            $table: $db.programDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableFilterComposer get groupId {
    final $$MuscleGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MuscleGroupsTableFilterComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayGroupsTableOrderingComposer extends Composer<_$AppDatabase, $ProgramDayGroupsTable> {
  $$ProgramDayGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ProgramDaysTableOrderingComposer get weekday {
    final $$ProgramDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDays,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDaysTableOrderingComposer(
            $db: $db,
            $table: $db.programDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableOrderingComposer get groupId {
    final $$MuscleGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MuscleGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayGroupsTableAnnotationComposer extends Composer<_$AppDatabase, $ProgramDayGroupsTable> {
  $$ProgramDayGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ProgramDaysTableAnnotationComposer get weekday {
    final $$ProgramDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDays,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.programDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableAnnotationComposer get groupId {
    final $$MuscleGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MuscleGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramDayGroupsTable,
          ProgramDayGroup,
          $$ProgramDayGroupsTableFilterComposer,
          $$ProgramDayGroupsTableOrderingComposer,
          $$ProgramDayGroupsTableAnnotationComposer,
          $$ProgramDayGroupsTableCreateCompanionBuilder,
          $$ProgramDayGroupsTableUpdateCompanionBuilder,
          (ProgramDayGroup, $$ProgramDayGroupsTableReferences),
          ProgramDayGroup,
          PrefetchHooks Function({bool weekday, bool groupId})
        > {
  $$ProgramDayGroupsTableTableManager(_$AppDatabase db, $ProgramDayGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProgramDayGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProgramDayGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProgramDayGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> weekday = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramDayGroupsCompanion(weekday: weekday, groupId: groupId, rowid: rowid),
          createCompanionCallback:
              ({required int weekday, required int groupId, Value<int> rowid = const Value.absent()}) =>
                  ProgramDayGroupsCompanion.insert(weekday: weekday, groupId: groupId, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$ProgramDayGroupsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({weekday = false, groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (weekday) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.weekday,
                                referencedTable: $$ProgramDayGroupsTableReferences._weekdayTable(db),
                                referencedColumn: $$ProgramDayGroupsTableReferences._weekdayTable(db).weekday,
                              )
                              as T;
                    }
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable: $$ProgramDayGroupsTableReferences._groupIdTable(db),
                                referencedColumn: $$ProgramDayGroupsTableReferences._groupIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProgramDayGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramDayGroupsTable,
      ProgramDayGroup,
      $$ProgramDayGroupsTableFilterComposer,
      $$ProgramDayGroupsTableOrderingComposer,
      $$ProgramDayGroupsTableAnnotationComposer,
      $$ProgramDayGroupsTableCreateCompanionBuilder,
      $$ProgramDayGroupsTableUpdateCompanionBuilder,
      (ProgramDayGroup, $$ProgramDayGroupsTableReferences),
      ProgramDayGroup,
      PrefetchHooks Function({bool weekday, bool groupId})
    >;
typedef $$ProgramDayExercisesTableCreateCompanionBuilder =
    ProgramDayExercisesCompanion Function({
      required int weekday,
      required int exerciseId,
      required int position,
      Value<int> rowid,
    });
typedef $$ProgramDayExercisesTableUpdateCompanionBuilder =
    ProgramDayExercisesCompanion Function({
      Value<int> weekday,
      Value<int> exerciseId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$ProgramDayExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ProgramDayExercisesTable, ProgramDayExercise> {
  $$ProgramDayExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProgramDaysTable _weekdayTable(_$AppDatabase db) =>
      db.programDays.createAlias($_aliasNameGenerator(db.programDayExercises.weekday, db.programDays.weekday));

  $$ProgramDaysTableProcessedTableManager get weekday {
    final $_column = $_itemColumn<int>('weekday')!;

    final manager = $$ProgramDaysTableTableManager($_db, $_db.programDays).filter((f) => f.weekday.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_weekdayTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias($_aliasNameGenerator(db.programDayExercises.exerciseId, db.exercises.id));

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProgramDayExercisesTableFilterComposer extends Composer<_$AppDatabase, $ProgramDayExercisesTable> {
  $$ProgramDayExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  $$ProgramDaysTableFilterComposer get weekday {
    final $$ProgramDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDays,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDaysTableFilterComposer(
            $db: $db,
            $table: $db.programDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayExercisesTableOrderingComposer extends Composer<_$AppDatabase, $ProgramDayExercisesTable> {
  $$ProgramDayExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  $$ProgramDaysTableOrderingComposer get weekday {
    final $$ProgramDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDays,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDaysTableOrderingComposer(
            $db: $db,
            $table: $db.programDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayExercisesTableAnnotationComposer extends Composer<_$AppDatabase, $ProgramDayExercisesTable> {
  $$ProgramDayExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position => $composableBuilder(column: $table.position, builder: (column) => column);

  $$ProgramDaysTableAnnotationComposer get weekday {
    final $$ProgramDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weekday,
      referencedTable: $db.programDays,
      getReferencedColumn: (t) => t.weekday,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProgramDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.programDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramDayExercisesTable,
          ProgramDayExercise,
          $$ProgramDayExercisesTableFilterComposer,
          $$ProgramDayExercisesTableOrderingComposer,
          $$ProgramDayExercisesTableAnnotationComposer,
          $$ProgramDayExercisesTableCreateCompanionBuilder,
          $$ProgramDayExercisesTableUpdateCompanionBuilder,
          (ProgramDayExercise, $$ProgramDayExercisesTableReferences),
          ProgramDayExercise,
          PrefetchHooks Function({bool weekday, bool exerciseId})
        > {
  $$ProgramDayExercisesTableTableManager(_$AppDatabase db, $ProgramDayExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProgramDayExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProgramDayExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProgramDayExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> weekday = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramDayExercisesCompanion(
                weekday: weekday,
                exerciseId: exerciseId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int weekday,
                required int exerciseId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => ProgramDayExercisesCompanion.insert(
                weekday: weekday,
                exerciseId: exerciseId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$ProgramDayExercisesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({weekday = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (weekday) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.weekday,
                                referencedTable: $$ProgramDayExercisesTableReferences._weekdayTable(db),
                                referencedColumn: $$ProgramDayExercisesTableReferences._weekdayTable(db).weekday,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ProgramDayExercisesTableReferences._exerciseIdTable(db),
                                referencedColumn: $$ProgramDayExercisesTableReferences._exerciseIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProgramDayExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramDayExercisesTable,
      ProgramDayExercise,
      $$ProgramDayExercisesTableFilterComposer,
      $$ProgramDayExercisesTableOrderingComposer,
      $$ProgramDayExercisesTableAnnotationComposer,
      $$ProgramDayExercisesTableCreateCompanionBuilder,
      $$ProgramDayExercisesTableUpdateCompanionBuilder,
      (ProgramDayExercise, $$ProgramDayExercisesTableReferences),
      ProgramDayExercise,
      PrefetchHooks Function({bool weekday, bool exerciseId})
    >;
typedef $$SessionHealthTableCreateCompanionBuilder =
    SessionHealthCompanion Function({
      Value<int> sessionId,
      required DateTime startAt,
      required DateTime endAt,
      Value<int?> avgHr,
      Value<int?> maxHr,
      Value<int?> activeKcal,
      Value<String?> source,
      Value<DateTime> fetchedAt,
    });
typedef $$SessionHealthTableUpdateCompanionBuilder =
    SessionHealthCompanion Function({
      Value<int> sessionId,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<int?> avgHr,
      Value<int?> maxHr,
      Value<int?> activeKcal,
      Value<String?> source,
      Value<DateTime> fetchedAt,
    });

final class $$SessionHealthTableReferences
    extends BaseReferences<_$AppDatabase, $SessionHealthTable, SessionHealthData> {
  $$SessionHealthTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias($_aliasNameGenerator(db.sessionHealth.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SessionHealthTableFilterComposer extends Composer<_$AppDatabase, $SessionHealthTable> {
  $$SessionHealthTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get avgHr => $composableBuilder(column: $table.avgHr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxHr => $composableBuilder(column: $table.maxHr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get activeKcal =>
      $composableBuilder(column: $table.activeKcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionHealthTableOrderingComposer extends Composer<_$AppDatabase, $SessionHealthTable> {
  $$SessionHealthTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get avgHr =>
      $composableBuilder(column: $table.avgHr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxHr =>
      $composableBuilder(column: $table.maxHr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get activeKcal =>
      $composableBuilder(column: $table.activeKcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionHealthTableAnnotationComposer extends Composer<_$AppDatabase, $SessionHealthTable> {
  $$SessionHealthTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get startAt => $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt => $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<int> get avgHr => $composableBuilder(column: $table.avgHr, builder: (column) => column);

  GeneratedColumn<int> get maxHr => $composableBuilder(column: $table.maxHr, builder: (column) => column);

  GeneratedColumn<int> get activeKcal => $composableBuilder(column: $table.activeKcal, builder: (column) => column);

  GeneratedColumn<String> get source => $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt => $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionHealthTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionHealthTable,
          SessionHealthData,
          $$SessionHealthTableFilterComposer,
          $$SessionHealthTableOrderingComposer,
          $$SessionHealthTableAnnotationComposer,
          $$SessionHealthTableCreateCompanionBuilder,
          $$SessionHealthTableUpdateCompanionBuilder,
          (SessionHealthData, $$SessionHealthTableReferences),
          SessionHealthData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionHealthTableTableManager(_$AppDatabase db, $SessionHealthTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionHealthTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionHealthTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionHealthTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<int?> avgHr = const Value.absent(),
                Value<int?> maxHr = const Value.absent(),
                Value<int?> activeKcal = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => SessionHealthCompanion(
                sessionId: sessionId,
                startAt: startAt,
                endAt: endAt,
                avgHr: avgHr,
                maxHr: maxHr,
                activeKcal: activeKcal,
                source: source,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> sessionId = const Value.absent(),
                required DateTime startAt,
                required DateTime endAt,
                Value<int?> avgHr = const Value.absent(),
                Value<int?> maxHr = const Value.absent(),
                Value<int?> activeKcal = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => SessionHealthCompanion.insert(
                sessionId: sessionId,
                startAt: startAt,
                endAt: endAt,
                avgHr: avgHr,
                maxHr: maxHr,
                activeKcal: activeKcal,
                source: source,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$SessionHealthTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SessionHealthTableReferences._sessionIdTable(db),
                                referencedColumn: $$SessionHealthTableReferences._sessionIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionHealthTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionHealthTable,
      SessionHealthData,
      $$SessionHealthTableFilterComposer,
      $$SessionHealthTableOrderingComposer,
      $$SessionHealthTableAnnotationComposer,
      $$SessionHealthTableCreateCompanionBuilder,
      $$SessionHealthTableUpdateCompanionBuilder,
      (SessionHealthData, $$SessionHealthTableReferences),
      SessionHealthData,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$DailyHealthTableCreateCompanionBuilder =
    DailyHealthCompanion Function({
      Value<int> dayKey,
      Value<int?> steps,
      Value<int?> sleepMin,
      Value<DateTime> fetchedAt,
    });
typedef $$DailyHealthTableUpdateCompanionBuilder =
    DailyHealthCompanion Function({
      Value<int> dayKey,
      Value<int?> steps,
      Value<int?> sleepMin,
      Value<DateTime> fetchedAt,
    });

class $$DailyHealthTableFilterComposer extends Composer<_$AppDatabase, $DailyHealthTable> {
  $$DailyHealthTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get steps => $composableBuilder(column: $table.steps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sleepMin =>
      $composableBuilder(column: $table.sleepMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
}

class $$DailyHealthTableOrderingComposer extends Composer<_$AppDatabase, $DailyHealthTable> {
  $$DailyHealthTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sleepMin =>
      $composableBuilder(column: $table.sleepMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyHealthTableAnnotationComposer extends Composer<_$AppDatabase, $DailyHealthTable> {
  $$DailyHealthTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dayKey => $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get steps => $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get sleepMin => $composableBuilder(column: $table.sleepMin, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt => $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$DailyHealthTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyHealthTable,
          DailyHealthData,
          $$DailyHealthTableFilterComposer,
          $$DailyHealthTableOrderingComposer,
          $$DailyHealthTableAnnotationComposer,
          $$DailyHealthTableCreateCompanionBuilder,
          $$DailyHealthTableUpdateCompanionBuilder,
          (DailyHealthData, BaseReferences<_$AppDatabase, $DailyHealthTable, DailyHealthData>),
          DailyHealthData,
          PrefetchHooks Function()
        > {
  $$DailyHealthTableTableManager(_$AppDatabase db, $DailyHealthTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DailyHealthTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DailyHealthTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$DailyHealthTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> dayKey = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<int?> sleepMin = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => DailyHealthCompanion(dayKey: dayKey, steps: steps, sleepMin: sleepMin, fetchedAt: fetchedAt),
          createCompanionCallback:
              ({
                Value<int> dayKey = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<int?> sleepMin = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => DailyHealthCompanion.insert(dayKey: dayKey, steps: steps, sleepMin: sleepMin, fetchedAt: fetchedAt),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyHealthTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyHealthTable,
      DailyHealthData,
      $$DailyHealthTableFilterComposer,
      $$DailyHealthTableOrderingComposer,
      $$DailyHealthTableAnnotationComposer,
      $$DailyHealthTableCreateCompanionBuilder,
      $$DailyHealthTableUpdateCompanionBuilder,
      (DailyHealthData, BaseReferences<_$AppDatabase, $DailyHealthTable, DailyHealthData>),
      DailyHealthData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions => $$SessionsTableTableManager(_db, _db.sessions);
  $$MuscleGroupsTableTableManager get muscleGroups => $$MuscleGroupsTableTableManager(_db, _db.muscleGroups);
  $$SessionGroupsTableTableManager get sessionGroups => $$SessionGroupsTableTableManager(_db, _db.sessionGroups);
  $$ExercisesTableTableManager get exercises => $$ExercisesTableTableManager(_db, _db.exercises);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(_db, _db.sessionExercises);
  $$ExerciseSetsTableTableManager get exerciseSets => $$ExerciseSetsTableTableManager(_db, _db.exerciseSets);
  $$BodyWeightsTableTableManager get bodyWeights => $$BodyWeightsTableTableManager(_db, _db.bodyWeights);
  $$ProgressPhotosTableTableManager get progressPhotos => $$ProgressPhotosTableTableManager(_db, _db.progressPhotos);
  $$GoalsTableTableManager get goals => $$GoalsTableTableManager(_db, _db.goals);
  $$ProgramDaysTableTableManager get programDays => $$ProgramDaysTableTableManager(_db, _db.programDays);
  $$ProgramDayGroupsTableTableManager get programDayGroups =>
      $$ProgramDayGroupsTableTableManager(_db, _db.programDayGroups);
  $$ProgramDayExercisesTableTableManager get programDayExercises =>
      $$ProgramDayExercisesTableTableManager(_db, _db.programDayExercises);
  $$SessionHealthTableTableManager get sessionHealth => $$SessionHealthTableTableManager(_db, _db.sessionHealth);
  $$DailyHealthTableTableManager get dailyHealth => $$DailyHealthTableTableManager(_db, _db.dailyHealth);
}
