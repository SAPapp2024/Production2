// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DBSampleModelTable extends DBSampleModel
    with TableInfo<$DBSampleModelTable, DBSampleModelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DBSampleModelTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _privateIdMeta =
      const VerificationMeta('privateId');
  @override
  late final GeneratedColumn<int> privateId = GeneratedColumn<int>(
      'private_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sampleDateMeta =
      const VerificationMeta('sampleDate');
  @override
  late final GeneratedColumn<DateTime> sampleDate = GeneratedColumn<DateTime>(
      'sample_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _locationPlotMeta =
      const VerificationMeta('locationPlot');
  @override
  late final GeneratedColumn<String> locationPlot = GeneratedColumn<String>(
      'location_plot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cultivationMeta =
      const VerificationMeta('cultivation');
  @override
  late final GeneratedColumn<String> cultivation = GeneratedColumn<String>(
      'cultivation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _treatmentMeta =
      const VerificationMeta('treatment');
  @override
  late final GeneratedColumn<String> treatment = GeneratedColumn<String>(
      'treatment', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cropMeta = const VerificationMeta('crop');
  @override
  late final GeneratedColumn<String> crop = GeneratedColumn<String>(
      'crop', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _varietyMeta =
      const VerificationMeta('variety');
  @override
  late final GeneratedColumn<String> variety = GeneratedColumn<String>(
      'variety', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _growerMeta = const VerificationMeta('grower');
  @override
  late final GeneratedColumn<String> grower = GeneratedColumn<String>(
      'grower', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _youngSamplesProvidedMeta =
      const VerificationMeta('youngSamplesProvided');
  @override
  late final GeneratedColumn<bool> youngSamplesProvided = GeneratedColumn<bool>(
      'young_samples_provided', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("young_samples_provided" IN (0, 1))'));
  static const VerificationMeta _oldSamplesProvidedMeta =
      const VerificationMeta('oldSamplesProvided');
  @override
  late final GeneratedColumn<bool> oldSamplesProvided = GeneratedColumn<bool>(
      'old_samples_provided', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("old_samples_provided" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        privateId,
        id,
        sampleDate,
        locationPlot,
        cultivation,
        treatment,
        crop,
        variety,
        grower,
        notes,
        latitude,
        longitude,
        youngSamplesProvided,
        oldSamplesProvided
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'd_b_sample_model';
  @override
  VerificationContext validateIntegrity(Insertable<DBSampleModelData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('private_id')) {
      context.handle(_privateIdMeta,
          privateId.isAcceptableOrUnknown(data['private_id']!, _privateIdMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sample_date')) {
      context.handle(
          _sampleDateMeta,
          sampleDate.isAcceptableOrUnknown(
              data['sample_date']!, _sampleDateMeta));
    }
    if (data.containsKey('location_plot')) {
      context.handle(
          _locationPlotMeta,
          locationPlot.isAcceptableOrUnknown(
              data['location_plot']!, _locationPlotMeta));
    } else if (isInserting) {
      context.missing(_locationPlotMeta);
    }
    if (data.containsKey('cultivation')) {
      context.handle(
          _cultivationMeta,
          cultivation.isAcceptableOrUnknown(
              data['cultivation']!, _cultivationMeta));
    } else if (isInserting) {
      context.missing(_cultivationMeta);
    }
    if (data.containsKey('treatment')) {
      context.handle(_treatmentMeta,
          treatment.isAcceptableOrUnknown(data['treatment']!, _treatmentMeta));
    } else if (isInserting) {
      context.missing(_treatmentMeta);
    }
    if (data.containsKey('crop')) {
      context.handle(
          _cropMeta, crop.isAcceptableOrUnknown(data['crop']!, _cropMeta));
    } else if (isInserting) {
      context.missing(_cropMeta);
    }
    if (data.containsKey('variety')) {
      context.handle(_varietyMeta,
          variety.isAcceptableOrUnknown(data['variety']!, _varietyMeta));
    }
    if (data.containsKey('grower')) {
      context.handle(_growerMeta,
          grower.isAcceptableOrUnknown(data['grower']!, _growerMeta));
    } else if (isInserting) {
      context.missing(_growerMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('young_samples_provided')) {
      context.handle(
          _youngSamplesProvidedMeta,
          youngSamplesProvided.isAcceptableOrUnknown(
              data['young_samples_provided']!, _youngSamplesProvidedMeta));
    } else if (isInserting) {
      context.missing(_youngSamplesProvidedMeta);
    }
    if (data.containsKey('old_samples_provided')) {
      context.handle(
          _oldSamplesProvidedMeta,
          oldSamplesProvided.isAcceptableOrUnknown(
              data['old_samples_provided']!, _oldSamplesProvidedMeta));
    } else if (isInserting) {
      context.missing(_oldSamplesProvidedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {privateId};
  @override
  DBSampleModelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBSampleModelData(
      privateId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}private_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sampleDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sample_date']),
      locationPlot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_plot'])!,
      cultivation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cultivation'])!,
      treatment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}treatment'])!,
      crop: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop'])!,
      variety: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variety']),
      grower: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grower'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      youngSamplesProvided: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}young_samples_provided'])!,
      oldSamplesProvided: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}old_samples_provided'])!,
    );
  }

  @override
  $DBSampleModelTable createAlias(String alias) {
    return $DBSampleModelTable(attachedDatabase, alias);
  }
}

class DBSampleModelData extends DataClass
    implements Insertable<DBSampleModelData> {
  final int privateId;
  final String id;
  final DateTime? sampleDate;
  final String locationPlot;
  final String cultivation;
  final String treatment;
  final String crop;
  final String? variety;
  final String grower;
  final String notes;
  final double? latitude;
  final double? longitude;
  final bool youngSamplesProvided;
  final bool oldSamplesProvided;
  const DBSampleModelData(
      {required this.privateId,
      required this.id,
      this.sampleDate,
      required this.locationPlot,
      required this.cultivation,
      required this.treatment,
      required this.crop,
      this.variety,
      required this.grower,
      required this.notes,
      this.latitude,
      this.longitude,
      required this.youngSamplesProvided,
      required this.oldSamplesProvided});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['private_id'] = Variable<int>(privateId);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sampleDate != null) {
      map['sample_date'] = Variable<DateTime>(sampleDate);
    }
    map['location_plot'] = Variable<String>(locationPlot);
    map['cultivation'] = Variable<String>(cultivation);
    map['treatment'] = Variable<String>(treatment);
    map['crop'] = Variable<String>(crop);
    if (!nullToAbsent || variety != null) {
      map['variety'] = Variable<String>(variety);
    }
    map['grower'] = Variable<String>(grower);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['young_samples_provided'] = Variable<bool>(youngSamplesProvided);
    map['old_samples_provided'] = Variable<bool>(oldSamplesProvided);
    return map;
  }

  DBSampleModelCompanion toCompanion(bool nullToAbsent) {
    return DBSampleModelCompanion(
      privateId: Value(privateId),
      id: Value(id),
      sampleDate: sampleDate == null && nullToAbsent
          ? const Value.absent()
          : Value(sampleDate),
      locationPlot: Value(locationPlot),
      cultivation: Value(cultivation),
      treatment: Value(treatment),
      crop: Value(crop),
      variety: variety == null && nullToAbsent
          ? const Value.absent()
          : Value(variety),
      grower: Value(grower),
      notes: Value(notes),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      youngSamplesProvided: Value(youngSamplesProvided),
      oldSamplesProvided: Value(oldSamplesProvided),
    );
  }

  factory DBSampleModelData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBSampleModelData(
      privateId: serializer.fromJson<int>(json['privateId']),
      id: serializer.fromJson<String>(json['id']),
      sampleDate: serializer.fromJson<DateTime?>(json['sampleDate']),
      locationPlot: serializer.fromJson<String>(json['locationPlot']),
      cultivation: serializer.fromJson<String>(json['cultivation']),
      treatment: serializer.fromJson<String>(json['treatment']),
      crop: serializer.fromJson<String>(json['crop']),
      variety: serializer.fromJson<String?>(json['variety']),
      grower: serializer.fromJson<String>(json['grower']),
      notes: serializer.fromJson<String>(json['notes']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      youngSamplesProvided:
          serializer.fromJson<bool>(json['youngSamplesProvided']),
      oldSamplesProvided: serializer.fromJson<bool>(json['oldSamplesProvided']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'privateId': serializer.toJson<int>(privateId),
      'id': serializer.toJson<String>(id),
      'sampleDate': serializer.toJson<DateTime?>(sampleDate),
      'locationPlot': serializer.toJson<String>(locationPlot),
      'cultivation': serializer.toJson<String>(cultivation),
      'treatment': serializer.toJson<String>(treatment),
      'crop': serializer.toJson<String>(crop),
      'variety': serializer.toJson<String?>(variety),
      'grower': serializer.toJson<String>(grower),
      'notes': serializer.toJson<String>(notes),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'youngSamplesProvided': serializer.toJson<bool>(youngSamplesProvided),
      'oldSamplesProvided': serializer.toJson<bool>(oldSamplesProvided),
    };
  }

  DBSampleModelData copyWith(
          {int? privateId,
          String? id,
          Value<DateTime?> sampleDate = const Value.absent(),
          String? locationPlot,
          String? cultivation,
          String? treatment,
          String? crop,
          Value<String?> variety = const Value.absent(),
          String? grower,
          String? notes,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          bool? youngSamplesProvided,
          bool? oldSamplesProvided}) =>
      DBSampleModelData(
        privateId: privateId ?? this.privateId,
        id: id ?? this.id,
        sampleDate: sampleDate.present ? sampleDate.value : this.sampleDate,
        locationPlot: locationPlot ?? this.locationPlot,
        cultivation: cultivation ?? this.cultivation,
        treatment: treatment ?? this.treatment,
        crop: crop ?? this.crop,
        variety: variety.present ? variety.value : this.variety,
        grower: grower ?? this.grower,
        notes: notes ?? this.notes,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        youngSamplesProvided: youngSamplesProvided ?? this.youngSamplesProvided,
        oldSamplesProvided: oldSamplesProvided ?? this.oldSamplesProvided,
      );
  DBSampleModelData copyWithCompanion(DBSampleModelCompanion data) {
    return DBSampleModelData(
      privateId: data.privateId.present ? data.privateId.value : this.privateId,
      id: data.id.present ? data.id.value : this.id,
      sampleDate:
          data.sampleDate.present ? data.sampleDate.value : this.sampleDate,
      locationPlot: data.locationPlot.present
          ? data.locationPlot.value
          : this.locationPlot,
      cultivation:
          data.cultivation.present ? data.cultivation.value : this.cultivation,
      treatment: data.treatment.present ? data.treatment.value : this.treatment,
      crop: data.crop.present ? data.crop.value : this.crop,
      variety: data.variety.present ? data.variety.value : this.variety,
      grower: data.grower.present ? data.grower.value : this.grower,
      notes: data.notes.present ? data.notes.value : this.notes,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      youngSamplesProvided: data.youngSamplesProvided.present
          ? data.youngSamplesProvided.value
          : this.youngSamplesProvided,
      oldSamplesProvided: data.oldSamplesProvided.present
          ? data.oldSamplesProvided.value
          : this.oldSamplesProvided,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBSampleModelData(')
          ..write('privateId: $privateId, ')
          ..write('id: $id, ')
          ..write('sampleDate: $sampleDate, ')
          ..write('locationPlot: $locationPlot, ')
          ..write('cultivation: $cultivation, ')
          ..write('treatment: $treatment, ')
          ..write('crop: $crop, ')
          ..write('variety: $variety, ')
          ..write('grower: $grower, ')
          ..write('notes: $notes, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('youngSamplesProvided: $youngSamplesProvided, ')
          ..write('oldSamplesProvided: $oldSamplesProvided')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      privateId,
      id,
      sampleDate,
      locationPlot,
      cultivation,
      treatment,
      crop,
      variety,
      grower,
      notes,
      latitude,
      longitude,
      youngSamplesProvided,
      oldSamplesProvided);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBSampleModelData &&
          other.privateId == this.privateId &&
          other.id == this.id &&
          other.sampleDate == this.sampleDate &&
          other.locationPlot == this.locationPlot &&
          other.cultivation == this.cultivation &&
          other.treatment == this.treatment &&
          other.crop == this.crop &&
          other.variety == this.variety &&
          other.grower == this.grower &&
          other.notes == this.notes &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.youngSamplesProvided == this.youngSamplesProvided &&
          other.oldSamplesProvided == this.oldSamplesProvided);
}

class DBSampleModelCompanion extends UpdateCompanion<DBSampleModelData> {
  final Value<int> privateId;
  final Value<String> id;
  final Value<DateTime?> sampleDate;
  final Value<String> locationPlot;
  final Value<String> cultivation;
  final Value<String> treatment;
  final Value<String> crop;
  final Value<String?> variety;
  final Value<String> grower;
  final Value<String> notes;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<bool> youngSamplesProvided;
  final Value<bool> oldSamplesProvided;
  const DBSampleModelCompanion({
    this.privateId = const Value.absent(),
    this.id = const Value.absent(),
    this.sampleDate = const Value.absent(),
    this.locationPlot = const Value.absent(),
    this.cultivation = const Value.absent(),
    this.treatment = const Value.absent(),
    this.crop = const Value.absent(),
    this.variety = const Value.absent(),
    this.grower = const Value.absent(),
    this.notes = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.youngSamplesProvided = const Value.absent(),
    this.oldSamplesProvided = const Value.absent(),
  });
  DBSampleModelCompanion.insert({
    this.privateId = const Value.absent(),
    required String id,
    this.sampleDate = const Value.absent(),
    required String locationPlot,
    required String cultivation,
    required String treatment,
    required String crop,
    this.variety = const Value.absent(),
    required String grower,
    required String notes,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required bool youngSamplesProvided,
    required bool oldSamplesProvided,
  })  : id = Value(id),
        locationPlot = Value(locationPlot),
        cultivation = Value(cultivation),
        treatment = Value(treatment),
        crop = Value(crop),
        grower = Value(grower),
        notes = Value(notes),
        youngSamplesProvided = Value(youngSamplesProvided),
        oldSamplesProvided = Value(oldSamplesProvided);
  static Insertable<DBSampleModelData> custom({
    Expression<int>? privateId,
    Expression<String>? id,
    Expression<DateTime>? sampleDate,
    Expression<String>? locationPlot,
    Expression<String>? cultivation,
    Expression<String>? treatment,
    Expression<String>? crop,
    Expression<String>? variety,
    Expression<String>? grower,
    Expression<String>? notes,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<bool>? youngSamplesProvided,
    Expression<bool>? oldSamplesProvided,
  }) {
    return RawValuesInsertable({
      if (privateId != null) 'private_id': privateId,
      if (id != null) 'id': id,
      if (sampleDate != null) 'sample_date': sampleDate,
      if (locationPlot != null) 'location_plot': locationPlot,
      if (cultivation != null) 'cultivation': cultivation,
      if (treatment != null) 'treatment': treatment,
      if (crop != null) 'crop': crop,
      if (variety != null) 'variety': variety,
      if (grower != null) 'grower': grower,
      if (notes != null) 'notes': notes,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (youngSamplesProvided != null)
        'young_samples_provided': youngSamplesProvided,
      if (oldSamplesProvided != null)
        'old_samples_provided': oldSamplesProvided,
    });
  }

  DBSampleModelCompanion copyWith(
      {Value<int>? privateId,
      Value<String>? id,
      Value<DateTime?>? sampleDate,
      Value<String>? locationPlot,
      Value<String>? cultivation,
      Value<String>? treatment,
      Value<String>? crop,
      Value<String?>? variety,
      Value<String>? grower,
      Value<String>? notes,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<bool>? youngSamplesProvided,
      Value<bool>? oldSamplesProvided}) {
    return DBSampleModelCompanion(
      privateId: privateId ?? this.privateId,
      id: id ?? this.id,
      sampleDate: sampleDate ?? this.sampleDate,
      locationPlot: locationPlot ?? this.locationPlot,
      cultivation: cultivation ?? this.cultivation,
      treatment: treatment ?? this.treatment,
      crop: crop ?? this.crop,
      variety: variety ?? this.variety,
      grower: grower ?? this.grower,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      youngSamplesProvided: youngSamplesProvided ?? this.youngSamplesProvided,
      oldSamplesProvided: oldSamplesProvided ?? this.oldSamplesProvided,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (privateId.present) {
      map['private_id'] = Variable<int>(privateId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sampleDate.present) {
      map['sample_date'] = Variable<DateTime>(sampleDate.value);
    }
    if (locationPlot.present) {
      map['location_plot'] = Variable<String>(locationPlot.value);
    }
    if (cultivation.present) {
      map['cultivation'] = Variable<String>(cultivation.value);
    }
    if (treatment.present) {
      map['treatment'] = Variable<String>(treatment.value);
    }
    if (crop.present) {
      map['crop'] = Variable<String>(crop.value);
    }
    if (variety.present) {
      map['variety'] = Variable<String>(variety.value);
    }
    if (grower.present) {
      map['grower'] = Variable<String>(grower.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (youngSamplesProvided.present) {
      map['young_samples_provided'] =
          Variable<bool>(youngSamplesProvided.value);
    }
    if (oldSamplesProvided.present) {
      map['old_samples_provided'] = Variable<bool>(oldSamplesProvided.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DBSampleModelCompanion(')
          ..write('privateId: $privateId, ')
          ..write('id: $id, ')
          ..write('sampleDate: $sampleDate, ')
          ..write('locationPlot: $locationPlot, ')
          ..write('cultivation: $cultivation, ')
          ..write('treatment: $treatment, ')
          ..write('crop: $crop, ')
          ..write('variety: $variety, ')
          ..write('grower: $grower, ')
          ..write('notes: $notes, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('youngSamplesProvided: $youngSamplesProvided, ')
          ..write('oldSamplesProvided: $oldSamplesProvided')
          ..write(')'))
        .toString();
  }
}

class $DBCurrentCompanyTable extends DBCurrentCompany
    with TableInfo<$DBCurrentCompanyTable, DBCurrentCompanyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DBCurrentCompanyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'd_b_current_company';
  @override
  VerificationContext validateIntegrity(
      Insertable<DBCurrentCompanyData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBCurrentCompanyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBCurrentCompanyData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
    );
  }

  @override
  $DBCurrentCompanyTable createAlias(String alias) {
    return $DBCurrentCompanyTable(attachedDatabase, alias);
  }
}

class DBCurrentCompanyData extends DataClass
    implements Insertable<DBCurrentCompanyData> {
  final String id;
  const DBCurrentCompanyData({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    return map;
  }

  DBCurrentCompanyCompanion toCompanion(bool nullToAbsent) {
    return DBCurrentCompanyCompanion(
      id: Value(id),
    );
  }

  factory DBCurrentCompanyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBCurrentCompanyData(
      id: serializer.fromJson<String>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
    };
  }

  DBCurrentCompanyData copyWith({String? id}) => DBCurrentCompanyData(
        id: id ?? this.id,
      );
  DBCurrentCompanyData copyWithCompanion(DBCurrentCompanyCompanion data) {
    return DBCurrentCompanyData(
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBCurrentCompanyData(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBCurrentCompanyData && other.id == this.id);
}

class DBCurrentCompanyCompanion extends UpdateCompanion<DBCurrentCompanyData> {
  final Value<String> id;
  final Value<int> rowid;
  const DBCurrentCompanyCompanion({
    this.id = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DBCurrentCompanyCompanion.insert({
    required String id,
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DBCurrentCompanyData> custom({
    Expression<String>? id,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DBCurrentCompanyCompanion copyWith({Value<String>? id, Value<int>? rowid}) {
    return DBCurrentCompanyCompanion(
      id: id ?? this.id,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DBCurrentCompanyCompanion(')
          ..write('id: $id, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DBSampleModelTable dBSampleModel = $DBSampleModelTable(this);
  late final $DBCurrentCompanyTable dBCurrentCompany =
      $DBCurrentCompanyTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [dBSampleModel, dBCurrentCompany];
}

typedef $$DBSampleModelTableCreateCompanionBuilder = DBSampleModelCompanion
    Function({
  Value<int> privateId,
  required String id,
  Value<DateTime?> sampleDate,
  required String locationPlot,
  required String cultivation,
  required String treatment,
  required String crop,
  Value<String?> variety,
  required String grower,
  required String notes,
  Value<double?> latitude,
  Value<double?> longitude,
  required bool youngSamplesProvided,
  required bool oldSamplesProvided,
});
typedef $$DBSampleModelTableUpdateCompanionBuilder = DBSampleModelCompanion
    Function({
  Value<int> privateId,
  Value<String> id,
  Value<DateTime?> sampleDate,
  Value<String> locationPlot,
  Value<String> cultivation,
  Value<String> treatment,
  Value<String> crop,
  Value<String?> variety,
  Value<String> grower,
  Value<String> notes,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<bool> youngSamplesProvided,
  Value<bool> oldSamplesProvided,
});

class $$DBSampleModelTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DBSampleModelTable,
    DBSampleModelData,
    $$DBSampleModelTableFilterComposer,
    $$DBSampleModelTableOrderingComposer,
    $$DBSampleModelTableCreateCompanionBuilder,
    $$DBSampleModelTableUpdateCompanionBuilder> {
  $$DBSampleModelTableTableManager(_$AppDatabase db, $DBSampleModelTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DBSampleModelTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DBSampleModelTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> privateId = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<DateTime?> sampleDate = const Value.absent(),
            Value<String> locationPlot = const Value.absent(),
            Value<String> cultivation = const Value.absent(),
            Value<String> treatment = const Value.absent(),
            Value<String> crop = const Value.absent(),
            Value<String?> variety = const Value.absent(),
            Value<String> grower = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<bool> youngSamplesProvided = const Value.absent(),
            Value<bool> oldSamplesProvided = const Value.absent(),
          }) =>
              DBSampleModelCompanion(
            privateId: privateId,
            id: id,
            sampleDate: sampleDate,
            locationPlot: locationPlot,
            cultivation: cultivation,
            treatment: treatment,
            crop: crop,
            variety: variety,
            grower: grower,
            notes: notes,
            latitude: latitude,
            longitude: longitude,
            youngSamplesProvided: youngSamplesProvided,
            oldSamplesProvided: oldSamplesProvided,
          ),
          createCompanionCallback: ({
            Value<int> privateId = const Value.absent(),
            required String id,
            Value<DateTime?> sampleDate = const Value.absent(),
            required String locationPlot,
            required String cultivation,
            required String treatment,
            required String crop,
            Value<String?> variety = const Value.absent(),
            required String grower,
            required String notes,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            required bool youngSamplesProvided,
            required bool oldSamplesProvided,
          }) =>
              DBSampleModelCompanion.insert(
            privateId: privateId,
            id: id,
            sampleDate: sampleDate,
            locationPlot: locationPlot,
            cultivation: cultivation,
            treatment: treatment,
            crop: crop,
            variety: variety,
            grower: grower,
            notes: notes,
            latitude: latitude,
            longitude: longitude,
            youngSamplesProvided: youngSamplesProvided,
            oldSamplesProvided: oldSamplesProvided,
          ),
        ));
}

class $$DBSampleModelTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DBSampleModelTable> {
  $$DBSampleModelTableFilterComposer(super.$state);
  ColumnFilters<int> get privateId => $state.composableBuilder(
      column: $state.table.privateId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get sampleDate => $state.composableBuilder(
      column: $state.table.sampleDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get locationPlot => $state.composableBuilder(
      column: $state.table.locationPlot,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cultivation => $state.composableBuilder(
      column: $state.table.cultivation,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get treatment => $state.composableBuilder(
      column: $state.table.treatment,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get crop => $state.composableBuilder(
      column: $state.table.crop,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get variety => $state.composableBuilder(
      column: $state.table.variety,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get grower => $state.composableBuilder(
      column: $state.table.grower,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get youngSamplesProvided => $state.composableBuilder(
      column: $state.table.youngSamplesProvided,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get oldSamplesProvided => $state.composableBuilder(
      column: $state.table.oldSamplesProvided,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DBSampleModelTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DBSampleModelTable> {
  $$DBSampleModelTableOrderingComposer(super.$state);
  ColumnOrderings<int> get privateId => $state.composableBuilder(
      column: $state.table.privateId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get sampleDate => $state.composableBuilder(
      column: $state.table.sampleDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get locationPlot => $state.composableBuilder(
      column: $state.table.locationPlot,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cultivation => $state.composableBuilder(
      column: $state.table.cultivation,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get treatment => $state.composableBuilder(
      column: $state.table.treatment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get crop => $state.composableBuilder(
      column: $state.table.crop,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get variety => $state.composableBuilder(
      column: $state.table.variety,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get grower => $state.composableBuilder(
      column: $state.table.grower,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get youngSamplesProvided => $state.composableBuilder(
      column: $state.table.youngSamplesProvided,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get oldSamplesProvided => $state.composableBuilder(
      column: $state.table.oldSamplesProvided,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DBCurrentCompanyTableCreateCompanionBuilder
    = DBCurrentCompanyCompanion Function({
  required String id,
  Value<int> rowid,
});
typedef $$DBCurrentCompanyTableUpdateCompanionBuilder
    = DBCurrentCompanyCompanion Function({
  Value<String> id,
  Value<int> rowid,
});

class $$DBCurrentCompanyTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DBCurrentCompanyTable,
    DBCurrentCompanyData,
    $$DBCurrentCompanyTableFilterComposer,
    $$DBCurrentCompanyTableOrderingComposer,
    $$DBCurrentCompanyTableCreateCompanionBuilder,
    $$DBCurrentCompanyTableUpdateCompanionBuilder> {
  $$DBCurrentCompanyTableTableManager(
      _$AppDatabase db, $DBCurrentCompanyTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DBCurrentCompanyTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DBCurrentCompanyTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DBCurrentCompanyCompanion(
            id: id,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<int> rowid = const Value.absent(),
          }) =>
              DBCurrentCompanyCompanion.insert(
            id: id,
            rowid: rowid,
          ),
        ));
}

class $$DBCurrentCompanyTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DBCurrentCompanyTable> {
  $$DBCurrentCompanyTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DBCurrentCompanyTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DBCurrentCompanyTable> {
  $$DBCurrentCompanyTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DBSampleModelTableTableManager get dBSampleModel =>
      $$DBSampleModelTableTableManager(_db, _db.dBSampleModel);
  $$DBCurrentCompanyTableTableManager get dBCurrentCompany =>
      $$DBCurrentCompanyTableTableManager(_db, _db.dBCurrentCompany);
}
