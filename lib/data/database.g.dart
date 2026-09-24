// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SmokingProductsTable extends SmokingProducts
    with TableInfo<$SmokingProductsTable, SmokingProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmokingProductsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<ProductType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProductType>($SmokingProductsTable.$convertertype);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ConsumptionPeriod, String>
  period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ConsumptionPeriod>($SmokingProductsTable.$converterperiod);
  static const VerificationMeta _unitsPerPackMeta = const VerificationMeta(
    'unitsPerPack',
  );
  @override
  late final GeneratedColumn<int> unitsPerPack = GeneratedColumn<int>(
    'units_per_pack',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packPriceMeta = const VerificationMeta(
    'packPrice',
  );
  @override
  late final GeneratedColumn<double> packPrice = GeneratedColumn<double>(
    'pack_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    period,
    unitsPerPack,
    packPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'smoking_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmokingProduct> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('units_per_pack')) {
      context.handle(
        _unitsPerPackMeta,
        unitsPerPack.isAcceptableOrUnknown(
          data['units_per_pack']!,
          _unitsPerPackMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitsPerPackMeta);
    }
    if (data.containsKey('pack_price')) {
      context.handle(
        _packPriceMeta,
        packPrice.isAcceptableOrUnknown(data['pack_price']!, _packPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_packPriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmokingProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmokingProduct(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: $SmokingProductsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      period: $SmokingProductsTable.$converterperiod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}period'],
        )!,
      ),
      unitsPerPack: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_per_pack'],
      )!,
      packPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pack_price'],
      )!,
    );
  }

  @override
  $SmokingProductsTable createAlias(String alias) {
    return $SmokingProductsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProductType, String, String> $convertertype =
      const EnumNameConverter<ProductType>(ProductType.values);
  static JsonTypeConverter2<ConsumptionPeriod, String, String>
  $converterperiod = const EnumNameConverter<ConsumptionPeriod>(
    ConsumptionPeriod.values,
  );
}

class SmokingProduct extends DataClass implements Insertable<SmokingProduct> {
  final int id;
  final ProductType type;

  /// Units consumed per [period]: cigarettes/sticks, devices, or bottles.
  final double amount;
  final ConsumptionPeriod period;

  /// Units in one purchased pack (20 cigarettes; 1 for a disposable or a bottle).
  final int unitsPerPack;
  final double packPrice;
  const SmokingProduct({
    required this.id,
    required this.type,
    required this.amount,
    required this.period,
    required this.unitsPerPack,
    required this.packPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<String>(
        $SmokingProductsTable.$convertertype.toSql(type),
      );
    }
    map['amount'] = Variable<double>(amount);
    {
      map['period'] = Variable<String>(
        $SmokingProductsTable.$converterperiod.toSql(period),
      );
    }
    map['units_per_pack'] = Variable<int>(unitsPerPack);
    map['pack_price'] = Variable<double>(packPrice);
    return map;
  }

  SmokingProductsCompanion toCompanion(bool nullToAbsent) {
    return SmokingProductsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      period: Value(period),
      unitsPerPack: Value(unitsPerPack),
      packPrice: Value(packPrice),
    );
  }

  factory SmokingProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmokingProduct(
      id: serializer.fromJson<int>(json['id']),
      type: $SmokingProductsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      amount: serializer.fromJson<double>(json['amount']),
      period: $SmokingProductsTable.$converterperiod.fromJson(
        serializer.fromJson<String>(json['period']),
      ),
      unitsPerPack: serializer.fromJson<int>(json['unitsPerPack']),
      packPrice: serializer.fromJson<double>(json['packPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(
        $SmokingProductsTable.$convertertype.toJson(type),
      ),
      'amount': serializer.toJson<double>(amount),
      'period': serializer.toJson<String>(
        $SmokingProductsTable.$converterperiod.toJson(period),
      ),
      'unitsPerPack': serializer.toJson<int>(unitsPerPack),
      'packPrice': serializer.toJson<double>(packPrice),
    };
  }

  SmokingProduct copyWith({
    int? id,
    ProductType? type,
    double? amount,
    ConsumptionPeriod? period,
    int? unitsPerPack,
    double? packPrice,
  }) => SmokingProduct(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    period: period ?? this.period,
    unitsPerPack: unitsPerPack ?? this.unitsPerPack,
    packPrice: packPrice ?? this.packPrice,
  );
  SmokingProduct copyWithCompanion(SmokingProductsCompanion data) {
    return SmokingProduct(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      period: data.period.present ? data.period.value : this.period,
      unitsPerPack: data.unitsPerPack.present
          ? data.unitsPerPack.value
          : this.unitsPerPack,
      packPrice: data.packPrice.present ? data.packPrice.value : this.packPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmokingProduct(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('unitsPerPack: $unitsPerPack, ')
          ..write('packPrice: $packPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, amount, period, unitsPerPack, packPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmokingProduct &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.period == this.period &&
          other.unitsPerPack == this.unitsPerPack &&
          other.packPrice == this.packPrice);
}

class SmokingProductsCompanion extends UpdateCompanion<SmokingProduct> {
  final Value<int> id;
  final Value<ProductType> type;
  final Value<double> amount;
  final Value<ConsumptionPeriod> period;
  final Value<int> unitsPerPack;
  final Value<double> packPrice;
  const SmokingProductsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.period = const Value.absent(),
    this.unitsPerPack = const Value.absent(),
    this.packPrice = const Value.absent(),
  });
  SmokingProductsCompanion.insert({
    this.id = const Value.absent(),
    required ProductType type,
    required double amount,
    required ConsumptionPeriod period,
    required int unitsPerPack,
    required double packPrice,
  }) : type = Value(type),
       amount = Value(amount),
       period = Value(period),
       unitsPerPack = Value(unitsPerPack),
       packPrice = Value(packPrice);
  static Insertable<SmokingProduct> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? period,
    Expression<int>? unitsPerPack,
    Expression<double>? packPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (period != null) 'period': period,
      if (unitsPerPack != null) 'units_per_pack': unitsPerPack,
      if (packPrice != null) 'pack_price': packPrice,
    });
  }

  SmokingProductsCompanion copyWith({
    Value<int>? id,
    Value<ProductType>? type,
    Value<double>? amount,
    Value<ConsumptionPeriod>? period,
    Value<int>? unitsPerPack,
    Value<double>? packPrice,
  }) {
    return SmokingProductsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      unitsPerPack: unitsPerPack ?? this.unitsPerPack,
      packPrice: packPrice ?? this.packPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $SmokingProductsTable.$convertertype.toSql(type.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(
        $SmokingProductsTable.$converterperiod.toSql(period.value),
      );
    }
    if (unitsPerPack.present) {
      map['units_per_pack'] = Variable<int>(unitsPerPack.value);
    }
    if (packPrice.present) {
      map['pack_price'] = Variable<double>(packPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmokingProductsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('unitsPerPack: $unitsPerPack, ')
          ..write('packPrice: $packPrice')
          ..write(')'))
        .toString();
  }
}

class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RelapseTrigger?, String> trigger =
      GeneratedColumn<String>(
        'trigger',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<RelapseTrigger?>($AttemptsTable.$convertertriggern);
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
  List<GeneratedColumn> get $columns => [id, startedAt, endedAt, trigger, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      trigger: $AttemptsTable.$convertertriggern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trigger'],
        ),
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RelapseTrigger, String, String> $convertertrigger =
      const EnumNameConverter<RelapseTrigger>(RelapseTrigger.values);
  static JsonTypeConverter2<RelapseTrigger?, String?, String?>
  $convertertriggern = JsonTypeConverter2.asNullable($convertertrigger);
}

class Attempt extends DataClass implements Insertable<Attempt> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final RelapseTrigger? trigger;
  final String? note;
  const Attempt({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.trigger,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || trigger != null) {
      map['trigger'] = Variable<String>(
        $AttemptsTable.$convertertriggern.toSql(trigger),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      trigger: trigger == null && nullToAbsent
          ? const Value.absent()
          : Value(trigger),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Attempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      trigger: $AttemptsTable.$convertertriggern.fromJson(
        serializer.fromJson<String?>(json['trigger']),
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'trigger': serializer.toJson<String?>(
        $AttemptsTable.$convertertriggern.toJson(trigger),
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  Attempt copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<RelapseTrigger?> trigger = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Attempt(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    trigger: trigger.present ? trigger.value : this.trigger,
    note: note.present ? note.value : this.note,
  );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('trigger: $trigger, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAt, endedAt, trigger, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.trigger == this.trigger &&
          other.note == this.note);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<RelapseTrigger?> trigger;
  final Value<String?> note;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.trigger = const Value.absent(),
    this.note = const Value.absent(),
  });
  AttemptsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.trigger = const Value.absent(),
    this.note = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<Attempt> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? trigger,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (trigger != null) 'trigger': trigger,
      if (note != null) 'note': note,
    });
  }

  AttemptsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<RelapseTrigger?>? trigger,
    Value<String?>? note,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      trigger: trigger ?? this.trigger,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(
        $AttemptsTable.$convertertriggern.toSql(trigger.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('trigger: $trigger, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $CravingsTable extends Cravings with TableInfo<$CravingsTable, Craving> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CravingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<int> attemptId = GeneratedColumn<int>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attempts (id)',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resistedMeta = const VerificationMeta(
    'resisted',
  );
  @override
  late final GeneratedColumn<bool> resisted = GeneratedColumn<bool>(
    'resisted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resisted" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, attemptId, at, resisted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cravings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Craving> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('resisted')) {
      context.handle(
        _resistedMeta,
        resisted.isAcceptableOrUnknown(data['resisted']!, _resistedMeta),
      );
    } else if (isInserting) {
      context.missing(_resistedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Craving map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Craving(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      resisted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resisted'],
      )!,
    );
  }

  @override
  $CravingsTable createAlias(String alias) {
    return $CravingsTable(attachedDatabase, alias);
  }
}

class Craving extends DataClass implements Insertable<Craving> {
  final int id;
  final int attemptId;
  final DateTime at;
  final bool resisted;
  const Craving({
    required this.id,
    required this.attemptId,
    required this.at,
    required this.resisted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attempt_id'] = Variable<int>(attemptId);
    map['at'] = Variable<DateTime>(at);
    map['resisted'] = Variable<bool>(resisted);
    return map;
  }

  CravingsCompanion toCompanion(bool nullToAbsent) {
    return CravingsCompanion(
      id: Value(id),
      attemptId: Value(attemptId),
      at: Value(at),
      resisted: Value(resisted),
    );
  }

  factory Craving.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Craving(
      id: serializer.fromJson<int>(json['id']),
      attemptId: serializer.fromJson<int>(json['attemptId']),
      at: serializer.fromJson<DateTime>(json['at']),
      resisted: serializer.fromJson<bool>(json['resisted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attemptId': serializer.toJson<int>(attemptId),
      'at': serializer.toJson<DateTime>(at),
      'resisted': serializer.toJson<bool>(resisted),
    };
  }

  Craving copyWith({int? id, int? attemptId, DateTime? at, bool? resisted}) =>
      Craving(
        id: id ?? this.id,
        attemptId: attemptId ?? this.attemptId,
        at: at ?? this.at,
        resisted: resisted ?? this.resisted,
      );
  Craving copyWithCompanion(CravingsCompanion data) {
    return Craving(
      id: data.id.present ? data.id.value : this.id,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      at: data.at.present ? data.at.value : this.at,
      resisted: data.resisted.present ? data.resisted.value : this.resisted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Craving(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('at: $at, ')
          ..write('resisted: $resisted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, attemptId, at, resisted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Craving &&
          other.id == this.id &&
          other.attemptId == this.attemptId &&
          other.at == this.at &&
          other.resisted == this.resisted);
}

class CravingsCompanion extends UpdateCompanion<Craving> {
  final Value<int> id;
  final Value<int> attemptId;
  final Value<DateTime> at;
  final Value<bool> resisted;
  const CravingsCompanion({
    this.id = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.at = const Value.absent(),
    this.resisted = const Value.absent(),
  });
  CravingsCompanion.insert({
    this.id = const Value.absent(),
    required int attemptId,
    required DateTime at,
    required bool resisted,
  }) : attemptId = Value(attemptId),
       at = Value(at),
       resisted = Value(resisted);
  static Insertable<Craving> custom({
    Expression<int>? id,
    Expression<int>? attemptId,
    Expression<DateTime>? at,
    Expression<bool>? resisted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attemptId != null) 'attempt_id': attemptId,
      if (at != null) 'at': at,
      if (resisted != null) 'resisted': resisted,
    });
  }

  CravingsCompanion copyWith({
    Value<int>? id,
    Value<int>? attemptId,
    Value<DateTime>? at,
    Value<bool>? resisted,
  }) {
    return CravingsCompanion(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      at: at ?? this.at,
      resisted: resisted ?? this.resisted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<int>(attemptId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (resisted.present) {
      map['resisted'] = Variable<bool>(resisted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CravingsCompanion(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('at: $at, ')
          ..write('resisted: $resisted')
          ..write(')'))
        .toString();
  }
}

class $UnlockedAchievementsTable extends UnlockedAchievements
    with TableInfo<$UnlockedAchievementsTable, UnlockedAchievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnlockedAchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _achievementIdMeta = const VerificationMeta(
    'achievementId',
  );
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<int> attemptId = GeneratedColumn<int>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attempts (id)',
    ),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [achievementId, attemptId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unlocked_achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnlockedAchievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIdMeta,
        achievementId.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementId, attemptId};
  @override
  UnlockedAchievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnlockedAchievement(
      achievementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievement_id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $UnlockedAchievementsTable createAlias(String alias) {
    return $UnlockedAchievementsTable(attachedDatabase, alias);
  }
}

class UnlockedAchievement extends DataClass
    implements Insertable<UnlockedAchievement> {
  final String achievementId;
  final int attemptId;
  final DateTime unlockedAt;
  const UnlockedAchievement({
    required this.achievementId,
    required this.attemptId,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['achievement_id'] = Variable<String>(achievementId);
    map['attempt_id'] = Variable<int>(attemptId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  UnlockedAchievementsCompanion toCompanion(bool nullToAbsent) {
    return UnlockedAchievementsCompanion(
      achievementId: Value(achievementId),
      attemptId: Value(attemptId),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory UnlockedAchievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnlockedAchievement(
      achievementId: serializer.fromJson<String>(json['achievementId']),
      attemptId: serializer.fromJson<int>(json['attemptId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'achievementId': serializer.toJson<String>(achievementId),
      'attemptId': serializer.toJson<int>(attemptId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  UnlockedAchievement copyWith({
    String? achievementId,
    int? attemptId,
    DateTime? unlockedAt,
  }) => UnlockedAchievement(
    achievementId: achievementId ?? this.achievementId,
    attemptId: attemptId ?? this.attemptId,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
  UnlockedAchievement copyWithCompanion(UnlockedAchievementsCompanion data) {
    return UnlockedAchievement(
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedAchievement(')
          ..write('achievementId: $achievementId, ')
          ..write('attemptId: $attemptId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(achievementId, attemptId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnlockedAchievement &&
          other.achievementId == this.achievementId &&
          other.attemptId == this.attemptId &&
          other.unlockedAt == this.unlockedAt);
}

class UnlockedAchievementsCompanion
    extends UpdateCompanion<UnlockedAchievement> {
  final Value<String> achievementId;
  final Value<int> attemptId;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const UnlockedAchievementsCompanion({
    this.achievementId = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnlockedAchievementsCompanion.insert({
    required String achievementId,
    required int attemptId,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : achievementId = Value(achievementId),
       attemptId = Value(attemptId),
       unlockedAt = Value(unlockedAt);
  static Insertable<UnlockedAchievement> custom({
    Expression<String>? achievementId,
    Expression<int>? attemptId,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (achievementId != null) 'achievement_id': achievementId,
      if (attemptId != null) 'attempt_id': attemptId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnlockedAchievementsCompanion copyWith({
    Value<String>? achievementId,
    Value<int>? attemptId,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return UnlockedAchievementsCompanion(
      achievementId: achievementId ?? this.achievementId,
      attemptId: attemptId ?? this.attemptId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<int>(attemptId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedAchievementsCompanion(')
          ..write('achievementId: $achievementId, ')
          ..write('attemptId: $attemptId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArticlesReadTable extends ArticlesRead
    with TableInfo<$ArticlesReadTable, ArticlesReadData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesReadTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [articleId, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles_read';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticlesReadData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {articleId};
  @override
  ArticlesReadData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticlesReadData(
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      )!,
    );
  }

  @override
  $ArticlesReadTable createAlias(String alias) {
    return $ArticlesReadTable(attachedDatabase, alias);
  }
}

class ArticlesReadData extends DataClass
    implements Insertable<ArticlesReadData> {
  final String articleId;
  final DateTime readAt;
  const ArticlesReadData({required this.articleId, required this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['article_id'] = Variable<String>(articleId);
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  ArticlesReadCompanion toCompanion(bool nullToAbsent) {
    return ArticlesReadCompanion(
      articleId: Value(articleId),
      readAt: Value(readAt),
    );
  }

  factory ArticlesReadData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticlesReadData(
      articleId: serializer.fromJson<String>(json['articleId']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'articleId': serializer.toJson<String>(articleId),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  ArticlesReadData copyWith({String? articleId, DateTime? readAt}) =>
      ArticlesReadData(
        articleId: articleId ?? this.articleId,
        readAt: readAt ?? this.readAt,
      );
  ArticlesReadData copyWithCompanion(ArticlesReadCompanion data) {
    return ArticlesReadData(
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesReadData(')
          ..write('articleId: $articleId, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(articleId, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticlesReadData &&
          other.articleId == this.articleId &&
          other.readAt == this.readAt);
}

class ArticlesReadCompanion extends UpdateCompanion<ArticlesReadData> {
  final Value<String> articleId;
  final Value<DateTime> readAt;
  final Value<int> rowid;
  const ArticlesReadCompanion({
    this.articleId = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticlesReadCompanion.insert({
    required String articleId,
    required DateTime readAt,
    this.rowid = const Value.absent(),
  }) : articleId = Value(articleId),
       readAt = Value(readAt);
  static Insertable<ArticlesReadData> custom({
    Expression<String>? articleId,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (articleId != null) 'article_id': articleId,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticlesReadCompanion copyWith({
    Value<String>? articleId,
    Value<DateTime>? readAt,
    Value<int>? rowid,
  }) {
    return ArticlesReadCompanion(
      articleId: articleId ?? this.articleId,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesReadCompanion(')
          ..write('articleId: $articleId, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SmokingProductsTable smokingProducts = $SmokingProductsTable(
    this,
  );
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $CravingsTable cravings = $CravingsTable(this);
  late final $UnlockedAchievementsTable unlockedAchievements =
      $UnlockedAchievementsTable(this);
  late final $ArticlesReadTable articlesRead = $ArticlesReadTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    smokingProducts,
    attempts,
    cravings,
    unlockedAchievements,
    articlesRead,
  ];
}

typedef $$SmokingProductsTableCreateCompanionBuilder =
    SmokingProductsCompanion Function({
      Value<int> id,
      required ProductType type,
      required double amount,
      required ConsumptionPeriod period,
      required int unitsPerPack,
      required double packPrice,
    });
typedef $$SmokingProductsTableUpdateCompanionBuilder =
    SmokingProductsCompanion Function({
      Value<int> id,
      Value<ProductType> type,
      Value<double> amount,
      Value<ConsumptionPeriod> period,
      Value<int> unitsPerPack,
      Value<double> packPrice,
    });

class $$SmokingProductsTableFilterComposer
    extends Composer<_$AppDatabase, $SmokingProductsTable> {
  $$SmokingProductsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ProductType, ProductType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ConsumptionPeriod, ConsumptionPeriod, String>
  get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get unitsPerPack => $composableBuilder(
    column: $table.unitsPerPack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get packPrice => $composableBuilder(
    column: $table.packPrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SmokingProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $SmokingProductsTable> {
  $$SmokingProductsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsPerPack => $composableBuilder(
    column: $table.unitsPerPack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get packPrice => $composableBuilder(
    column: $table.packPrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmokingProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmokingProductsTable> {
  $$SmokingProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProductType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ConsumptionPeriod, String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<int> get unitsPerPack => $composableBuilder(
    column: $table.unitsPerPack,
    builder: (column) => column,
  );

  GeneratedColumn<double> get packPrice =>
      $composableBuilder(column: $table.packPrice, builder: (column) => column);
}

class $$SmokingProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SmokingProductsTable,
          SmokingProduct,
          $$SmokingProductsTableFilterComposer,
          $$SmokingProductsTableOrderingComposer,
          $$SmokingProductsTableAnnotationComposer,
          $$SmokingProductsTableCreateCompanionBuilder,
          $$SmokingProductsTableUpdateCompanionBuilder,
          (
            SmokingProduct,
            BaseReferences<
              _$AppDatabase,
              $SmokingProductsTable,
              SmokingProduct
            >,
          ),
          SmokingProduct,
          PrefetchHooks Function()
        > {
  $$SmokingProductsTableTableManager(
    _$AppDatabase db,
    $SmokingProductsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmokingProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmokingProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmokingProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ProductType> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<ConsumptionPeriod> period = const Value.absent(),
                Value<int> unitsPerPack = const Value.absent(),
                Value<double> packPrice = const Value.absent(),
              }) => SmokingProductsCompanion(
                id: id,
                type: type,
                amount: amount,
                period: period,
                unitsPerPack: unitsPerPack,
                packPrice: packPrice,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ProductType type,
                required double amount,
                required ConsumptionPeriod period,
                required int unitsPerPack,
                required double packPrice,
              }) => SmokingProductsCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                period: period,
                unitsPerPack: unitsPerPack,
                packPrice: packPrice,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SmokingProductsTable, SmokingProduct>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SmokingProductsTable,
                    SmokingProduct
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SmokingProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SmokingProductsTable,
      SmokingProduct,
      $$SmokingProductsTableFilterComposer,
      $$SmokingProductsTableOrderingComposer,
      $$SmokingProductsTableAnnotationComposer,
      $$SmokingProductsTableCreateCompanionBuilder,
      $$SmokingProductsTableUpdateCompanionBuilder,
      (
        SmokingProduct,
        BaseReferences<_$AppDatabase, $SmokingProductsTable, SmokingProduct>,
      ),
      SmokingProduct,
      PrefetchHooks Function()
    >;
typedef $$AttemptsTableCreateCompanionBuilder = AttemptsCompanion Function({
  Value<int> id,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<RelapseTrigger?> trigger,
  Value<String?> note,
});
typedef $$AttemptsTableUpdateCompanionBuilder = AttemptsCompanion Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<RelapseTrigger?> trigger,
  Value<String?> note,
});

final class $$AttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $AttemptsTable, Attempt> {
  $$AttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CravingsTable, List<Craving>> _cravingsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cravings,
    aliasName: 'attempts__id__cravings__attempt_id',
  );

  $$CravingsTableProcessedTableManager get cravingsRefs {
    final manager = $$CravingsTableTableManager(
      $_db,
      $_db.cravings,
    ).filter((f) => f.attemptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cravingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $UnlockedAchievementsTable,
    List<UnlockedAchievement>
  >
  _unlockedAchievementsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.unlockedAchievements,
        aliasName: 'attempts__id__unlocked_achievements__attempt_id',
      );

  $$UnlockedAchievementsTableProcessedTableManager
  get unlockedAchievementsRefs {
    final manager = $$UnlockedAchievementsTableTableManager(
      $_db,
      $_db.unlockedAchievements,
    ).filter((f) => f.attemptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _unlockedAchievementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RelapseTrigger?, RelapseTrigger, String>
  get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cravingsRefs(
    Expression<bool> Function($$CravingsTableFilterComposer f) f,
  ) {
    final $$CravingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cravings,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CravingsTableFilterComposer(
            $db: $db,
            $table: $db.cravings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> unlockedAchievementsRefs(
    Expression<bool> Function($$UnlockedAchievementsTableFilterComposer f) f,
  ) {
    final $$UnlockedAchievementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.unlockedAchievements,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnlockedAchievementsTableFilterComposer(
            $db: $db,
            $table: $db.unlockedAchievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RelapseTrigger?, String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> cravingsRefs<T extends Object>(
    Expression<T> Function($$CravingsTableAnnotationComposer a) f,
  ) {
    final $$CravingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cravings,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CravingsTableAnnotationComposer(
            $db: $db,
            $table: $db.cravings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> unlockedAchievementsRefs<T extends Object>(
    Expression<T> Function($$UnlockedAchievementsTableAnnotationComposer a) f,
  ) {
    final $$UnlockedAchievementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.unlockedAchievements,
          getReferencedColumn: (t) => t.attemptId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UnlockedAchievementsTableAnnotationComposer(
                $db: $db,
                $table: $db.unlockedAchievements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptsTable,
          Attempt,
          $$AttemptsTableFilterComposer,
          $$AttemptsTableOrderingComposer,
          $$AttemptsTableAnnotationComposer,
          $$AttemptsTableCreateCompanionBuilder,
          $$AttemptsTableUpdateCompanionBuilder,
          (Attempt, $$AttemptsTableReferences),
          Attempt,
          PrefetchHooks Function({
            bool cravingsRefs,
            bool unlockedAchievementsRefs,
          })
        > {
  $$AttemptsTableTableManager(_$AppDatabase db, $AttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<RelapseTrigger?> trigger = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                trigger: trigger,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<RelapseTrigger?> trigger = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => AttemptsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                trigger: trigger,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttemptsTable, Attempt>(table),
                  $$AttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({cravingsRefs = false, unlockedAchievementsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cravingsRefs) db.cravings,
                    if (unlockedAchievementsRefs) db.unlockedAchievements,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cravingsRefs)
                        await $_getPrefetchedData<
                          Attempt,
                          $AttemptsTable,
                          Craving
                        >(
                          currentTable: table,
                          referencedTable: $$AttemptsTableReferences
                              ._cravingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttemptsTableReferences(
                                db,
                                table,
                                p0,
                              ).cravingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.attemptId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (unlockedAchievementsRefs)
                        await $_getPrefetchedData<
                          Attempt,
                          $AttemptsTable,
                          UnlockedAchievement
                        >(
                          currentTable: table,
                          referencedTable: $$AttemptsTableReferences
                              ._unlockedAchievementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttemptsTableReferences(
                                db,
                                table,
                                p0,
                              ).unlockedAchievementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.attemptId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptsTable,
      Attempt,
      $$AttemptsTableFilterComposer,
      $$AttemptsTableOrderingComposer,
      $$AttemptsTableAnnotationComposer,
      $$AttemptsTableCreateCompanionBuilder,
      $$AttemptsTableUpdateCompanionBuilder,
      (Attempt, $$AttemptsTableReferences),
      Attempt,
      PrefetchHooks Function({bool cravingsRefs, bool unlockedAchievementsRefs})
    >;
typedef $$CravingsTableCreateCompanionBuilder = CravingsCompanion Function({
  Value<int> id,
  required int attemptId,
  required DateTime at,
  required bool resisted,
});
typedef $$CravingsTableUpdateCompanionBuilder = CravingsCompanion Function({
  Value<int> id,
  Value<int> attemptId,
  Value<DateTime> at,
  Value<bool> resisted,
});

final class $$CravingsTableReferences
    extends BaseReferences<_$AppDatabase, $CravingsTable, Craving> {
  $$CravingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AttemptsTable _attemptIdTable(_$AppDatabase db) =>
      db.attempts.createAlias('cravings__attempt_id__attempts__id');

  $$AttemptsTableProcessedTableManager get attemptId {
    final $_column = $_itemColumn<int>('attempt_id')!;

    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attemptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CravingsTableFilterComposer
    extends Composer<_$AppDatabase, $CravingsTable> {
  $$CravingsTableFilterComposer({
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

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resisted => $composableBuilder(
    column: $table.resisted,
    builder: (column) => ColumnFilters(column),
  );

  $$AttemptsTableFilterComposer get attemptId {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CravingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CravingsTable> {
  $$CravingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resisted => $composableBuilder(
    column: $table.resisted,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttemptsTableOrderingComposer get attemptId {
    final $$AttemptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableOrderingComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CravingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CravingsTable> {
  $$CravingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<bool> get resisted =>
      $composableBuilder(column: $table.resisted, builder: (column) => column);

  $$AttemptsTableAnnotationComposer get attemptId {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CravingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CravingsTable,
          Craving,
          $$CravingsTableFilterComposer,
          $$CravingsTableOrderingComposer,
          $$CravingsTableAnnotationComposer,
          $$CravingsTableCreateCompanionBuilder,
          $$CravingsTableUpdateCompanionBuilder,
          (Craving, $$CravingsTableReferences),
          Craving,
          PrefetchHooks Function({bool attemptId})
        > {
  $$CravingsTableTableManager(_$AppDatabase db, $CravingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CravingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CravingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CravingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attemptId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<bool> resisted = const Value.absent(),
              }) => CravingsCompanion(
                id: id,
                attemptId: attemptId,
                at: at,
                resisted: resisted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int attemptId,
                required DateTime at,
                required bool resisted,
              }) => CravingsCompanion.insert(
                id: id,
                attemptId: attemptId,
                at: at,
                resisted: resisted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CravingsTable, Craving>(table),
                  $$CravingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attemptId = false}) {
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
                    if (attemptId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.attemptId,
                        referencedTable: $$CravingsTableReferences
                            ._attemptIdTable(db),
                        referencedColumn: $$CravingsTableReferences
                            ._attemptIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CravingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CravingsTable,
      Craving,
      $$CravingsTableFilterComposer,
      $$CravingsTableOrderingComposer,
      $$CravingsTableAnnotationComposer,
      $$CravingsTableCreateCompanionBuilder,
      $$CravingsTableUpdateCompanionBuilder,
      (Craving, $$CravingsTableReferences),
      Craving,
      PrefetchHooks Function({bool attemptId})
    >;
typedef $$UnlockedAchievementsTableCreateCompanionBuilder =
    UnlockedAchievementsCompanion Function({
      required String achievementId,
      required int attemptId,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$UnlockedAchievementsTableUpdateCompanionBuilder =
    UnlockedAchievementsCompanion Function({
      Value<String> achievementId,
      Value<int> attemptId,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

final class $$UnlockedAchievementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UnlockedAchievementsTable,
          UnlockedAchievement
        > {
  $$UnlockedAchievementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttemptsTable _attemptIdTable(_$AppDatabase db) => db.attempts
      .createAlias('unlocked_achievements__attempt_id__attempts__id');

  $$AttemptsTableProcessedTableManager get attemptId {
    final $_column = $_itemColumn<int>('attempt_id')!;

    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attemptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UnlockedAchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AttemptsTableFilterComposer get attemptId {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnlockedAchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttemptsTableOrderingComposer get attemptId {
    final $$AttemptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableOrderingComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnlockedAchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  $$AttemptsTableAnnotationComposer get attemptId {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnlockedAchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnlockedAchievementsTable,
          UnlockedAchievement,
          $$UnlockedAchievementsTableFilterComposer,
          $$UnlockedAchievementsTableOrderingComposer,
          $$UnlockedAchievementsTableAnnotationComposer,
          $$UnlockedAchievementsTableCreateCompanionBuilder,
          $$UnlockedAchievementsTableUpdateCompanionBuilder,
          (UnlockedAchievement, $$UnlockedAchievementsTableReferences),
          UnlockedAchievement,
          PrefetchHooks Function({bool attemptId})
        > {
  $$UnlockedAchievementsTableTableManager(
    _$AppDatabase db,
    $UnlockedAchievementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnlockedAchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnlockedAchievementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UnlockedAchievementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> achievementId = const Value.absent(),
                Value<int> attemptId = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnlockedAchievementsCompanion(
                achievementId: achievementId,
                attemptId: attemptId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String achievementId,
                required int attemptId,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => UnlockedAchievementsCompanion.insert(
                achievementId: achievementId,
                attemptId: attemptId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UnlockedAchievementsTable, UnlockedAchievement>(
                    table,
                  ),
                  $$UnlockedAchievementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attemptId = false}) {
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
                    if (attemptId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.attemptId,
                        referencedTable: $$UnlockedAchievementsTableReferences
                            ._attemptIdTable(db),
                        referencedColumn: $$UnlockedAchievementsTableReferences
                            ._attemptIdTable(db)
                            .id,
                      ) as T;
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

typedef $$UnlockedAchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnlockedAchievementsTable,
      UnlockedAchievement,
      $$UnlockedAchievementsTableFilterComposer,
      $$UnlockedAchievementsTableOrderingComposer,
      $$UnlockedAchievementsTableAnnotationComposer,
      $$UnlockedAchievementsTableCreateCompanionBuilder,
      $$UnlockedAchievementsTableUpdateCompanionBuilder,
      (UnlockedAchievement, $$UnlockedAchievementsTableReferences),
      UnlockedAchievement,
      PrefetchHooks Function({bool attemptId})
    >;
typedef $$ArticlesReadTableCreateCompanionBuilder =
    ArticlesReadCompanion Function({
      required String articleId,
      required DateTime readAt,
      Value<int> rowid,
    });
typedef $$ArticlesReadTableUpdateCompanionBuilder =
    ArticlesReadCompanion Function({
      Value<String> articleId,
      Value<DateTime> readAt,
      Value<int> rowid,
    });

class $$ArticlesReadTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesReadTable> {
  $$ArticlesReadTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArticlesReadTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesReadTable> {
  $$ArticlesReadTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticlesReadTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesReadTable> {
  $$ArticlesReadTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$ArticlesReadTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesReadTable,
          ArticlesReadData,
          $$ArticlesReadTableFilterComposer,
          $$ArticlesReadTableOrderingComposer,
          $$ArticlesReadTableAnnotationComposer,
          $$ArticlesReadTableCreateCompanionBuilder,
          $$ArticlesReadTableUpdateCompanionBuilder,
          (
            ArticlesReadData,
            BaseReferences<_$AppDatabase, $ArticlesReadTable, ArticlesReadData>,
          ),
          ArticlesReadData,
          PrefetchHooks Function()
        > {
  $$ArticlesReadTableTableManager(_$AppDatabase db, $ArticlesReadTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesReadTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesReadTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesReadTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> articleId = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesReadCompanion(
                articleId: articleId,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String articleId,
                required DateTime readAt,
                Value<int> rowid = const Value.absent(),
              }) => ArticlesReadCompanion.insert(
                articleId: articleId,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArticlesReadTable, ArticlesReadData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ArticlesReadTable,
                    ArticlesReadData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArticlesReadTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesReadTable,
      ArticlesReadData,
      $$ArticlesReadTableFilterComposer,
      $$ArticlesReadTableOrderingComposer,
      $$ArticlesReadTableAnnotationComposer,
      $$ArticlesReadTableCreateCompanionBuilder,
      $$ArticlesReadTableUpdateCompanionBuilder,
      (
        ArticlesReadData,
        BaseReferences<_$AppDatabase, $ArticlesReadTable, ArticlesReadData>,
      ),
      ArticlesReadData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SmokingProductsTableTableManager get smokingProducts =>
      $$SmokingProductsTableTableManager(_db, _db.smokingProducts);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$CravingsTableTableManager get cravings =>
      $$CravingsTableTableManager(_db, _db.cravings);
  $$UnlockedAchievementsTableTableManager get unlockedAchievements =>
      $$UnlockedAchievementsTableTableManager(_db, _db.unlockedAchievements);
  $$ArticlesReadTableTableManager get articlesRead =>
      $$ArticlesReadTableTableManager(_db, _db.articlesRead);
}
