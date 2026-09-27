// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AvatarsTable extends Avatars with TableInfo<$AvatarsTable, AvatarRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AvatarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _avatarIdMeta =
      const VerificationMeta('avatarId');
  @override
  late final GeneratedColumn<String> avatarId = GeneratedColumn<String>(
      'avatar_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetPathMeta =
      const VerificationMeta('assetPath');
  @override
  late final GeneratedColumn<String> assetPath = GeneratedColumn<String>(
      'asset_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _previewImagePathMeta =
      const VerificationMeta('previewImagePath');
  @override
  late final GeneratedColumn<String> previewImagePath = GeneratedColumn<String>(
      'preview_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultScaleMeta =
      const VerificationMeta('defaultScale');
  @override
  late final GeneratedColumn<double> defaultScale = GeneratedColumn<double>(
      'default_scale', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _assetVersionMeta =
      const VerificationMeta('assetVersion');
  @override
  late final GeneratedColumn<int> assetVersion = GeneratedColumn<int>(
      'asset_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        avatarId,
        displayName,
        assetPath,
        previewImagePath,
        defaultScale,
        assetVersion,
        isEnabled,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'avatars';
  @override
  VerificationContext validateIntegrity(Insertable<AvatarRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('avatar_id')) {
      context.handle(_avatarIdMeta,
          avatarId.isAcceptableOrUnknown(data['avatar_id']!, _avatarIdMeta));
    } else if (isInserting) {
      context.missing(_avatarIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('asset_path')) {
      context.handle(_assetPathMeta,
          assetPath.isAcceptableOrUnknown(data['asset_path']!, _assetPathMeta));
    }
    if (data.containsKey('preview_image_path')) {
      context.handle(
          _previewImagePathMeta,
          previewImagePath.isAcceptableOrUnknown(
              data['preview_image_path']!, _previewImagePathMeta));
    }
    if (data.containsKey('default_scale')) {
      context.handle(
          _defaultScaleMeta,
          defaultScale.isAcceptableOrUnknown(
              data['default_scale']!, _defaultScaleMeta));
    }
    if (data.containsKey('asset_version')) {
      context.handle(
          _assetVersionMeta,
          assetVersion.isAcceptableOrUnknown(
              data['asset_version']!, _assetVersionMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {avatarId};
  @override
  AvatarRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AvatarRow(
      avatarId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      assetPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_path']),
      previewImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preview_image_path']),
      defaultScale: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}default_scale'])!,
      assetVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}asset_version'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $AvatarsTable createAlias(String alias) {
    return $AvatarsTable(attachedDatabase, alias);
  }
}

class AvatarRow extends DataClass implements Insertable<AvatarRow> {
  final String avatarId;
  final String displayName;
  final String? assetPath;
  final String? previewImagePath;
  final double defaultScale;
  final int assetVersion;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const AvatarRow(
      {required this.avatarId,
      required this.displayName,
      this.assetPath,
      this.previewImagePath,
      required this.defaultScale,
      required this.assetVersion,
      required this.isEnabled,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['avatar_id'] = Variable<String>(avatarId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || assetPath != null) {
      map['asset_path'] = Variable<String>(assetPath);
    }
    if (!nullToAbsent || previewImagePath != null) {
      map['preview_image_path'] = Variable<String>(previewImagePath);
    }
    map['default_scale'] = Variable<double>(defaultScale);
    map['asset_version'] = Variable<int>(assetVersion);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AvatarsCompanion toCompanion(bool nullToAbsent) {
    return AvatarsCompanion(
      avatarId: Value(avatarId),
      displayName: Value(displayName),
      assetPath: assetPath == null && nullToAbsent
          ? const Value.absent()
          : Value(assetPath),
      previewImagePath: previewImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(previewImagePath),
      defaultScale: Value(defaultScale),
      assetVersion: Value(assetVersion),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory AvatarRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AvatarRow(
      avatarId: serializer.fromJson<String>(json['avatarId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      assetPath: serializer.fromJson<String?>(json['assetPath']),
      previewImagePath: serializer.fromJson<String?>(json['previewImagePath']),
      defaultScale: serializer.fromJson<double>(json['defaultScale']),
      assetVersion: serializer.fromJson<int>(json['assetVersion']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'avatarId': serializer.toJson<String>(avatarId),
      'displayName': serializer.toJson<String>(displayName),
      'assetPath': serializer.toJson<String?>(assetPath),
      'previewImagePath': serializer.toJson<String?>(previewImagePath),
      'defaultScale': serializer.toJson<double>(defaultScale),
      'assetVersion': serializer.toJson<int>(assetVersion),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  AvatarRow copyWith(
          {String? avatarId,
          String? displayName,
          Value<String?> assetPath = const Value.absent(),
          Value<String?> previewImagePath = const Value.absent(),
          double? defaultScale,
          int? assetVersion,
          bool? isEnabled,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      AvatarRow(
        avatarId: avatarId ?? this.avatarId,
        displayName: displayName ?? this.displayName,
        assetPath: assetPath.present ? assetPath.value : this.assetPath,
        previewImagePath: previewImagePath.present
            ? previewImagePath.value
            : this.previewImagePath,
        defaultScale: defaultScale ?? this.defaultScale,
        assetVersion: assetVersion ?? this.assetVersion,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  AvatarRow copyWithCompanion(AvatarsCompanion data) {
    return AvatarRow(
      avatarId: data.avatarId.present ? data.avatarId.value : this.avatarId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      assetPath: data.assetPath.present ? data.assetPath.value : this.assetPath,
      previewImagePath: data.previewImagePath.present
          ? data.previewImagePath.value
          : this.previewImagePath,
      defaultScale: data.defaultScale.present
          ? data.defaultScale.value
          : this.defaultScale,
      assetVersion: data.assetVersion.present
          ? data.assetVersion.value
          : this.assetVersion,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AvatarRow(')
          ..write('avatarId: $avatarId, ')
          ..write('displayName: $displayName, ')
          ..write('assetPath: $assetPath, ')
          ..write('previewImagePath: $previewImagePath, ')
          ..write('defaultScale: $defaultScale, ')
          ..write('assetVersion: $assetVersion, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      avatarId,
      displayName,
      assetPath,
      previewImagePath,
      defaultScale,
      assetVersion,
      isEnabled,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AvatarRow &&
          other.avatarId == this.avatarId &&
          other.displayName == this.displayName &&
          other.assetPath == this.assetPath &&
          other.previewImagePath == this.previewImagePath &&
          other.defaultScale == this.defaultScale &&
          other.assetVersion == this.assetVersion &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AvatarsCompanion extends UpdateCompanion<AvatarRow> {
  final Value<String> avatarId;
  final Value<String> displayName;
  final Value<String?> assetPath;
  final Value<String?> previewImagePath;
  final Value<double> defaultScale;
  final Value<int> assetVersion;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const AvatarsCompanion({
    this.avatarId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.assetPath = const Value.absent(),
    this.previewImagePath = const Value.absent(),
    this.defaultScale = const Value.absent(),
    this.assetVersion = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AvatarsCompanion.insert({
    required String avatarId,
    required String displayName,
    this.assetPath = const Value.absent(),
    this.previewImagePath = const Value.absent(),
    this.defaultScale = const Value.absent(),
    this.assetVersion = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : avatarId = Value(avatarId),
        displayName = Value(displayName),
        createdAt = Value(createdAt);
  static Insertable<AvatarRow> custom({
    Expression<String>? avatarId,
    Expression<String>? displayName,
    Expression<String>? assetPath,
    Expression<String>? previewImagePath,
    Expression<double>? defaultScale,
    Expression<int>? assetVersion,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (avatarId != null) 'avatar_id': avatarId,
      if (displayName != null) 'display_name': displayName,
      if (assetPath != null) 'asset_path': assetPath,
      if (previewImagePath != null) 'preview_image_path': previewImagePath,
      if (defaultScale != null) 'default_scale': defaultScale,
      if (assetVersion != null) 'asset_version': assetVersion,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AvatarsCompanion copyWith(
      {Value<String>? avatarId,
      Value<String>? displayName,
      Value<String?>? assetPath,
      Value<String?>? previewImagePath,
      Value<double>? defaultScale,
      Value<int>? assetVersion,
      Value<bool>? isEnabled,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return AvatarsCompanion(
      avatarId: avatarId ?? this.avatarId,
      displayName: displayName ?? this.displayName,
      assetPath: assetPath ?? this.assetPath,
      previewImagePath: previewImagePath ?? this.previewImagePath,
      defaultScale: defaultScale ?? this.defaultScale,
      assetVersion: assetVersion ?? this.assetVersion,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (avatarId.present) {
      map['avatar_id'] = Variable<String>(avatarId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (assetPath.present) {
      map['asset_path'] = Variable<String>(assetPath.value);
    }
    if (previewImagePath.present) {
      map['preview_image_path'] = Variable<String>(previewImagePath.value);
    }
    if (defaultScale.present) {
      map['default_scale'] = Variable<double>(defaultScale.value);
    }
    if (assetVersion.present) {
      map['asset_version'] = Variable<int>(assetVersion.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('AvatarsCompanion(')
          ..write('avatarId: $avatarId, ')
          ..write('displayName: $displayName, ')
          ..write('assetPath: $assetPath, ')
          ..write('previewImagePath: $previewImagePath, ')
          ..write('defaultScale: $defaultScale, ')
          ..write('assetVersion: $assetVersion, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, RoomRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetPathMeta =
      const VerificationMeta('assetPath');
  @override
  late final GeneratedColumn<String> assetPath = GeneratedColumn<String>(
      'asset_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previewImagePathMeta =
      const VerificationMeta('previewImagePath');
  @override
  late final GeneratedColumn<String> previewImagePath = GeneratedColumn<String>(
      'preview_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _assetVersionMeta =
      const VerificationMeta('assetVersion');
  @override
  late final GeneratedColumn<int> assetVersion = GeneratedColumn<int>(
      'asset_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _defaultAvatarIdMeta =
      const VerificationMeta('defaultAvatarId');
  @override
  late final GeneratedColumn<String> defaultAvatarId = GeneratedColumn<String>(
      'default_avatar_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES avatars (avatar_id) ON DELETE SET NULL'));
  static const VerificationMeta _cameraAzimuthMeta =
      const VerificationMeta('cameraAzimuth');
  @override
  late final GeneratedColumn<double> cameraAzimuth = GeneratedColumn<double>(
      'camera_azimuth', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.70));
  static const VerificationMeta _cameraElevationMeta =
      const VerificationMeta('cameraElevation');
  @override
  late final GeneratedColumn<double> cameraElevation = GeneratedColumn<double>(
      'camera_elevation', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.63));
  static const VerificationMeta _cameraDistanceMeta =
      const VerificationMeta('cameraDistance');
  @override
  late final GeneratedColumn<double> cameraDistance = GeneratedColumn<double>(
      'camera_distance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(12.0));
  static const VerificationMeta _orthographicSizeMeta =
      const VerificationMeta('orthographicSize');
  @override
  late final GeneratedColumn<double> orthographicSize = GeneratedColumn<double>(
      'orthographic_size', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(4.7));
  static const VerificationMeta _targetXMeta =
      const VerificationMeta('targetX');
  @override
  late final GeneratedColumn<double> targetX = GeneratedColumn<double>(
      'target_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _targetYMeta =
      const VerificationMeta('targetY');
  @override
  late final GeneratedColumn<double> targetY = GeneratedColumn<double>(
      'target_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.25));
  static const VerificationMeta _targetZMeta =
      const VerificationMeta('targetZ');
  @override
  late final GeneratedColumn<double> targetZ = GeneratedColumn<double>(
      'target_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _floorYMeta = const VerificationMeta('floorY');
  @override
  late final GeneratedColumn<double> floorY = GeneratedColumn<double>(
      'floor_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _gridOriginXMeta =
      const VerificationMeta('gridOriginX');
  @override
  late final GeneratedColumn<double> gridOriginX = GeneratedColumn<double>(
      'grid_origin_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(-3.0));
  static const VerificationMeta _gridOriginYMeta =
      const VerificationMeta('gridOriginY');
  @override
  late final GeneratedColumn<double> gridOriginY = GeneratedColumn<double>(
      'grid_origin_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _gridOriginZMeta =
      const VerificationMeta('gridOriginZ');
  @override
  late final GeneratedColumn<double> gridOriginZ = GeneratedColumn<double>(
      'grid_origin_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(-2.65));
  static const VerificationMeta _cellSizeXMeta =
      const VerificationMeta('cellSizeX');
  @override
  late final GeneratedColumn<double> cellSizeX = GeneratedColumn<double>(
      'cell_size_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.30));
  static const VerificationMeta _cellSizeYMeta =
      const VerificationMeta('cellSizeY');
  @override
  late final GeneratedColumn<double> cellSizeY = GeneratedColumn<double>(
      'cell_size_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.40));
  static const VerificationMeta _cellSizeZMeta =
      const VerificationMeta('cellSizeZ');
  @override
  late final GeneratedColumn<double> cellSizeZ = GeneratedColumn<double>(
      'cell_size_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.265));
  static const VerificationMeta _gridCountXMeta =
      const VerificationMeta('gridCountX');
  @override
  late final GeneratedColumn<int> gridCountX = GeneratedColumn<int>(
      'grid_count_x', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(20));
  static const VerificationMeta _gridCountYMeta =
      const VerificationMeta('gridCountY');
  @override
  late final GeneratedColumn<int> gridCountY = GeneratedColumn<int>(
      'grid_count_y', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(8));
  static const VerificationMeta _gridCountZMeta =
      const VerificationMeta('gridCountZ');
  @override
  late final GeneratedColumn<int> gridCountZ = GeneratedColumn<int>(
      'grid_count_z', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(20));
  static const VerificationMeta _gridVersionMeta =
      const VerificationMeta('gridVersion');
  @override
  late final GeneratedColumn<int> gridVersion = GeneratedColumn<int>(
      'grid_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _walkMinXMeta =
      const VerificationMeta('walkMinX');
  @override
  late final GeneratedColumn<double> walkMinX = GeneratedColumn<double>(
      'walk_min_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(-2.35));
  static const VerificationMeta _walkMaxXMeta =
      const VerificationMeta('walkMaxX');
  @override
  late final GeneratedColumn<double> walkMaxX = GeneratedColumn<double>(
      'walk_max_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.35));
  static const VerificationMeta _walkMinZMeta =
      const VerificationMeta('walkMinZ');
  @override
  late final GeneratedColumn<double> walkMinZ = GeneratedColumn<double>(
      'walk_min_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(-1.95));
  static const VerificationMeta _walkMaxZMeta =
      const VerificationMeta('walkMaxZ');
  @override
  late final GeneratedColumn<double> walkMaxZ = GeneratedColumn<double>(
      'walk_max_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.95));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        roomId,
        name,
        assetPath,
        previewImagePath,
        isEnabled,
        displayOrder,
        assetVersion,
        defaultAvatarId,
        cameraAzimuth,
        cameraElevation,
        cameraDistance,
        orthographicSize,
        targetX,
        targetY,
        targetZ,
        floorY,
        gridOriginX,
        gridOriginY,
        gridOriginZ,
        cellSizeX,
        cellSizeY,
        cellSizeZ,
        gridCountX,
        gridCountY,
        gridCountZ,
        gridVersion,
        walkMinX,
        walkMaxX,
        walkMinZ,
        walkMaxZ,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(Insertable<RoomRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('asset_path')) {
      context.handle(_assetPathMeta,
          assetPath.isAcceptableOrUnknown(data['asset_path']!, _assetPathMeta));
    } else if (isInserting) {
      context.missing(_assetPathMeta);
    }
    if (data.containsKey('preview_image_path')) {
      context.handle(
          _previewImagePathMeta,
          previewImagePath.isAcceptableOrUnknown(
              data['preview_image_path']!, _previewImagePathMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    if (data.containsKey('asset_version')) {
      context.handle(
          _assetVersionMeta,
          assetVersion.isAcceptableOrUnknown(
              data['asset_version']!, _assetVersionMeta));
    }
    if (data.containsKey('default_avatar_id')) {
      context.handle(
          _defaultAvatarIdMeta,
          defaultAvatarId.isAcceptableOrUnknown(
              data['default_avatar_id']!, _defaultAvatarIdMeta));
    }
    if (data.containsKey('camera_azimuth')) {
      context.handle(
          _cameraAzimuthMeta,
          cameraAzimuth.isAcceptableOrUnknown(
              data['camera_azimuth']!, _cameraAzimuthMeta));
    }
    if (data.containsKey('camera_elevation')) {
      context.handle(
          _cameraElevationMeta,
          cameraElevation.isAcceptableOrUnknown(
              data['camera_elevation']!, _cameraElevationMeta));
    }
    if (data.containsKey('camera_distance')) {
      context.handle(
          _cameraDistanceMeta,
          cameraDistance.isAcceptableOrUnknown(
              data['camera_distance']!, _cameraDistanceMeta));
    }
    if (data.containsKey('orthographic_size')) {
      context.handle(
          _orthographicSizeMeta,
          orthographicSize.isAcceptableOrUnknown(
              data['orthographic_size']!, _orthographicSizeMeta));
    }
    if (data.containsKey('target_x')) {
      context.handle(_targetXMeta,
          targetX.isAcceptableOrUnknown(data['target_x']!, _targetXMeta));
    }
    if (data.containsKey('target_y')) {
      context.handle(_targetYMeta,
          targetY.isAcceptableOrUnknown(data['target_y']!, _targetYMeta));
    }
    if (data.containsKey('target_z')) {
      context.handle(_targetZMeta,
          targetZ.isAcceptableOrUnknown(data['target_z']!, _targetZMeta));
    }
    if (data.containsKey('floor_y')) {
      context.handle(_floorYMeta,
          floorY.isAcceptableOrUnknown(data['floor_y']!, _floorYMeta));
    }
    if (data.containsKey('grid_origin_x')) {
      context.handle(
          _gridOriginXMeta,
          gridOriginX.isAcceptableOrUnknown(
              data['grid_origin_x']!, _gridOriginXMeta));
    }
    if (data.containsKey('grid_origin_y')) {
      context.handle(
          _gridOriginYMeta,
          gridOriginY.isAcceptableOrUnknown(
              data['grid_origin_y']!, _gridOriginYMeta));
    }
    if (data.containsKey('grid_origin_z')) {
      context.handle(
          _gridOriginZMeta,
          gridOriginZ.isAcceptableOrUnknown(
              data['grid_origin_z']!, _gridOriginZMeta));
    }
    if (data.containsKey('cell_size_x')) {
      context.handle(
          _cellSizeXMeta,
          cellSizeX.isAcceptableOrUnknown(
              data['cell_size_x']!, _cellSizeXMeta));
    }
    if (data.containsKey('cell_size_y')) {
      context.handle(
          _cellSizeYMeta,
          cellSizeY.isAcceptableOrUnknown(
              data['cell_size_y']!, _cellSizeYMeta));
    }
    if (data.containsKey('cell_size_z')) {
      context.handle(
          _cellSizeZMeta,
          cellSizeZ.isAcceptableOrUnknown(
              data['cell_size_z']!, _cellSizeZMeta));
    }
    if (data.containsKey('grid_count_x')) {
      context.handle(
          _gridCountXMeta,
          gridCountX.isAcceptableOrUnknown(
              data['grid_count_x']!, _gridCountXMeta));
    }
    if (data.containsKey('grid_count_y')) {
      context.handle(
          _gridCountYMeta,
          gridCountY.isAcceptableOrUnknown(
              data['grid_count_y']!, _gridCountYMeta));
    }
    if (data.containsKey('grid_count_z')) {
      context.handle(
          _gridCountZMeta,
          gridCountZ.isAcceptableOrUnknown(
              data['grid_count_z']!, _gridCountZMeta));
    }
    if (data.containsKey('grid_version')) {
      context.handle(
          _gridVersionMeta,
          gridVersion.isAcceptableOrUnknown(
              data['grid_version']!, _gridVersionMeta));
    }
    if (data.containsKey('walk_min_x')) {
      context.handle(_walkMinXMeta,
          walkMinX.isAcceptableOrUnknown(data['walk_min_x']!, _walkMinXMeta));
    }
    if (data.containsKey('walk_max_x')) {
      context.handle(_walkMaxXMeta,
          walkMaxX.isAcceptableOrUnknown(data['walk_max_x']!, _walkMaxXMeta));
    }
    if (data.containsKey('walk_min_z')) {
      context.handle(_walkMinZMeta,
          walkMinZ.isAcceptableOrUnknown(data['walk_min_z']!, _walkMinZMeta));
    }
    if (data.containsKey('walk_max_z')) {
      context.handle(_walkMaxZMeta,
          walkMaxZ.isAcceptableOrUnknown(data['walk_max_z']!, _walkMaxZMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId};
  @override
  RoomRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomRow(
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      assetPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_path'])!,
      previewImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preview_image_path']),
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
      assetVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}asset_version'])!,
      defaultAvatarId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_avatar_id']),
      cameraAzimuth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}camera_azimuth'])!,
      cameraElevation: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}camera_elevation'])!,
      cameraDistance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}camera_distance'])!,
      orthographicSize: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}orthographic_size'])!,
      targetX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_x'])!,
      targetY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_y'])!,
      targetZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_z'])!,
      floorY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}floor_y'])!,
      gridOriginX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grid_origin_x'])!,
      gridOriginY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grid_origin_y'])!,
      gridOriginZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grid_origin_z'])!,
      cellSizeX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cell_size_x'])!,
      cellSizeY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cell_size_y'])!,
      cellSizeZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cell_size_z'])!,
      gridCountX: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_count_x'])!,
      gridCountY: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_count_y'])!,
      gridCountZ: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_count_z'])!,
      gridVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_version'])!,
      walkMinX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}walk_min_x'])!,
      walkMaxX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}walk_max_x'])!,
      walkMinZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}walk_min_z'])!,
      walkMaxZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}walk_max_z'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class RoomRow extends DataClass implements Insertable<RoomRow> {
  final String roomId;
  final String name;
  final String assetPath;
  final String? previewImagePath;
  final bool isEnabled;
  final int displayOrder;
  final int assetVersion;
  final String? defaultAvatarId;
  final double cameraAzimuth;
  final double cameraElevation;
  final double cameraDistance;
  final double orthographicSize;
  final double targetX;
  final double targetY;
  final double targetZ;
  final double floorY;
  final double gridOriginX;
  final double gridOriginY;
  final double gridOriginZ;
  final double cellSizeX;
  final double cellSizeY;
  final double cellSizeZ;
  final int gridCountX;
  final int gridCountY;
  final int gridCountZ;
  final int gridVersion;
  final double walkMinX;
  final double walkMaxX;
  final double walkMinZ;
  final double walkMaxZ;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RoomRow(
      {required this.roomId,
      required this.name,
      required this.assetPath,
      this.previewImagePath,
      required this.isEnabled,
      required this.displayOrder,
      required this.assetVersion,
      this.defaultAvatarId,
      required this.cameraAzimuth,
      required this.cameraElevation,
      required this.cameraDistance,
      required this.orthographicSize,
      required this.targetX,
      required this.targetY,
      required this.targetZ,
      required this.floorY,
      required this.gridOriginX,
      required this.gridOriginY,
      required this.gridOriginZ,
      required this.cellSizeX,
      required this.cellSizeY,
      required this.cellSizeZ,
      required this.gridCountX,
      required this.gridCountY,
      required this.gridCountZ,
      required this.gridVersion,
      required this.walkMinX,
      required this.walkMaxX,
      required this.walkMinZ,
      required this.walkMaxZ,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['room_id'] = Variable<String>(roomId);
    map['name'] = Variable<String>(name);
    map['asset_path'] = Variable<String>(assetPath);
    if (!nullToAbsent || previewImagePath != null) {
      map['preview_image_path'] = Variable<String>(previewImagePath);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['display_order'] = Variable<int>(displayOrder);
    map['asset_version'] = Variable<int>(assetVersion);
    if (!nullToAbsent || defaultAvatarId != null) {
      map['default_avatar_id'] = Variable<String>(defaultAvatarId);
    }
    map['camera_azimuth'] = Variable<double>(cameraAzimuth);
    map['camera_elevation'] = Variable<double>(cameraElevation);
    map['camera_distance'] = Variable<double>(cameraDistance);
    map['orthographic_size'] = Variable<double>(orthographicSize);
    map['target_x'] = Variable<double>(targetX);
    map['target_y'] = Variable<double>(targetY);
    map['target_z'] = Variable<double>(targetZ);
    map['floor_y'] = Variable<double>(floorY);
    map['grid_origin_x'] = Variable<double>(gridOriginX);
    map['grid_origin_y'] = Variable<double>(gridOriginY);
    map['grid_origin_z'] = Variable<double>(gridOriginZ);
    map['cell_size_x'] = Variable<double>(cellSizeX);
    map['cell_size_y'] = Variable<double>(cellSizeY);
    map['cell_size_z'] = Variable<double>(cellSizeZ);
    map['grid_count_x'] = Variable<int>(gridCountX);
    map['grid_count_y'] = Variable<int>(gridCountY);
    map['grid_count_z'] = Variable<int>(gridCountZ);
    map['grid_version'] = Variable<int>(gridVersion);
    map['walk_min_x'] = Variable<double>(walkMinX);
    map['walk_max_x'] = Variable<double>(walkMaxX);
    map['walk_min_z'] = Variable<double>(walkMinZ);
    map['walk_max_z'] = Variable<double>(walkMaxZ);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      roomId: Value(roomId),
      name: Value(name),
      assetPath: Value(assetPath),
      previewImagePath: previewImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(previewImagePath),
      isEnabled: Value(isEnabled),
      displayOrder: Value(displayOrder),
      assetVersion: Value(assetVersion),
      defaultAvatarId: defaultAvatarId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultAvatarId),
      cameraAzimuth: Value(cameraAzimuth),
      cameraElevation: Value(cameraElevation),
      cameraDistance: Value(cameraDistance),
      orthographicSize: Value(orthographicSize),
      targetX: Value(targetX),
      targetY: Value(targetY),
      targetZ: Value(targetZ),
      floorY: Value(floorY),
      gridOriginX: Value(gridOriginX),
      gridOriginY: Value(gridOriginY),
      gridOriginZ: Value(gridOriginZ),
      cellSizeX: Value(cellSizeX),
      cellSizeY: Value(cellSizeY),
      cellSizeZ: Value(cellSizeZ),
      gridCountX: Value(gridCountX),
      gridCountY: Value(gridCountY),
      gridCountZ: Value(gridCountZ),
      gridVersion: Value(gridVersion),
      walkMinX: Value(walkMinX),
      walkMaxX: Value(walkMaxX),
      walkMinZ: Value(walkMinZ),
      walkMaxZ: Value(walkMaxZ),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoomRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomRow(
      roomId: serializer.fromJson<String>(json['roomId']),
      name: serializer.fromJson<String>(json['name']),
      assetPath: serializer.fromJson<String>(json['assetPath']),
      previewImagePath: serializer.fromJson<String?>(json['previewImagePath']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      assetVersion: serializer.fromJson<int>(json['assetVersion']),
      defaultAvatarId: serializer.fromJson<String?>(json['defaultAvatarId']),
      cameraAzimuth: serializer.fromJson<double>(json['cameraAzimuth']),
      cameraElevation: serializer.fromJson<double>(json['cameraElevation']),
      cameraDistance: serializer.fromJson<double>(json['cameraDistance']),
      orthographicSize: serializer.fromJson<double>(json['orthographicSize']),
      targetX: serializer.fromJson<double>(json['targetX']),
      targetY: serializer.fromJson<double>(json['targetY']),
      targetZ: serializer.fromJson<double>(json['targetZ']),
      floorY: serializer.fromJson<double>(json['floorY']),
      gridOriginX: serializer.fromJson<double>(json['gridOriginX']),
      gridOriginY: serializer.fromJson<double>(json['gridOriginY']),
      gridOriginZ: serializer.fromJson<double>(json['gridOriginZ']),
      cellSizeX: serializer.fromJson<double>(json['cellSizeX']),
      cellSizeY: serializer.fromJson<double>(json['cellSizeY']),
      cellSizeZ: serializer.fromJson<double>(json['cellSizeZ']),
      gridCountX: serializer.fromJson<int>(json['gridCountX']),
      gridCountY: serializer.fromJson<int>(json['gridCountY']),
      gridCountZ: serializer.fromJson<int>(json['gridCountZ']),
      gridVersion: serializer.fromJson<int>(json['gridVersion']),
      walkMinX: serializer.fromJson<double>(json['walkMinX']),
      walkMaxX: serializer.fromJson<double>(json['walkMaxX']),
      walkMinZ: serializer.fromJson<double>(json['walkMinZ']),
      walkMaxZ: serializer.fromJson<double>(json['walkMaxZ']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<String>(roomId),
      'name': serializer.toJson<String>(name),
      'assetPath': serializer.toJson<String>(assetPath),
      'previewImagePath': serializer.toJson<String?>(previewImagePath),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'assetVersion': serializer.toJson<int>(assetVersion),
      'defaultAvatarId': serializer.toJson<String?>(defaultAvatarId),
      'cameraAzimuth': serializer.toJson<double>(cameraAzimuth),
      'cameraElevation': serializer.toJson<double>(cameraElevation),
      'cameraDistance': serializer.toJson<double>(cameraDistance),
      'orthographicSize': serializer.toJson<double>(orthographicSize),
      'targetX': serializer.toJson<double>(targetX),
      'targetY': serializer.toJson<double>(targetY),
      'targetZ': serializer.toJson<double>(targetZ),
      'floorY': serializer.toJson<double>(floorY),
      'gridOriginX': serializer.toJson<double>(gridOriginX),
      'gridOriginY': serializer.toJson<double>(gridOriginY),
      'gridOriginZ': serializer.toJson<double>(gridOriginZ),
      'cellSizeX': serializer.toJson<double>(cellSizeX),
      'cellSizeY': serializer.toJson<double>(cellSizeY),
      'cellSizeZ': serializer.toJson<double>(cellSizeZ),
      'gridCountX': serializer.toJson<int>(gridCountX),
      'gridCountY': serializer.toJson<int>(gridCountY),
      'gridCountZ': serializer.toJson<int>(gridCountZ),
      'gridVersion': serializer.toJson<int>(gridVersion),
      'walkMinX': serializer.toJson<double>(walkMinX),
      'walkMaxX': serializer.toJson<double>(walkMaxX),
      'walkMinZ': serializer.toJson<double>(walkMinZ),
      'walkMaxZ': serializer.toJson<double>(walkMaxZ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RoomRow copyWith(
          {String? roomId,
          String? name,
          String? assetPath,
          Value<String?> previewImagePath = const Value.absent(),
          bool? isEnabled,
          int? displayOrder,
          int? assetVersion,
          Value<String?> defaultAvatarId = const Value.absent(),
          double? cameraAzimuth,
          double? cameraElevation,
          double? cameraDistance,
          double? orthographicSize,
          double? targetX,
          double? targetY,
          double? targetZ,
          double? floorY,
          double? gridOriginX,
          double? gridOriginY,
          double? gridOriginZ,
          double? cellSizeX,
          double? cellSizeY,
          double? cellSizeZ,
          int? gridCountX,
          int? gridCountY,
          int? gridCountZ,
          int? gridVersion,
          double? walkMinX,
          double? walkMaxX,
          double? walkMinZ,
          double? walkMaxZ,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RoomRow(
        roomId: roomId ?? this.roomId,
        name: name ?? this.name,
        assetPath: assetPath ?? this.assetPath,
        previewImagePath: previewImagePath.present
            ? previewImagePath.value
            : this.previewImagePath,
        isEnabled: isEnabled ?? this.isEnabled,
        displayOrder: displayOrder ?? this.displayOrder,
        assetVersion: assetVersion ?? this.assetVersion,
        defaultAvatarId: defaultAvatarId.present
            ? defaultAvatarId.value
            : this.defaultAvatarId,
        cameraAzimuth: cameraAzimuth ?? this.cameraAzimuth,
        cameraElevation: cameraElevation ?? this.cameraElevation,
        cameraDistance: cameraDistance ?? this.cameraDistance,
        orthographicSize: orthographicSize ?? this.orthographicSize,
        targetX: targetX ?? this.targetX,
        targetY: targetY ?? this.targetY,
        targetZ: targetZ ?? this.targetZ,
        floorY: floorY ?? this.floorY,
        gridOriginX: gridOriginX ?? this.gridOriginX,
        gridOriginY: gridOriginY ?? this.gridOriginY,
        gridOriginZ: gridOriginZ ?? this.gridOriginZ,
        cellSizeX: cellSizeX ?? this.cellSizeX,
        cellSizeY: cellSizeY ?? this.cellSizeY,
        cellSizeZ: cellSizeZ ?? this.cellSizeZ,
        gridCountX: gridCountX ?? this.gridCountX,
        gridCountY: gridCountY ?? this.gridCountY,
        gridCountZ: gridCountZ ?? this.gridCountZ,
        gridVersion: gridVersion ?? this.gridVersion,
        walkMinX: walkMinX ?? this.walkMinX,
        walkMaxX: walkMaxX ?? this.walkMaxX,
        walkMinZ: walkMinZ ?? this.walkMinZ,
        walkMaxZ: walkMaxZ ?? this.walkMaxZ,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RoomRow copyWithCompanion(RoomsCompanion data) {
    return RoomRow(
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      name: data.name.present ? data.name.value : this.name,
      assetPath: data.assetPath.present ? data.assetPath.value : this.assetPath,
      previewImagePath: data.previewImagePath.present
          ? data.previewImagePath.value
          : this.previewImagePath,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      assetVersion: data.assetVersion.present
          ? data.assetVersion.value
          : this.assetVersion,
      defaultAvatarId: data.defaultAvatarId.present
          ? data.defaultAvatarId.value
          : this.defaultAvatarId,
      cameraAzimuth: data.cameraAzimuth.present
          ? data.cameraAzimuth.value
          : this.cameraAzimuth,
      cameraElevation: data.cameraElevation.present
          ? data.cameraElevation.value
          : this.cameraElevation,
      cameraDistance: data.cameraDistance.present
          ? data.cameraDistance.value
          : this.cameraDistance,
      orthographicSize: data.orthographicSize.present
          ? data.orthographicSize.value
          : this.orthographicSize,
      targetX: data.targetX.present ? data.targetX.value : this.targetX,
      targetY: data.targetY.present ? data.targetY.value : this.targetY,
      targetZ: data.targetZ.present ? data.targetZ.value : this.targetZ,
      floorY: data.floorY.present ? data.floorY.value : this.floorY,
      gridOriginX:
          data.gridOriginX.present ? data.gridOriginX.value : this.gridOriginX,
      gridOriginY:
          data.gridOriginY.present ? data.gridOriginY.value : this.gridOriginY,
      gridOriginZ:
          data.gridOriginZ.present ? data.gridOriginZ.value : this.gridOriginZ,
      cellSizeX: data.cellSizeX.present ? data.cellSizeX.value : this.cellSizeX,
      cellSizeY: data.cellSizeY.present ? data.cellSizeY.value : this.cellSizeY,
      cellSizeZ: data.cellSizeZ.present ? data.cellSizeZ.value : this.cellSizeZ,
      gridCountX:
          data.gridCountX.present ? data.gridCountX.value : this.gridCountX,
      gridCountY:
          data.gridCountY.present ? data.gridCountY.value : this.gridCountY,
      gridCountZ:
          data.gridCountZ.present ? data.gridCountZ.value : this.gridCountZ,
      gridVersion:
          data.gridVersion.present ? data.gridVersion.value : this.gridVersion,
      walkMinX: data.walkMinX.present ? data.walkMinX.value : this.walkMinX,
      walkMaxX: data.walkMaxX.present ? data.walkMaxX.value : this.walkMaxX,
      walkMinZ: data.walkMinZ.present ? data.walkMinZ.value : this.walkMinZ,
      walkMaxZ: data.walkMaxZ.present ? data.walkMaxZ.value : this.walkMaxZ,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomRow(')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('assetPath: $assetPath, ')
          ..write('previewImagePath: $previewImagePath, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('assetVersion: $assetVersion, ')
          ..write('defaultAvatarId: $defaultAvatarId, ')
          ..write('cameraAzimuth: $cameraAzimuth, ')
          ..write('cameraElevation: $cameraElevation, ')
          ..write('cameraDistance: $cameraDistance, ')
          ..write('orthographicSize: $orthographicSize, ')
          ..write('targetX: $targetX, ')
          ..write('targetY: $targetY, ')
          ..write('targetZ: $targetZ, ')
          ..write('floorY: $floorY, ')
          ..write('gridOriginX: $gridOriginX, ')
          ..write('gridOriginY: $gridOriginY, ')
          ..write('gridOriginZ: $gridOriginZ, ')
          ..write('cellSizeX: $cellSizeX, ')
          ..write('cellSizeY: $cellSizeY, ')
          ..write('cellSizeZ: $cellSizeZ, ')
          ..write('gridCountX: $gridCountX, ')
          ..write('gridCountY: $gridCountY, ')
          ..write('gridCountZ: $gridCountZ, ')
          ..write('gridVersion: $gridVersion, ')
          ..write('walkMinX: $walkMinX, ')
          ..write('walkMaxX: $walkMaxX, ')
          ..write('walkMinZ: $walkMinZ, ')
          ..write('walkMaxZ: $walkMaxZ, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        roomId,
        name,
        assetPath,
        previewImagePath,
        isEnabled,
        displayOrder,
        assetVersion,
        defaultAvatarId,
        cameraAzimuth,
        cameraElevation,
        cameraDistance,
        orthographicSize,
        targetX,
        targetY,
        targetZ,
        floorY,
        gridOriginX,
        gridOriginY,
        gridOriginZ,
        cellSizeX,
        cellSizeY,
        cellSizeZ,
        gridCountX,
        gridCountY,
        gridCountZ,
        gridVersion,
        walkMinX,
        walkMaxX,
        walkMinZ,
        walkMaxZ,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomRow &&
          other.roomId == this.roomId &&
          other.name == this.name &&
          other.assetPath == this.assetPath &&
          other.previewImagePath == this.previewImagePath &&
          other.isEnabled == this.isEnabled &&
          other.displayOrder == this.displayOrder &&
          other.assetVersion == this.assetVersion &&
          other.defaultAvatarId == this.defaultAvatarId &&
          other.cameraAzimuth == this.cameraAzimuth &&
          other.cameraElevation == this.cameraElevation &&
          other.cameraDistance == this.cameraDistance &&
          other.orthographicSize == this.orthographicSize &&
          other.targetX == this.targetX &&
          other.targetY == this.targetY &&
          other.targetZ == this.targetZ &&
          other.floorY == this.floorY &&
          other.gridOriginX == this.gridOriginX &&
          other.gridOriginY == this.gridOriginY &&
          other.gridOriginZ == this.gridOriginZ &&
          other.cellSizeX == this.cellSizeX &&
          other.cellSizeY == this.cellSizeY &&
          other.cellSizeZ == this.cellSizeZ &&
          other.gridCountX == this.gridCountX &&
          other.gridCountY == this.gridCountY &&
          other.gridCountZ == this.gridCountZ &&
          other.gridVersion == this.gridVersion &&
          other.walkMinX == this.walkMinX &&
          other.walkMaxX == this.walkMaxX &&
          other.walkMinZ == this.walkMinZ &&
          other.walkMaxZ == this.walkMaxZ &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoomsCompanion extends UpdateCompanion<RoomRow> {
  final Value<String> roomId;
  final Value<String> name;
  final Value<String> assetPath;
  final Value<String?> previewImagePath;
  final Value<bool> isEnabled;
  final Value<int> displayOrder;
  final Value<int> assetVersion;
  final Value<String?> defaultAvatarId;
  final Value<double> cameraAzimuth;
  final Value<double> cameraElevation;
  final Value<double> cameraDistance;
  final Value<double> orthographicSize;
  final Value<double> targetX;
  final Value<double> targetY;
  final Value<double> targetZ;
  final Value<double> floorY;
  final Value<double> gridOriginX;
  final Value<double> gridOriginY;
  final Value<double> gridOriginZ;
  final Value<double> cellSizeX;
  final Value<double> cellSizeY;
  final Value<double> cellSizeZ;
  final Value<int> gridCountX;
  final Value<int> gridCountY;
  final Value<int> gridCountZ;
  final Value<int> gridVersion;
  final Value<double> walkMinX;
  final Value<double> walkMaxX;
  final Value<double> walkMinZ;
  final Value<double> walkMaxZ;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RoomsCompanion({
    this.roomId = const Value.absent(),
    this.name = const Value.absent(),
    this.assetPath = const Value.absent(),
    this.previewImagePath = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.assetVersion = const Value.absent(),
    this.defaultAvatarId = const Value.absent(),
    this.cameraAzimuth = const Value.absent(),
    this.cameraElevation = const Value.absent(),
    this.cameraDistance = const Value.absent(),
    this.orthographicSize = const Value.absent(),
    this.targetX = const Value.absent(),
    this.targetY = const Value.absent(),
    this.targetZ = const Value.absent(),
    this.floorY = const Value.absent(),
    this.gridOriginX = const Value.absent(),
    this.gridOriginY = const Value.absent(),
    this.gridOriginZ = const Value.absent(),
    this.cellSizeX = const Value.absent(),
    this.cellSizeY = const Value.absent(),
    this.cellSizeZ = const Value.absent(),
    this.gridCountX = const Value.absent(),
    this.gridCountY = const Value.absent(),
    this.gridCountZ = const Value.absent(),
    this.gridVersion = const Value.absent(),
    this.walkMinX = const Value.absent(),
    this.walkMaxX = const Value.absent(),
    this.walkMinZ = const Value.absent(),
    this.walkMaxZ = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String roomId,
    required String name,
    required String assetPath,
    this.previewImagePath = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.assetVersion = const Value.absent(),
    this.defaultAvatarId = const Value.absent(),
    this.cameraAzimuth = const Value.absent(),
    this.cameraElevation = const Value.absent(),
    this.cameraDistance = const Value.absent(),
    this.orthographicSize = const Value.absent(),
    this.targetX = const Value.absent(),
    this.targetY = const Value.absent(),
    this.targetZ = const Value.absent(),
    this.floorY = const Value.absent(),
    this.gridOriginX = const Value.absent(),
    this.gridOriginY = const Value.absent(),
    this.gridOriginZ = const Value.absent(),
    this.cellSizeX = const Value.absent(),
    this.cellSizeY = const Value.absent(),
    this.cellSizeZ = const Value.absent(),
    this.gridCountX = const Value.absent(),
    this.gridCountY = const Value.absent(),
    this.gridCountZ = const Value.absent(),
    this.gridVersion = const Value.absent(),
    this.walkMinX = const Value.absent(),
    this.walkMaxX = const Value.absent(),
    this.walkMinZ = const Value.absent(),
    this.walkMaxZ = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : roomId = Value(roomId),
        name = Value(name),
        assetPath = Value(assetPath),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RoomRow> custom({
    Expression<String>? roomId,
    Expression<String>? name,
    Expression<String>? assetPath,
    Expression<String>? previewImagePath,
    Expression<bool>? isEnabled,
    Expression<int>? displayOrder,
    Expression<int>? assetVersion,
    Expression<String>? defaultAvatarId,
    Expression<double>? cameraAzimuth,
    Expression<double>? cameraElevation,
    Expression<double>? cameraDistance,
    Expression<double>? orthographicSize,
    Expression<double>? targetX,
    Expression<double>? targetY,
    Expression<double>? targetZ,
    Expression<double>? floorY,
    Expression<double>? gridOriginX,
    Expression<double>? gridOriginY,
    Expression<double>? gridOriginZ,
    Expression<double>? cellSizeX,
    Expression<double>? cellSizeY,
    Expression<double>? cellSizeZ,
    Expression<int>? gridCountX,
    Expression<int>? gridCountY,
    Expression<int>? gridCountZ,
    Expression<int>? gridVersion,
    Expression<double>? walkMinX,
    Expression<double>? walkMaxX,
    Expression<double>? walkMinZ,
    Expression<double>? walkMaxZ,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (name != null) 'name': name,
      if (assetPath != null) 'asset_path': assetPath,
      if (previewImagePath != null) 'preview_image_path': previewImagePath,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (displayOrder != null) 'display_order': displayOrder,
      if (assetVersion != null) 'asset_version': assetVersion,
      if (defaultAvatarId != null) 'default_avatar_id': defaultAvatarId,
      if (cameraAzimuth != null) 'camera_azimuth': cameraAzimuth,
      if (cameraElevation != null) 'camera_elevation': cameraElevation,
      if (cameraDistance != null) 'camera_distance': cameraDistance,
      if (orthographicSize != null) 'orthographic_size': orthographicSize,
      if (targetX != null) 'target_x': targetX,
      if (targetY != null) 'target_y': targetY,
      if (targetZ != null) 'target_z': targetZ,
      if (floorY != null) 'floor_y': floorY,
      if (gridOriginX != null) 'grid_origin_x': gridOriginX,
      if (gridOriginY != null) 'grid_origin_y': gridOriginY,
      if (gridOriginZ != null) 'grid_origin_z': gridOriginZ,
      if (cellSizeX != null) 'cell_size_x': cellSizeX,
      if (cellSizeY != null) 'cell_size_y': cellSizeY,
      if (cellSizeZ != null) 'cell_size_z': cellSizeZ,
      if (gridCountX != null) 'grid_count_x': gridCountX,
      if (gridCountY != null) 'grid_count_y': gridCountY,
      if (gridCountZ != null) 'grid_count_z': gridCountZ,
      if (gridVersion != null) 'grid_version': gridVersion,
      if (walkMinX != null) 'walk_min_x': walkMinX,
      if (walkMaxX != null) 'walk_max_x': walkMaxX,
      if (walkMinZ != null) 'walk_min_z': walkMinZ,
      if (walkMaxZ != null) 'walk_max_z': walkMaxZ,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith(
      {Value<String>? roomId,
      Value<String>? name,
      Value<String>? assetPath,
      Value<String?>? previewImagePath,
      Value<bool>? isEnabled,
      Value<int>? displayOrder,
      Value<int>? assetVersion,
      Value<String?>? defaultAvatarId,
      Value<double>? cameraAzimuth,
      Value<double>? cameraElevation,
      Value<double>? cameraDistance,
      Value<double>? orthographicSize,
      Value<double>? targetX,
      Value<double>? targetY,
      Value<double>? targetZ,
      Value<double>? floorY,
      Value<double>? gridOriginX,
      Value<double>? gridOriginY,
      Value<double>? gridOriginZ,
      Value<double>? cellSizeX,
      Value<double>? cellSizeY,
      Value<double>? cellSizeZ,
      Value<int>? gridCountX,
      Value<int>? gridCountY,
      Value<int>? gridCountZ,
      Value<int>? gridVersion,
      Value<double>? walkMinX,
      Value<double>? walkMaxX,
      Value<double>? walkMinZ,
      Value<double>? walkMaxZ,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RoomsCompanion(
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      assetPath: assetPath ?? this.assetPath,
      previewImagePath: previewImagePath ?? this.previewImagePath,
      isEnabled: isEnabled ?? this.isEnabled,
      displayOrder: displayOrder ?? this.displayOrder,
      assetVersion: assetVersion ?? this.assetVersion,
      defaultAvatarId: defaultAvatarId ?? this.defaultAvatarId,
      cameraAzimuth: cameraAzimuth ?? this.cameraAzimuth,
      cameraElevation: cameraElevation ?? this.cameraElevation,
      cameraDistance: cameraDistance ?? this.cameraDistance,
      orthographicSize: orthographicSize ?? this.orthographicSize,
      targetX: targetX ?? this.targetX,
      targetY: targetY ?? this.targetY,
      targetZ: targetZ ?? this.targetZ,
      floorY: floorY ?? this.floorY,
      gridOriginX: gridOriginX ?? this.gridOriginX,
      gridOriginY: gridOriginY ?? this.gridOriginY,
      gridOriginZ: gridOriginZ ?? this.gridOriginZ,
      cellSizeX: cellSizeX ?? this.cellSizeX,
      cellSizeY: cellSizeY ?? this.cellSizeY,
      cellSizeZ: cellSizeZ ?? this.cellSizeZ,
      gridCountX: gridCountX ?? this.gridCountX,
      gridCountY: gridCountY ?? this.gridCountY,
      gridCountZ: gridCountZ ?? this.gridCountZ,
      gridVersion: gridVersion ?? this.gridVersion,
      walkMinX: walkMinX ?? this.walkMinX,
      walkMaxX: walkMaxX ?? this.walkMaxX,
      walkMinZ: walkMinZ ?? this.walkMinZ,
      walkMaxZ: walkMaxZ ?? this.walkMaxZ,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (assetPath.present) {
      map['asset_path'] = Variable<String>(assetPath.value);
    }
    if (previewImagePath.present) {
      map['preview_image_path'] = Variable<String>(previewImagePath.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (assetVersion.present) {
      map['asset_version'] = Variable<int>(assetVersion.value);
    }
    if (defaultAvatarId.present) {
      map['default_avatar_id'] = Variable<String>(defaultAvatarId.value);
    }
    if (cameraAzimuth.present) {
      map['camera_azimuth'] = Variable<double>(cameraAzimuth.value);
    }
    if (cameraElevation.present) {
      map['camera_elevation'] = Variable<double>(cameraElevation.value);
    }
    if (cameraDistance.present) {
      map['camera_distance'] = Variable<double>(cameraDistance.value);
    }
    if (orthographicSize.present) {
      map['orthographic_size'] = Variable<double>(orthographicSize.value);
    }
    if (targetX.present) {
      map['target_x'] = Variable<double>(targetX.value);
    }
    if (targetY.present) {
      map['target_y'] = Variable<double>(targetY.value);
    }
    if (targetZ.present) {
      map['target_z'] = Variable<double>(targetZ.value);
    }
    if (floorY.present) {
      map['floor_y'] = Variable<double>(floorY.value);
    }
    if (gridOriginX.present) {
      map['grid_origin_x'] = Variable<double>(gridOriginX.value);
    }
    if (gridOriginY.present) {
      map['grid_origin_y'] = Variable<double>(gridOriginY.value);
    }
    if (gridOriginZ.present) {
      map['grid_origin_z'] = Variable<double>(gridOriginZ.value);
    }
    if (cellSizeX.present) {
      map['cell_size_x'] = Variable<double>(cellSizeX.value);
    }
    if (cellSizeY.present) {
      map['cell_size_y'] = Variable<double>(cellSizeY.value);
    }
    if (cellSizeZ.present) {
      map['cell_size_z'] = Variable<double>(cellSizeZ.value);
    }
    if (gridCountX.present) {
      map['grid_count_x'] = Variable<int>(gridCountX.value);
    }
    if (gridCountY.present) {
      map['grid_count_y'] = Variable<int>(gridCountY.value);
    }
    if (gridCountZ.present) {
      map['grid_count_z'] = Variable<int>(gridCountZ.value);
    }
    if (gridVersion.present) {
      map['grid_version'] = Variable<int>(gridVersion.value);
    }
    if (walkMinX.present) {
      map['walk_min_x'] = Variable<double>(walkMinX.value);
    }
    if (walkMaxX.present) {
      map['walk_max_x'] = Variable<double>(walkMaxX.value);
    }
    if (walkMinZ.present) {
      map['walk_min_z'] = Variable<double>(walkMinZ.value);
    }
    if (walkMaxZ.present) {
      map['walk_max_z'] = Variable<double>(walkMaxZ.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('RoomsCompanion(')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('assetPath: $assetPath, ')
          ..write('previewImagePath: $previewImagePath, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('assetVersion: $assetVersion, ')
          ..write('defaultAvatarId: $defaultAvatarId, ')
          ..write('cameraAzimuth: $cameraAzimuth, ')
          ..write('cameraElevation: $cameraElevation, ')
          ..write('cameraDistance: $cameraDistance, ')
          ..write('orthographicSize: $orthographicSize, ')
          ..write('targetX: $targetX, ')
          ..write('targetY: $targetY, ')
          ..write('targetZ: $targetZ, ')
          ..write('floorY: $floorY, ')
          ..write('gridOriginX: $gridOriginX, ')
          ..write('gridOriginY: $gridOriginY, ')
          ..write('gridOriginZ: $gridOriginZ, ')
          ..write('cellSizeX: $cellSizeX, ')
          ..write('cellSizeY: $cellSizeY, ')
          ..write('cellSizeZ: $cellSizeZ, ')
          ..write('gridCountX: $gridCountX, ')
          ..write('gridCountY: $gridCountY, ')
          ..write('gridCountZ: $gridCountZ, ')
          ..write('gridVersion: $gridVersion, ')
          ..write('walkMinX: $walkMinX, ')
          ..write('walkMaxX: $walkMaxX, ')
          ..write('walkMinZ: $walkMinZ, ')
          ..write('walkMaxZ: $walkMaxZ, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _selectedRoomIdMeta =
      const VerificationMeta('selectedRoomId');
  @override
  late final GeneratedColumn<String> selectedRoomId = GeneratedColumn<String>(
      'selected_room_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rooms (room_id) ON DELETE SET NULL'));
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
      'onboarding_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastOpenedAtMeta =
      const VerificationMeta('lastOpenedAt');
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
      'last_opened_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  @override
  List<GeneratedColumn> get $columns => [
        profileId,
        selectedRoomId,
        onboardingCompleted,
        createdAt,
        updatedAt,
        lastOpenedAt,
        version,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(Insertable<UserPreferenceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('selected_room_id')) {
      context.handle(
          _selectedRoomIdMeta,
          selectedRoomId.isAcceptableOrUnknown(
              data['selected_room_id']!, _selectedRoomIdMeta));
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
          _onboardingCompletedMeta,
          onboardingCompleted.isAcceptableOrUnknown(
              data['onboarding_completed']!, _onboardingCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
          _lastOpenedAtMeta,
          lastOpenedAt.isAcceptableOrUnknown(
              data['last_opened_at']!, _lastOpenedAtMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  UserPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreferenceRow(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      selectedRoomId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}selected_room_id']),
      onboardingCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_opened_at']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreferenceRow extends DataClass
    implements Insertable<UserPreferenceRow> {
  final String profileId;
  final String? selectedRoomId;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;
  final int version;
  final String syncState;
  const UserPreferenceRow(
      {required this.profileId,
      this.selectedRoomId,
      required this.onboardingCompleted,
      required this.createdAt,
      required this.updatedAt,
      this.lastOpenedAt,
      required this.version,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    if (!nullToAbsent || selectedRoomId != null) {
      map['selected_room_id'] = Variable<String>(selectedRoomId);
    }
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    map['version'] = Variable<int>(version);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      profileId: Value(profileId),
      selectedRoomId: selectedRoomId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedRoomId),
      onboardingCompleted: Value(onboardingCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
      version: Value(version),
      syncState: Value(syncState),
    );
  }

  factory UserPreferenceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreferenceRow(
      profileId: serializer.fromJson<String>(json['profileId']),
      selectedRoomId: serializer.fromJson<String?>(json['selectedRoomId']),
      onboardingCompleted:
          serializer.fromJson<bool>(json['onboardingCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
      version: serializer.fromJson<int>(json['version']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'selectedRoomId': serializer.toJson<String?>(selectedRoomId),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
      'version': serializer.toJson<int>(version),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  UserPreferenceRow copyWith(
          {String? profileId,
          Value<String?> selectedRoomId = const Value.absent(),
          bool? onboardingCompleted,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> lastOpenedAt = const Value.absent(),
          int? version,
          String? syncState}) =>
      UserPreferenceRow(
        profileId: profileId ?? this.profileId,
        selectedRoomId:
            selectedRoomId.present ? selectedRoomId.value : this.selectedRoomId,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastOpenedAt:
            lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
        version: version ?? this.version,
        syncState: syncState ?? this.syncState,
      );
  UserPreferenceRow copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreferenceRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      selectedRoomId: data.selectedRoomId.present
          ? data.selectedRoomId.value
          : this.selectedRoomId,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      version: data.version.present ? data.version.value : this.version,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferenceRow(')
          ..write('profileId: $profileId, ')
          ..write('selectedRoomId: $selectedRoomId, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('version: $version, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      profileId,
      selectedRoomId,
      onboardingCompleted,
      createdAt,
      updatedAt,
      lastOpenedAt,
      version,
      syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreferenceRow &&
          other.profileId == this.profileId &&
          other.selectedRoomId == this.selectedRoomId &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.version == this.version &&
          other.syncState == this.syncState);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreferenceRow> {
  final Value<String> profileId;
  final Value<String?> selectedRoomId;
  final Value<bool> onboardingCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<int> version;
  final Value<String> syncState;
  final Value<int> rowid;
  const UserPreferencesCompanion({
    this.profileId = const Value.absent(),
    this.selectedRoomId = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    required String profileId,
    this.selectedRoomId = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastOpenedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : profileId = Value(profileId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserPreferenceRow> custom({
    Expression<String>? profileId,
    Expression<String>? selectedRoomId,
    Expression<bool>? onboardingCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? version,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (selectedRoomId != null) 'selected_room_id': selectedRoomId,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (version != null) 'version': version,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPreferencesCompanion copyWith(
      {Value<String>? profileId,
      Value<String?>? selectedRoomId,
      Value<bool>? onboardingCompleted,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? lastOpenedAt,
      Value<int>? version,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return UserPreferencesCompanion(
      profileId: profileId ?? this.profileId,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      version: version ?? this.version,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (selectedRoomId.present) {
      map['selected_room_id'] = Variable<String>(selectedRoomId.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('selectedRoomId: $selectedRoomId, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('version: $version, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomAvatarAssignmentsTable extends RoomAvatarAssignments
    with TableInfo<$RoomAvatarAssignmentsTable, RoomAvatarAssignmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomAvatarAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assignmentIdMeta =
      const VerificationMeta('assignmentId');
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
      'assignment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rooms (room_id) ON DELETE CASCADE'));
  static const VerificationMeta _avatarIdMeta =
      const VerificationMeta('avatarId');
  @override
  late final GeneratedColumn<String> avatarId = GeneratedColumn<String>(
      'avatar_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES avatars (avatar_id) ON DELETE RESTRICT'));
  static const VerificationMeta _posXMeta = const VerificationMeta('posX');
  @override
  late final GeneratedColumn<double> posX = GeneratedColumn<double>(
      'pos_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _posYMeta = const VerificationMeta('posY');
  @override
  late final GeneratedColumn<double> posY = GeneratedColumn<double>(
      'pos_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _posZMeta = const VerificationMeta('posZ');
  @override
  late final GeneratedColumn<double> posZ = GeneratedColumn<double>(
      'pos_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _scaleXMeta = const VerificationMeta('scaleX');
  @override
  late final GeneratedColumn<double> scaleX = GeneratedColumn<double>(
      'scale_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _scaleYMeta = const VerificationMeta('scaleY');
  @override
  late final GeneratedColumn<double> scaleY = GeneratedColumn<double>(
      'scale_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _scaleZMeta = const VerificationMeta('scaleZ');
  @override
  late final GeneratedColumn<double> scaleZ = GeneratedColumn<double>(
      'scale_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _rotationXMeta =
      const VerificationMeta('rotationX');
  @override
  late final GeneratedColumn<double> rotationX = GeneratedColumn<double>(
      'rotation_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _rotationYMeta =
      const VerificationMeta('rotationY');
  @override
  late final GeneratedColumn<double> rotationY = GeneratedColumn<double>(
      'rotation_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _rotationZMeta =
      const VerificationMeta('rotationZ');
  @override
  late final GeneratedColumn<double> rotationZ = GeneratedColumn<double>(
      'rotation_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  @override
  List<GeneratedColumn> get $columns => [
        assignmentId,
        profileId,
        roomId,
        avatarId,
        posX,
        posY,
        posZ,
        scaleX,
        scaleY,
        scaleZ,
        rotationX,
        rotationY,
        rotationZ,
        createdAt,
        updatedAt,
        version,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'room_avatar_assignments';
  @override
  VerificationContext validateIntegrity(
      Insertable<RoomAvatarAssignmentRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assignment_id')) {
      context.handle(
          _assignmentIdMeta,
          assignmentId.isAcceptableOrUnknown(
              data['assignment_id']!, _assignmentIdMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('avatar_id')) {
      context.handle(_avatarIdMeta,
          avatarId.isAcceptableOrUnknown(data['avatar_id']!, _avatarIdMeta));
    } else if (isInserting) {
      context.missing(_avatarIdMeta);
    }
    if (data.containsKey('pos_x')) {
      context.handle(
          _posXMeta, posX.isAcceptableOrUnknown(data['pos_x']!, _posXMeta));
    }
    if (data.containsKey('pos_y')) {
      context.handle(
          _posYMeta, posY.isAcceptableOrUnknown(data['pos_y']!, _posYMeta));
    }
    if (data.containsKey('pos_z')) {
      context.handle(
          _posZMeta, posZ.isAcceptableOrUnknown(data['pos_z']!, _posZMeta));
    }
    if (data.containsKey('scale_x')) {
      context.handle(_scaleXMeta,
          scaleX.isAcceptableOrUnknown(data['scale_x']!, _scaleXMeta));
    }
    if (data.containsKey('scale_y')) {
      context.handle(_scaleYMeta,
          scaleY.isAcceptableOrUnknown(data['scale_y']!, _scaleYMeta));
    }
    if (data.containsKey('scale_z')) {
      context.handle(_scaleZMeta,
          scaleZ.isAcceptableOrUnknown(data['scale_z']!, _scaleZMeta));
    }
    if (data.containsKey('rotation_x')) {
      context.handle(_rotationXMeta,
          rotationX.isAcceptableOrUnknown(data['rotation_x']!, _rotationXMeta));
    }
    if (data.containsKey('rotation_y')) {
      context.handle(_rotationYMeta,
          rotationY.isAcceptableOrUnknown(data['rotation_y']!, _rotationYMeta));
    }
    if (data.containsKey('rotation_z')) {
      context.handle(_rotationZMeta,
          rotationZ.isAcceptableOrUnknown(data['rotation_z']!, _rotationZMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, roomId};
  @override
  RoomAvatarAssignmentRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomAvatarAssignmentRow(
      assignmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assignment_id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
      avatarId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_id'])!,
      posX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_x'])!,
      posY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_y'])!,
      posZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_z'])!,
      scaleX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scale_x'])!,
      scaleY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scale_y'])!,
      scaleZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scale_z'])!,
      rotationX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rotation_x'])!,
      rotationY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rotation_y'])!,
      rotationZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rotation_z'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $RoomAvatarAssignmentsTable createAlias(String alias) {
    return $RoomAvatarAssignmentsTable(attachedDatabase, alias);
  }
}

class RoomAvatarAssignmentRow extends DataClass
    implements Insertable<RoomAvatarAssignmentRow> {
  final String assignmentId;
  final String profileId;
  final String roomId;
  final String avatarId;
  final double posX;
  final double posY;
  final double posZ;
  final double scaleX;
  final double scaleY;
  final double scaleZ;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String syncState;
  const RoomAvatarAssignmentRow(
      {required this.assignmentId,
      required this.profileId,
      required this.roomId,
      required this.avatarId,
      required this.posX,
      required this.posY,
      required this.posZ,
      required this.scaleX,
      required this.scaleY,
      required this.scaleZ,
      required this.rotationX,
      required this.rotationY,
      required this.rotationZ,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assignment_id'] = Variable<String>(assignmentId);
    map['profile_id'] = Variable<String>(profileId);
    map['room_id'] = Variable<String>(roomId);
    map['avatar_id'] = Variable<String>(avatarId);
    map['pos_x'] = Variable<double>(posX);
    map['pos_y'] = Variable<double>(posY);
    map['pos_z'] = Variable<double>(posZ);
    map['scale_x'] = Variable<double>(scaleX);
    map['scale_y'] = Variable<double>(scaleY);
    map['scale_z'] = Variable<double>(scaleZ);
    map['rotation_x'] = Variable<double>(rotationX);
    map['rotation_y'] = Variable<double>(rotationY);
    map['rotation_z'] = Variable<double>(rotationZ);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  RoomAvatarAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return RoomAvatarAssignmentsCompanion(
      assignmentId: Value(assignmentId),
      profileId: Value(profileId),
      roomId: Value(roomId),
      avatarId: Value(avatarId),
      posX: Value(posX),
      posY: Value(posY),
      posZ: Value(posZ),
      scaleX: Value(scaleX),
      scaleY: Value(scaleY),
      scaleZ: Value(scaleZ),
      rotationX: Value(rotationX),
      rotationY: Value(rotationY),
      rotationZ: Value(rotationZ),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      syncState: Value(syncState),
    );
  }

  factory RoomAvatarAssignmentRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomAvatarAssignmentRow(
      assignmentId: serializer.fromJson<String>(json['assignmentId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      avatarId: serializer.fromJson<String>(json['avatarId']),
      posX: serializer.fromJson<double>(json['posX']),
      posY: serializer.fromJson<double>(json['posY']),
      posZ: serializer.fromJson<double>(json['posZ']),
      scaleX: serializer.fromJson<double>(json['scaleX']),
      scaleY: serializer.fromJson<double>(json['scaleY']),
      scaleZ: serializer.fromJson<double>(json['scaleZ']),
      rotationX: serializer.fromJson<double>(json['rotationX']),
      rotationY: serializer.fromJson<double>(json['rotationY']),
      rotationZ: serializer.fromJson<double>(json['rotationZ']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assignmentId': serializer.toJson<String>(assignmentId),
      'profileId': serializer.toJson<String>(profileId),
      'roomId': serializer.toJson<String>(roomId),
      'avatarId': serializer.toJson<String>(avatarId),
      'posX': serializer.toJson<double>(posX),
      'posY': serializer.toJson<double>(posY),
      'posZ': serializer.toJson<double>(posZ),
      'scaleX': serializer.toJson<double>(scaleX),
      'scaleY': serializer.toJson<double>(scaleY),
      'scaleZ': serializer.toJson<double>(scaleZ),
      'rotationX': serializer.toJson<double>(rotationX),
      'rotationY': serializer.toJson<double>(rotationY),
      'rotationZ': serializer.toJson<double>(rotationZ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  RoomAvatarAssignmentRow copyWith(
          {String? assignmentId,
          String? profileId,
          String? roomId,
          String? avatarId,
          double? posX,
          double? posY,
          double? posZ,
          double? scaleX,
          double? scaleY,
          double? scaleZ,
          double? rotationX,
          double? rotationY,
          double? rotationZ,
          DateTime? createdAt,
          DateTime? updatedAt,
          int? version,
          String? syncState}) =>
      RoomAvatarAssignmentRow(
        assignmentId: assignmentId ?? this.assignmentId,
        profileId: profileId ?? this.profileId,
        roomId: roomId ?? this.roomId,
        avatarId: avatarId ?? this.avatarId,
        posX: posX ?? this.posX,
        posY: posY ?? this.posY,
        posZ: posZ ?? this.posZ,
        scaleX: scaleX ?? this.scaleX,
        scaleY: scaleY ?? this.scaleY,
        scaleZ: scaleZ ?? this.scaleZ,
        rotationX: rotationX ?? this.rotationX,
        rotationY: rotationY ?? this.rotationY,
        rotationZ: rotationZ ?? this.rotationZ,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        syncState: syncState ?? this.syncState,
      );
  RoomAvatarAssignmentRow copyWithCompanion(
      RoomAvatarAssignmentsCompanion data) {
    return RoomAvatarAssignmentRow(
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      avatarId: data.avatarId.present ? data.avatarId.value : this.avatarId,
      posX: data.posX.present ? data.posX.value : this.posX,
      posY: data.posY.present ? data.posY.value : this.posY,
      posZ: data.posZ.present ? data.posZ.value : this.posZ,
      scaleX: data.scaleX.present ? data.scaleX.value : this.scaleX,
      scaleY: data.scaleY.present ? data.scaleY.value : this.scaleY,
      scaleZ: data.scaleZ.present ? data.scaleZ.value : this.scaleZ,
      rotationX: data.rotationX.present ? data.rotationX.value : this.rotationX,
      rotationY: data.rotationY.present ? data.rotationY.value : this.rotationY,
      rotationZ: data.rotationZ.present ? data.rotationZ.value : this.rotationZ,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomAvatarAssignmentRow(')
          ..write('assignmentId: $assignmentId, ')
          ..write('profileId: $profileId, ')
          ..write('roomId: $roomId, ')
          ..write('avatarId: $avatarId, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('posZ: $posZ, ')
          ..write('scaleX: $scaleX, ')
          ..write('scaleY: $scaleY, ')
          ..write('scaleZ: $scaleZ, ')
          ..write('rotationX: $rotationX, ')
          ..write('rotationY: $rotationY, ')
          ..write('rotationZ: $rotationZ, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      assignmentId,
      profileId,
      roomId,
      avatarId,
      posX,
      posY,
      posZ,
      scaleX,
      scaleY,
      scaleZ,
      rotationX,
      rotationY,
      rotationZ,
      createdAt,
      updatedAt,
      version,
      syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomAvatarAssignmentRow &&
          other.assignmentId == this.assignmentId &&
          other.profileId == this.profileId &&
          other.roomId == this.roomId &&
          other.avatarId == this.avatarId &&
          other.posX == this.posX &&
          other.posY == this.posY &&
          other.posZ == this.posZ &&
          other.scaleX == this.scaleX &&
          other.scaleY == this.scaleY &&
          other.scaleZ == this.scaleZ &&
          other.rotationX == this.rotationX &&
          other.rotationY == this.rotationY &&
          other.rotationZ == this.rotationZ &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.syncState == this.syncState);
}

class RoomAvatarAssignmentsCompanion
    extends UpdateCompanion<RoomAvatarAssignmentRow> {
  final Value<String> assignmentId;
  final Value<String> profileId;
  final Value<String> roomId;
  final Value<String> avatarId;
  final Value<double> posX;
  final Value<double> posY;
  final Value<double> posZ;
  final Value<double> scaleX;
  final Value<double> scaleY;
  final Value<double> scaleZ;
  final Value<double> rotationX;
  final Value<double> rotationY;
  final Value<double> rotationZ;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<String> syncState;
  final Value<int> rowid;
  const RoomAvatarAssignmentsCompanion({
    this.assignmentId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.avatarId = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.posZ = const Value.absent(),
    this.scaleX = const Value.absent(),
    this.scaleY = const Value.absent(),
    this.scaleZ = const Value.absent(),
    this.rotationX = const Value.absent(),
    this.rotationY = const Value.absent(),
    this.rotationZ = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomAvatarAssignmentsCompanion.insert({
    this.assignmentId = const Value.absent(),
    required String profileId,
    required String roomId,
    required String avatarId,
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.posZ = const Value.absent(),
    this.scaleX = const Value.absent(),
    this.scaleY = const Value.absent(),
    this.scaleZ = const Value.absent(),
    this.rotationX = const Value.absent(),
    this.rotationY = const Value.absent(),
    this.rotationZ = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : profileId = Value(profileId),
        roomId = Value(roomId),
        avatarId = Value(avatarId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RoomAvatarAssignmentRow> custom({
    Expression<String>? assignmentId,
    Expression<String>? profileId,
    Expression<String>? roomId,
    Expression<String>? avatarId,
    Expression<double>? posX,
    Expression<double>? posY,
    Expression<double>? posZ,
    Expression<double>? scaleX,
    Expression<double>? scaleY,
    Expression<double>? scaleZ,
    Expression<double>? rotationX,
    Expression<double>? rotationY,
    Expression<double>? rotationZ,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (profileId != null) 'profile_id': profileId,
      if (roomId != null) 'room_id': roomId,
      if (avatarId != null) 'avatar_id': avatarId,
      if (posX != null) 'pos_x': posX,
      if (posY != null) 'pos_y': posY,
      if (posZ != null) 'pos_z': posZ,
      if (scaleX != null) 'scale_x': scaleX,
      if (scaleY != null) 'scale_y': scaleY,
      if (scaleZ != null) 'scale_z': scaleZ,
      if (rotationX != null) 'rotation_x': rotationX,
      if (rotationY != null) 'rotation_y': rotationY,
      if (rotationZ != null) 'rotation_z': rotationZ,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomAvatarAssignmentsCompanion copyWith(
      {Value<String>? assignmentId,
      Value<String>? profileId,
      Value<String>? roomId,
      Value<String>? avatarId,
      Value<double>? posX,
      Value<double>? posY,
      Value<double>? posZ,
      Value<double>? scaleX,
      Value<double>? scaleY,
      Value<double>? scaleZ,
      Value<double>? rotationX,
      Value<double>? rotationY,
      Value<double>? rotationZ,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? version,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return RoomAvatarAssignmentsCompanion(
      assignmentId: assignmentId ?? this.assignmentId,
      profileId: profileId ?? this.profileId,
      roomId: roomId ?? this.roomId,
      avatarId: avatarId ?? this.avatarId,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      posZ: posZ ?? this.posZ,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      scaleZ: scaleZ ?? this.scaleZ,
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (avatarId.present) {
      map['avatar_id'] = Variable<String>(avatarId.value);
    }
    if (posX.present) {
      map['pos_x'] = Variable<double>(posX.value);
    }
    if (posY.present) {
      map['pos_y'] = Variable<double>(posY.value);
    }
    if (posZ.present) {
      map['pos_z'] = Variable<double>(posZ.value);
    }
    if (scaleX.present) {
      map['scale_x'] = Variable<double>(scaleX.value);
    }
    if (scaleY.present) {
      map['scale_y'] = Variable<double>(scaleY.value);
    }
    if (scaleZ.present) {
      map['scale_z'] = Variable<double>(scaleZ.value);
    }
    if (rotationX.present) {
      map['rotation_x'] = Variable<double>(rotationX.value);
    }
    if (rotationY.present) {
      map['rotation_y'] = Variable<double>(rotationY.value);
    }
    if (rotationZ.present) {
      map['rotation_z'] = Variable<double>(rotationZ.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomAvatarAssignmentsCompanion(')
          ..write('assignmentId: $assignmentId, ')
          ..write('profileId: $profileId, ')
          ..write('roomId: $roomId, ')
          ..write('avatarId: $avatarId, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('posZ: $posZ, ')
          ..write('scaleX: $scaleX, ')
          ..write('scaleY: $scaleY, ')
          ..write('scaleZ: $scaleZ, ')
          ..write('rotationX: $rotationX, ')
          ..write('rotationY: $rotationY, ')
          ..write('rotationZ: $rotationZ, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_user'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('keep'));
  static const VerificationMeta _transferableMeta =
      const VerificationMeta('transferable');
  @override
  late final GeneratedColumn<bool> transferable = GeneratedColumn<bool>(
      'transferable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("transferable" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _localImagePathMeta =
      const VerificationMeta('localImagePath');
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
      'local_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalImageKeyMeta =
      const VerificationMeta('originalImageKey');
  @override
  late final GeneratedColumn<String> originalImageKey = GeneratedColumn<String>(
      'original_image_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _processedImageKeyMeta =
      const VerificationMeta('processedImageKey');
  @override
  late final GeneratedColumn<String> processedImageKey =
      GeneratedColumn<String>('processed_image_key', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _processedLocalImagePathMeta =
      const VerificationMeta('processedLocalImagePath');
  @override
  late final GeneratedColumn<String> processedLocalImagePath =
      GeneratedColumn<String>('processed_local_image_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _outputTypeMeta =
      const VerificationMeta('outputType');
  @override
  late final GeneratedColumn<String> outputType = GeneratedColumn<String>(
      'output_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('sticker_png'));
  static const VerificationMeta _processStatusMeta =
      const VerificationMeta('processStatus');
  @override
  late final GeneratedColumn<String> processStatus = GeneratedColumn<String>(
      'process_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('idle'));
  static const VerificationMeta _processErrorMessageMeta =
      const VerificationMeta('processErrorMessage');
  @override
  late final GeneratedColumn<String> processErrorMessage =
      GeneratedColumn<String>('process_error_message', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _processFailureStageMeta =
      const VerificationMeta('processFailureStage');
  @override
  late final GeneratedColumn<String> processFailureStage =
      GeneratedColumn<String>('process_failure_stage', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _usedFromMeta =
      const VerificationMeta('usedFrom');
  @override
  late final GeneratedColumn<DateTime> usedFrom = GeneratedColumn<DateTime>(
      'used_from', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _usedUntilMeta =
      const VerificationMeta('usedUntil');
  @override
  late final GeneratedColumn<DateTime> usedUntil = GeneratedColumn<DateTime>(
      'used_until', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        itemId,
        ownerId,
        title,
        memo,
        status,
        transferable,
        localImagePath,
        originalImageKey,
        processedImageKey,
        processedLocalImagePath,
        outputType,
        processStatus,
        processErrorMessage,
        processFailureStage,
        usedFrom,
        usedUntil,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<Item> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('transferable')) {
      context.handle(
          _transferableMeta,
          transferable.isAcceptableOrUnknown(
              data['transferable']!, _transferableMeta));
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
          _localImagePathMeta,
          localImagePath.isAcceptableOrUnknown(
              data['local_image_path']!, _localImagePathMeta));
    }
    if (data.containsKey('original_image_key')) {
      context.handle(
          _originalImageKeyMeta,
          originalImageKey.isAcceptableOrUnknown(
              data['original_image_key']!, _originalImageKeyMeta));
    }
    if (data.containsKey('processed_image_key')) {
      context.handle(
          _processedImageKeyMeta,
          processedImageKey.isAcceptableOrUnknown(
              data['processed_image_key']!, _processedImageKeyMeta));
    }
    if (data.containsKey('processed_local_image_path')) {
      context.handle(
          _processedLocalImagePathMeta,
          processedLocalImagePath.isAcceptableOrUnknown(
              data['processed_local_image_path']!,
              _processedLocalImagePathMeta));
    }
    if (data.containsKey('output_type')) {
      context.handle(
          _outputTypeMeta,
          outputType.isAcceptableOrUnknown(
              data['output_type']!, _outputTypeMeta));
    }
    if (data.containsKey('process_status')) {
      context.handle(
          _processStatusMeta,
          processStatus.isAcceptableOrUnknown(
              data['process_status']!, _processStatusMeta));
    }
    if (data.containsKey('process_error_message')) {
      context.handle(
          _processErrorMessageMeta,
          processErrorMessage.isAcceptableOrUnknown(
              data['process_error_message']!, _processErrorMessageMeta));
    }
    if (data.containsKey('process_failure_stage')) {
      context.handle(
          _processFailureStageMeta,
          processFailureStage.isAcceptableOrUnknown(
              data['process_failure_stage']!, _processFailureStageMeta));
    }
    if (data.containsKey('used_from')) {
      context.handle(_usedFromMeta,
          usedFrom.isAcceptableOrUnknown(data['used_from']!, _usedFromMeta));
    }
    if (data.containsKey('used_until')) {
      context.handle(_usedUntilMeta,
          usedUntil.isAcceptableOrUnknown(data['used_until']!, _usedUntilMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      transferable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}transferable'])!,
      localImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_image_path']),
      originalImageKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_image_key']),
      processedImageKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}processed_image_key']),
      processedLocalImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}processed_local_image_path']),
      outputType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}output_type'])!,
      processStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}process_status'])!,
      processErrorMessage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}process_error_message']),
      processFailureStage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}process_failure_stage']),
      usedFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}used_from']),
      usedUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}used_until']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String itemId;
  final String ownerId;
  final String title;
  final String memo;
  final String status;
  final bool transferable;
  final String? localImagePath;
  final String? originalImageKey;
  final String? processedImageKey;
  final String? processedLocalImagePath;
  final String outputType;
  final String processStatus;
  final String? processErrorMessage;
  final String? processFailureStage;
  final DateTime? usedFrom;
  final DateTime? usedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Item(
      {required this.itemId,
      required this.ownerId,
      required this.title,
      required this.memo,
      required this.status,
      required this.transferable,
      this.localImagePath,
      this.originalImageKey,
      this.processedImageKey,
      this.processedLocalImagePath,
      required this.outputType,
      required this.processStatus,
      this.processErrorMessage,
      this.processFailureStage,
      this.usedFrom,
      this.usedUntil,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['owner_id'] = Variable<String>(ownerId);
    map['title'] = Variable<String>(title);
    map['memo'] = Variable<String>(memo);
    map['status'] = Variable<String>(status);
    map['transferable'] = Variable<bool>(transferable);
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    if (!nullToAbsent || originalImageKey != null) {
      map['original_image_key'] = Variable<String>(originalImageKey);
    }
    if (!nullToAbsent || processedImageKey != null) {
      map['processed_image_key'] = Variable<String>(processedImageKey);
    }
    if (!nullToAbsent || processedLocalImagePath != null) {
      map['processed_local_image_path'] =
          Variable<String>(processedLocalImagePath);
    }
    map['output_type'] = Variable<String>(outputType);
    map['process_status'] = Variable<String>(processStatus);
    if (!nullToAbsent || processErrorMessage != null) {
      map['process_error_message'] = Variable<String>(processErrorMessage);
    }
    if (!nullToAbsent || processFailureStage != null) {
      map['process_failure_stage'] = Variable<String>(processFailureStage);
    }
    if (!nullToAbsent || usedFrom != null) {
      map['used_from'] = Variable<DateTime>(usedFrom);
    }
    if (!nullToAbsent || usedUntil != null) {
      map['used_until'] = Variable<DateTime>(usedUntil);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      itemId: Value(itemId),
      ownerId: Value(ownerId),
      title: Value(title),
      memo: Value(memo),
      status: Value(status),
      transferable: Value(transferable),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
      originalImageKey: originalImageKey == null && nullToAbsent
          ? const Value.absent()
          : Value(originalImageKey),
      processedImageKey: processedImageKey == null && nullToAbsent
          ? const Value.absent()
          : Value(processedImageKey),
      processedLocalImagePath: processedLocalImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(processedLocalImagePath),
      outputType: Value(outputType),
      processStatus: Value(processStatus),
      processErrorMessage: processErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(processErrorMessage),
      processFailureStage: processFailureStage == null && nullToAbsent
          ? const Value.absent()
          : Value(processFailureStage),
      usedFrom: usedFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(usedFrom),
      usedUntil: usedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(usedUntil),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      itemId: serializer.fromJson<String>(json['itemId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      title: serializer.fromJson<String>(json['title']),
      memo: serializer.fromJson<String>(json['memo']),
      status: serializer.fromJson<String>(json['status']),
      transferable: serializer.fromJson<bool>(json['transferable']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      originalImageKey: serializer.fromJson<String?>(json['originalImageKey']),
      processedImageKey:
          serializer.fromJson<String?>(json['processedImageKey']),
      processedLocalImagePath:
          serializer.fromJson<String?>(json['processedLocalImagePath']),
      outputType: serializer.fromJson<String>(json['outputType']),
      processStatus: serializer.fromJson<String>(json['processStatus']),
      processErrorMessage:
          serializer.fromJson<String?>(json['processErrorMessage']),
      processFailureStage:
          serializer.fromJson<String?>(json['processFailureStage']),
      usedFrom: serializer.fromJson<DateTime?>(json['usedFrom']),
      usedUntil: serializer.fromJson<DateTime?>(json['usedUntil']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'ownerId': serializer.toJson<String>(ownerId),
      'title': serializer.toJson<String>(title),
      'memo': serializer.toJson<String>(memo),
      'status': serializer.toJson<String>(status),
      'transferable': serializer.toJson<bool>(transferable),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'originalImageKey': serializer.toJson<String?>(originalImageKey),
      'processedImageKey': serializer.toJson<String?>(processedImageKey),
      'processedLocalImagePath':
          serializer.toJson<String?>(processedLocalImagePath),
      'outputType': serializer.toJson<String>(outputType),
      'processStatus': serializer.toJson<String>(processStatus),
      'processErrorMessage': serializer.toJson<String?>(processErrorMessage),
      'processFailureStage': serializer.toJson<String?>(processFailureStage),
      'usedFrom': serializer.toJson<DateTime?>(usedFrom),
      'usedUntil': serializer.toJson<DateTime?>(usedUntil),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Item copyWith(
          {String? itemId,
          String? ownerId,
          String? title,
          String? memo,
          String? status,
          bool? transferable,
          Value<String?> localImagePath = const Value.absent(),
          Value<String?> originalImageKey = const Value.absent(),
          Value<String?> processedImageKey = const Value.absent(),
          Value<String?> processedLocalImagePath = const Value.absent(),
          String? outputType,
          String? processStatus,
          Value<String?> processErrorMessage = const Value.absent(),
          Value<String?> processFailureStage = const Value.absent(),
          Value<DateTime?> usedFrom = const Value.absent(),
          Value<DateTime?> usedUntil = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Item(
        itemId: itemId ?? this.itemId,
        ownerId: ownerId ?? this.ownerId,
        title: title ?? this.title,
        memo: memo ?? this.memo,
        status: status ?? this.status,
        transferable: transferable ?? this.transferable,
        localImagePath:
            localImagePath.present ? localImagePath.value : this.localImagePath,
        originalImageKey: originalImageKey.present
            ? originalImageKey.value
            : this.originalImageKey,
        processedImageKey: processedImageKey.present
            ? processedImageKey.value
            : this.processedImageKey,
        processedLocalImagePath: processedLocalImagePath.present
            ? processedLocalImagePath.value
            : this.processedLocalImagePath,
        outputType: outputType ?? this.outputType,
        processStatus: processStatus ?? this.processStatus,
        processErrorMessage: processErrorMessage.present
            ? processErrorMessage.value
            : this.processErrorMessage,
        processFailureStage: processFailureStage.present
            ? processFailureStage.value
            : this.processFailureStage,
        usedFrom: usedFrom.present ? usedFrom.value : this.usedFrom,
        usedUntil: usedUntil.present ? usedUntil.value : this.usedUntil,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      title: data.title.present ? data.title.value : this.title,
      memo: data.memo.present ? data.memo.value : this.memo,
      status: data.status.present ? data.status.value : this.status,
      transferable: data.transferable.present
          ? data.transferable.value
          : this.transferable,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      originalImageKey: data.originalImageKey.present
          ? data.originalImageKey.value
          : this.originalImageKey,
      processedImageKey: data.processedImageKey.present
          ? data.processedImageKey.value
          : this.processedImageKey,
      processedLocalImagePath: data.processedLocalImagePath.present
          ? data.processedLocalImagePath.value
          : this.processedLocalImagePath,
      outputType:
          data.outputType.present ? data.outputType.value : this.outputType,
      processStatus: data.processStatus.present
          ? data.processStatus.value
          : this.processStatus,
      processErrorMessage: data.processErrorMessage.present
          ? data.processErrorMessage.value
          : this.processErrorMessage,
      processFailureStage: data.processFailureStage.present
          ? data.processFailureStage.value
          : this.processFailureStage,
      usedFrom: data.usedFrom.present ? data.usedFrom.value : this.usedFrom,
      usedUntil: data.usedUntil.present ? data.usedUntil.value : this.usedUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('itemId: $itemId, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('memo: $memo, ')
          ..write('status: $status, ')
          ..write('transferable: $transferable, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('originalImageKey: $originalImageKey, ')
          ..write('processedImageKey: $processedImageKey, ')
          ..write('processedLocalImagePath: $processedLocalImagePath, ')
          ..write('outputType: $outputType, ')
          ..write('processStatus: $processStatus, ')
          ..write('processErrorMessage: $processErrorMessage, ')
          ..write('processFailureStage: $processFailureStage, ')
          ..write('usedFrom: $usedFrom, ')
          ..write('usedUntil: $usedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      itemId,
      ownerId,
      title,
      memo,
      status,
      transferable,
      localImagePath,
      originalImageKey,
      processedImageKey,
      processedLocalImagePath,
      outputType,
      processStatus,
      processErrorMessage,
      processFailureStage,
      usedFrom,
      usedUntil,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.itemId == this.itemId &&
          other.ownerId == this.ownerId &&
          other.title == this.title &&
          other.memo == this.memo &&
          other.status == this.status &&
          other.transferable == this.transferable &&
          other.localImagePath == this.localImagePath &&
          other.originalImageKey == this.originalImageKey &&
          other.processedImageKey == this.processedImageKey &&
          other.processedLocalImagePath == this.processedLocalImagePath &&
          other.outputType == this.outputType &&
          other.processStatus == this.processStatus &&
          other.processErrorMessage == this.processErrorMessage &&
          other.processFailureStage == this.processFailureStage &&
          other.usedFrom == this.usedFrom &&
          other.usedUntil == this.usedUntil &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> itemId;
  final Value<String> ownerId;
  final Value<String> title;
  final Value<String> memo;
  final Value<String> status;
  final Value<bool> transferable;
  final Value<String?> localImagePath;
  final Value<String?> originalImageKey;
  final Value<String?> processedImageKey;
  final Value<String?> processedLocalImagePath;
  final Value<String> outputType;
  final Value<String> processStatus;
  final Value<String?> processErrorMessage;
  final Value<String?> processFailureStage;
  final Value<DateTime?> usedFrom;
  final Value<DateTime?> usedUntil;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ItemsCompanion({
    this.itemId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.title = const Value.absent(),
    this.memo = const Value.absent(),
    this.status = const Value.absent(),
    this.transferable = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.originalImageKey = const Value.absent(),
    this.processedImageKey = const Value.absent(),
    this.processedLocalImagePath = const Value.absent(),
    this.outputType = const Value.absent(),
    this.processStatus = const Value.absent(),
    this.processErrorMessage = const Value.absent(),
    this.processFailureStage = const Value.absent(),
    this.usedFrom = const Value.absent(),
    this.usedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String itemId,
    this.ownerId = const Value.absent(),
    required String title,
    this.memo = const Value.absent(),
    this.status = const Value.absent(),
    this.transferable = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.originalImageKey = const Value.absent(),
    this.processedImageKey = const Value.absent(),
    this.processedLocalImagePath = const Value.absent(),
    this.outputType = const Value.absent(),
    this.processStatus = const Value.absent(),
    this.processErrorMessage = const Value.absent(),
    this.processFailureStage = const Value.absent(),
    this.usedFrom = const Value.absent(),
    this.usedUntil = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Item> custom({
    Expression<String>? itemId,
    Expression<String>? ownerId,
    Expression<String>? title,
    Expression<String>? memo,
    Expression<String>? status,
    Expression<bool>? transferable,
    Expression<String>? localImagePath,
    Expression<String>? originalImageKey,
    Expression<String>? processedImageKey,
    Expression<String>? processedLocalImagePath,
    Expression<String>? outputType,
    Expression<String>? processStatus,
    Expression<String>? processErrorMessage,
    Expression<String>? processFailureStage,
    Expression<DateTime>? usedFrom,
    Expression<DateTime>? usedUntil,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (ownerId != null) 'owner_id': ownerId,
      if (title != null) 'title': title,
      if (memo != null) 'memo': memo,
      if (status != null) 'status': status,
      if (transferable != null) 'transferable': transferable,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (originalImageKey != null) 'original_image_key': originalImageKey,
      if (processedImageKey != null) 'processed_image_key': processedImageKey,
      if (processedLocalImagePath != null)
        'processed_local_image_path': processedLocalImagePath,
      if (outputType != null) 'output_type': outputType,
      if (processStatus != null) 'process_status': processStatus,
      if (processErrorMessage != null)
        'process_error_message': processErrorMessage,
      if (processFailureStage != null)
        'process_failure_stage': processFailureStage,
      if (usedFrom != null) 'used_from': usedFrom,
      if (usedUntil != null) 'used_until': usedUntil,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? ownerId,
      Value<String>? title,
      Value<String>? memo,
      Value<String>? status,
      Value<bool>? transferable,
      Value<String?>? localImagePath,
      Value<String?>? originalImageKey,
      Value<String?>? processedImageKey,
      Value<String?>? processedLocalImagePath,
      Value<String>? outputType,
      Value<String>? processStatus,
      Value<String?>? processErrorMessage,
      Value<String?>? processFailureStage,
      Value<DateTime?>? usedFrom,
      Value<DateTime?>? usedUntil,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ItemsCompanion(
      itemId: itemId ?? this.itemId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      transferable: transferable ?? this.transferable,
      localImagePath: localImagePath ?? this.localImagePath,
      originalImageKey: originalImageKey ?? this.originalImageKey,
      processedImageKey: processedImageKey ?? this.processedImageKey,
      processedLocalImagePath:
          processedLocalImagePath ?? this.processedLocalImagePath,
      outputType: outputType ?? this.outputType,
      processStatus: processStatus ?? this.processStatus,
      processErrorMessage: processErrorMessage ?? this.processErrorMessage,
      processFailureStage: processFailureStage ?? this.processFailureStage,
      usedFrom: usedFrom ?? this.usedFrom,
      usedUntil: usedUntil ?? this.usedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (transferable.present) {
      map['transferable'] = Variable<bool>(transferable.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (originalImageKey.present) {
      map['original_image_key'] = Variable<String>(originalImageKey.value);
    }
    if (processedImageKey.present) {
      map['processed_image_key'] = Variable<String>(processedImageKey.value);
    }
    if (processedLocalImagePath.present) {
      map['processed_local_image_path'] =
          Variable<String>(processedLocalImagePath.value);
    }
    if (outputType.present) {
      map['output_type'] = Variable<String>(outputType.value);
    }
    if (processStatus.present) {
      map['process_status'] = Variable<String>(processStatus.value);
    }
    if (processErrorMessage.present) {
      map['process_error_message'] =
          Variable<String>(processErrorMessage.value);
    }
    if (processFailureStage.present) {
      map['process_failure_stage'] =
          Variable<String>(processFailureStage.value);
    }
    if (usedFrom.present) {
      map['used_from'] = Variable<DateTime>(usedFrom.value);
    }
    if (usedUntil.present) {
      map['used_until'] = Variable<DateTime>(usedUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('ItemsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('memo: $memo, ')
          ..write('status: $status, ')
          ..write('transferable: $transferable, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('originalImageKey: $originalImageKey, ')
          ..write('processedImageKey: $processedImageKey, ')
          ..write('processedLocalImagePath: $processedLocalImagePath, ')
          ..write('outputType: $outputType, ')
          ..write('processStatus: $processStatus, ')
          ..write('processErrorMessage: $processErrorMessage, ')
          ..write('processFailureStage: $processFailureStage, ')
          ..write('usedFrom: $usedFrom, ')
          ..write('usedUntil: $usedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemMediaTable extends ItemMedia
    with TableInfo<$ItemMediaTable, ItemMediaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemMediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
      'media_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES items (item_id) ON DELETE CASCADE'));
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storageKeyMeta =
      const VerificationMeta('storageKey');
  @override
  late final GeneratedColumn<String> storageKey = GeneratedColumn<String>(
      'storage_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [mediaId, itemId, mediaType, localPath, storageKey, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_media';
  @override
  VerificationContext validateIntegrity(Insertable<ItemMediaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('storage_key')) {
      context.handle(
          _storageKeyMeta,
          storageKey.isAcceptableOrUnknown(
              data['storage_key']!, _storageKeyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  ItemMediaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemMediaRow(
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      storageKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_key']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ItemMediaTable createAlias(String alias) {
    return $ItemMediaTable(attachedDatabase, alias);
  }
}

class ItemMediaRow extends DataClass implements Insertable<ItemMediaRow> {
  final String mediaId;
  final String itemId;
  final String mediaType;
  final String localPath;
  final String? storageKey;
  final DateTime createdAt;
  const ItemMediaRow(
      {required this.mediaId,
      required this.itemId,
      required this.mediaType,
      required this.localPath,
      this.storageKey,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['item_id'] = Variable<String>(itemId);
    map['media_type'] = Variable<String>(mediaType);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || storageKey != null) {
      map['storage_key'] = Variable<String>(storageKey);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ItemMediaCompanion toCompanion(bool nullToAbsent) {
    return ItemMediaCompanion(
      mediaId: Value(mediaId),
      itemId: Value(itemId),
      mediaType: Value(mediaType),
      localPath: Value(localPath),
      storageKey: storageKey == null && nullToAbsent
          ? const Value.absent()
          : Value(storageKey),
      createdAt: Value(createdAt),
    );
  }

  factory ItemMediaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemMediaRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      localPath: serializer.fromJson<String>(json['localPath']),
      storageKey: serializer.fromJson<String?>(json['storageKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'itemId': serializer.toJson<String>(itemId),
      'mediaType': serializer.toJson<String>(mediaType),
      'localPath': serializer.toJson<String>(localPath),
      'storageKey': serializer.toJson<String?>(storageKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ItemMediaRow copyWith(
          {String? mediaId,
          String? itemId,
          String? mediaType,
          String? localPath,
          Value<String?> storageKey = const Value.absent(),
          DateTime? createdAt}) =>
      ItemMediaRow(
        mediaId: mediaId ?? this.mediaId,
        itemId: itemId ?? this.itemId,
        mediaType: mediaType ?? this.mediaType,
        localPath: localPath ?? this.localPath,
        storageKey: storageKey.present ? storageKey.value : this.storageKey,
        createdAt: createdAt ?? this.createdAt,
      );
  ItemMediaRow copyWithCompanion(ItemMediaCompanion data) {
    return ItemMediaRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      storageKey:
          data.storageKey.present ? data.storageKey.value : this.storageKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemMediaRow(')
          ..write('mediaId: $mediaId, ')
          ..write('itemId: $itemId, ')
          ..write('mediaType: $mediaType, ')
          ..write('localPath: $localPath, ')
          ..write('storageKey: $storageKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(mediaId, itemId, mediaType, localPath, storageKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemMediaRow &&
          other.mediaId == this.mediaId &&
          other.itemId == this.itemId &&
          other.mediaType == this.mediaType &&
          other.localPath == this.localPath &&
          other.storageKey == this.storageKey &&
          other.createdAt == this.createdAt);
}

class ItemMediaCompanion extends UpdateCompanion<ItemMediaRow> {
  final Value<String> mediaId;
  final Value<String> itemId;
  final Value<String> mediaType;
  final Value<String> localPath;
  final Value<String?> storageKey;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ItemMediaCompanion({
    this.mediaId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.localPath = const Value.absent(),
    this.storageKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemMediaCompanion.insert({
    required String mediaId,
    required String itemId,
    required String mediaType,
    required String localPath,
    this.storageKey = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : mediaId = Value(mediaId),
        itemId = Value(itemId),
        mediaType = Value(mediaType),
        localPath = Value(localPath),
        createdAt = Value(createdAt);
  static Insertable<ItemMediaRow> custom({
    Expression<String>? mediaId,
    Expression<String>? itemId,
    Expression<String>? mediaType,
    Expression<String>? localPath,
    Expression<String>? storageKey,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (itemId != null) 'item_id': itemId,
      if (mediaType != null) 'media_type': mediaType,
      if (localPath != null) 'local_path': localPath,
      if (storageKey != null) 'storage_key': storageKey,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemMediaCompanion copyWith(
      {Value<String>? mediaId,
      Value<String>? itemId,
      Value<String>? mediaType,
      Value<String>? localPath,
      Value<String?>? storageKey,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ItemMediaCompanion(
      mediaId: mediaId ?? this.mediaId,
      itemId: itemId ?? this.itemId,
      mediaType: mediaType ?? this.mediaType,
      localPath: localPath ?? this.localPath,
      storageKey: storageKey ?? this.storageKey,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (storageKey.present) {
      map['storage_key'] = Variable<String>(storageKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemMediaCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('itemId: $itemId, ')
          ..write('mediaType: $mediaType, ')
          ..write('localPath: $localPath, ')
          ..write('storageKey: $storageKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemAvatarLinksTable extends ItemAvatarLinks
    with TableInfo<$ItemAvatarLinksTable, ItemAvatarLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemAvatarLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES items (item_id) ON DELETE CASCADE'));
  static const VerificationMeta _avatarIdMeta =
      const VerificationMeta('avatarId');
  @override
  late final GeneratedColumn<String> avatarId = GeneratedColumn<String>(
      'avatar_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES avatars (avatar_id) ON DELETE CASCADE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [itemId, avatarId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_avatar_links';
  @override
  VerificationContext validateIntegrity(Insertable<ItemAvatarLinkRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('avatar_id')) {
      context.handle(_avatarIdMeta,
          avatarId.isAcceptableOrUnknown(data['avatar_id']!, _avatarIdMeta));
    } else if (isInserting) {
      context.missing(_avatarIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, avatarId};
  @override
  ItemAvatarLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemAvatarLinkRow(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      avatarId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ItemAvatarLinksTable createAlias(String alias) {
    return $ItemAvatarLinksTable(attachedDatabase, alias);
  }
}

class ItemAvatarLinkRow extends DataClass
    implements Insertable<ItemAvatarLinkRow> {
  final String itemId;
  final String avatarId;
  final DateTime createdAt;
  const ItemAvatarLinkRow(
      {required this.itemId, required this.avatarId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['avatar_id'] = Variable<String>(avatarId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ItemAvatarLinksCompanion toCompanion(bool nullToAbsent) {
    return ItemAvatarLinksCompanion(
      itemId: Value(itemId),
      avatarId: Value(avatarId),
      createdAt: Value(createdAt),
    );
  }

  factory ItemAvatarLinkRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemAvatarLinkRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      avatarId: serializer.fromJson<String>(json['avatarId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'avatarId': serializer.toJson<String>(avatarId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ItemAvatarLinkRow copyWith(
          {String? itemId, String? avatarId, DateTime? createdAt}) =>
      ItemAvatarLinkRow(
        itemId: itemId ?? this.itemId,
        avatarId: avatarId ?? this.avatarId,
        createdAt: createdAt ?? this.createdAt,
      );
  ItemAvatarLinkRow copyWithCompanion(ItemAvatarLinksCompanion data) {
    return ItemAvatarLinkRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      avatarId: data.avatarId.present ? data.avatarId.value : this.avatarId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemAvatarLinkRow(')
          ..write('itemId: $itemId, ')
          ..write('avatarId: $avatarId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, avatarId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemAvatarLinkRow &&
          other.itemId == this.itemId &&
          other.avatarId == this.avatarId &&
          other.createdAt == this.createdAt);
}

class ItemAvatarLinksCompanion extends UpdateCompanion<ItemAvatarLinkRow> {
  final Value<String> itemId;
  final Value<String> avatarId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ItemAvatarLinksCompanion({
    this.itemId = const Value.absent(),
    this.avatarId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemAvatarLinksCompanion.insert({
    required String itemId,
    required String avatarId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        avatarId = Value(avatarId),
        createdAt = Value(createdAt);
  static Insertable<ItemAvatarLinkRow> custom({
    Expression<String>? itemId,
    Expression<String>? avatarId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (avatarId != null) 'avatar_id': avatarId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemAvatarLinksCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? avatarId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ItemAvatarLinksCompanion(
      itemId: itemId ?? this.itemId,
      avatarId: avatarId ?? this.avatarId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (avatarId.present) {
      map['avatar_id'] = Variable<String>(avatarId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemAvatarLinksCompanion(')
          ..write('itemId: $itemId, ')
          ..write('avatarId: $avatarId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomObjectsTable extends RoomObjects
    with TableInfo<$RoomObjectsTable, RoomObjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomObjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _objectIdMeta =
      const VerificationMeta('objectId');
  @override
  late final GeneratedColumn<String> objectId = GeneratedColumn<String>(
      'object_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_profile'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rooms (room_id) ON DELETE CASCADE'),
      defaultValue: const Constant('simple_room'));
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES items (item_id) ON DELETE CASCADE'));
  static const VerificationMeta _objectTypeMeta =
      const VerificationMeta('objectType');
  @override
  late final GeneratedColumn<String> objectType = GeneratedColumn<String>(
      'object_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('item_plane'));
  static const VerificationMeta _assetKeyMeta =
      const VerificationMeta('assetKey');
  @override
  late final GeneratedColumn<String> assetKey = GeneratedColumn<String>(
      'asset_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localAssetPathMeta =
      const VerificationMeta('localAssetPath');
  @override
  late final GeneratedColumn<String> localAssetPath = GeneratedColumn<String>(
      'local_asset_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageKeyMeta =
      const VerificationMeta('storageKey');
  @override
  late final GeneratedColumn<String> storageKey = GeneratedColumn<String>(
      'storage_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _placementSurfaceMeta =
      const VerificationMeta('placementSurface');
  @override
  late final GeneratedColumn<String> placementSurface = GeneratedColumn<String>(
      'placement_surface', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('floor'));
  static const VerificationMeta _gridXMeta = const VerificationMeta('gridX');
  @override
  late final GeneratedColumn<int> gridX = GeneratedColumn<int>(
      'grid_x', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _gridYMeta = const VerificationMeta('gridY');
  @override
  late final GeneratedColumn<int> gridY = GeneratedColumn<int>(
      'grid_y', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _gridZMeta = const VerificationMeta('gridZ');
  @override
  late final GeneratedColumn<int> gridZ = GeneratedColumn<int>(
      'grid_z', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _spanXMeta = const VerificationMeta('spanX');
  @override
  late final GeneratedColumn<int> spanX = GeneratedColumn<int>(
      'span_x', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _spanYMeta = const VerificationMeta('spanY');
  @override
  late final GeneratedColumn<int> spanY = GeneratedColumn<int>(
      'span_y', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _spanZMeta = const VerificationMeta('spanZ');
  @override
  late final GeneratedColumn<int> spanZ = GeneratedColumn<int>(
      'span_z', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _gridVersionMeta =
      const VerificationMeta('gridVersion');
  @override
  late final GeneratedColumn<int> gridVersion = GeneratedColumn<int>(
      'grid_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _posXMeta = const VerificationMeta('posX');
  @override
  late final GeneratedColumn<double> posX = GeneratedColumn<double>(
      'pos_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _posYMeta = const VerificationMeta('posY');
  @override
  late final GeneratedColumn<double> posY = GeneratedColumn<double>(
      'pos_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _posZMeta = const VerificationMeta('posZ');
  @override
  late final GeneratedColumn<double> posZ = GeneratedColumn<double>(
      'pos_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _scaleMeta = const VerificationMeta('scale');
  @override
  late final GeneratedColumn<double> scale = GeneratedColumn<double>(
      'scale', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _scaleXMeta = const VerificationMeta('scaleX');
  @override
  late final GeneratedColumn<double> scaleX = GeneratedColumn<double>(
      'scale_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _scaleYMeta = const VerificationMeta('scaleY');
  @override
  late final GeneratedColumn<double> scaleY = GeneratedColumn<double>(
      'scale_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _scaleZMeta = const VerificationMeta('scaleZ');
  @override
  late final GeneratedColumn<double> scaleZ = GeneratedColumn<double>(
      'scale_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _rotationXMeta =
      const VerificationMeta('rotationX');
  @override
  late final GeneratedColumn<double> rotationX = GeneratedColumn<double>(
      'rotation_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _rotationYMeta =
      const VerificationMeta('rotationY');
  @override
  late final GeneratedColumn<double> rotationY = GeneratedColumn<double>(
      'rotation_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _rotationZMeta =
      const VerificationMeta('rotationZ');
  @override
  late final GeneratedColumn<double> rotationZ = GeneratedColumn<double>(
      'rotation_z', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _isPlacedMeta =
      const VerificationMeta('isPlaced');
  @override
  late final GeneratedColumn<bool> isPlaced = GeneratedColumn<bool>(
      'is_placed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_placed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _originalWidthMeta =
      const VerificationMeta('originalWidth');
  @override
  late final GeneratedColumn<int> originalWidth = GeneratedColumn<int>(
      'original_width', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originalHeightMeta =
      const VerificationMeta('originalHeight');
  @override
  late final GeneratedColumn<int> originalHeight = GeneratedColumn<int>(
      'original_height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _footprintWidthMeta =
      const VerificationMeta('footprintWidth');
  @override
  late final GeneratedColumn<double> footprintWidth = GeneratedColumn<double>(
      'footprint_width', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _footprintHeightMeta =
      const VerificationMeta('footprintHeight');
  @override
  late final GeneratedColumn<double> footprintHeight = GeneratedColumn<double>(
      'footprint_height', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _footprintDepthMeta =
      const VerificationMeta('footprintDepth');
  @override
  late final GeneratedColumn<double> footprintDepth = GeneratedColumn<double>(
      'footprint_depth', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  @override
  List<GeneratedColumn> get $columns => [
        objectId,
        profileId,
        roomId,
        itemId,
        objectType,
        assetKey,
        localAssetPath,
        storageKey,
        placementSurface,
        gridX,
        gridY,
        gridZ,
        spanX,
        spanY,
        spanZ,
        gridVersion,
        posX,
        posY,
        posZ,
        scale,
        scaleX,
        scaleY,
        scaleZ,
        rotationX,
        rotationY,
        rotationZ,
        isPlaced,
        originalWidth,
        originalHeight,
        footprintWidth,
        footprintHeight,
        footprintDepth,
        createdAt,
        updatedAt,
        deletedAt,
        version,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'room_objects';
  @override
  VerificationContext validateIntegrity(Insertable<RoomObjectRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('object_id')) {
      context.handle(_objectIdMeta,
          objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta));
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    }
    if (data.containsKey('object_type')) {
      context.handle(
          _objectTypeMeta,
          objectType.isAcceptableOrUnknown(
              data['object_type']!, _objectTypeMeta));
    }
    if (data.containsKey('asset_key')) {
      context.handle(_assetKeyMeta,
          assetKey.isAcceptableOrUnknown(data['asset_key']!, _assetKeyMeta));
    }
    if (data.containsKey('local_asset_path')) {
      context.handle(
          _localAssetPathMeta,
          localAssetPath.isAcceptableOrUnknown(
              data['local_asset_path']!, _localAssetPathMeta));
    }
    if (data.containsKey('storage_key')) {
      context.handle(
          _storageKeyMeta,
          storageKey.isAcceptableOrUnknown(
              data['storage_key']!, _storageKeyMeta));
    }
    if (data.containsKey('placement_surface')) {
      context.handle(
          _placementSurfaceMeta,
          placementSurface.isAcceptableOrUnknown(
              data['placement_surface']!, _placementSurfaceMeta));
    }
    if (data.containsKey('grid_x')) {
      context.handle(
          _gridXMeta, gridX.isAcceptableOrUnknown(data['grid_x']!, _gridXMeta));
    }
    if (data.containsKey('grid_y')) {
      context.handle(
          _gridYMeta, gridY.isAcceptableOrUnknown(data['grid_y']!, _gridYMeta));
    }
    if (data.containsKey('grid_z')) {
      context.handle(
          _gridZMeta, gridZ.isAcceptableOrUnknown(data['grid_z']!, _gridZMeta));
    }
    if (data.containsKey('span_x')) {
      context.handle(
          _spanXMeta, spanX.isAcceptableOrUnknown(data['span_x']!, _spanXMeta));
    }
    if (data.containsKey('span_y')) {
      context.handle(
          _spanYMeta, spanY.isAcceptableOrUnknown(data['span_y']!, _spanYMeta));
    }
    if (data.containsKey('span_z')) {
      context.handle(
          _spanZMeta, spanZ.isAcceptableOrUnknown(data['span_z']!, _spanZMeta));
    }
    if (data.containsKey('grid_version')) {
      context.handle(
          _gridVersionMeta,
          gridVersion.isAcceptableOrUnknown(
              data['grid_version']!, _gridVersionMeta));
    }
    if (data.containsKey('pos_x')) {
      context.handle(
          _posXMeta, posX.isAcceptableOrUnknown(data['pos_x']!, _posXMeta));
    }
    if (data.containsKey('pos_y')) {
      context.handle(
          _posYMeta, posY.isAcceptableOrUnknown(data['pos_y']!, _posYMeta));
    }
    if (data.containsKey('pos_z')) {
      context.handle(
          _posZMeta, posZ.isAcceptableOrUnknown(data['pos_z']!, _posZMeta));
    }
    if (data.containsKey('scale')) {
      context.handle(
          _scaleMeta, scale.isAcceptableOrUnknown(data['scale']!, _scaleMeta));
    }
    if (data.containsKey('scale_x')) {
      context.handle(_scaleXMeta,
          scaleX.isAcceptableOrUnknown(data['scale_x']!, _scaleXMeta));
    }
    if (data.containsKey('scale_y')) {
      context.handle(_scaleYMeta,
          scaleY.isAcceptableOrUnknown(data['scale_y']!, _scaleYMeta));
    }
    if (data.containsKey('scale_z')) {
      context.handle(_scaleZMeta,
          scaleZ.isAcceptableOrUnknown(data['scale_z']!, _scaleZMeta));
    }
    if (data.containsKey('rotation_x')) {
      context.handle(_rotationXMeta,
          rotationX.isAcceptableOrUnknown(data['rotation_x']!, _rotationXMeta));
    }
    if (data.containsKey('rotation_y')) {
      context.handle(_rotationYMeta,
          rotationY.isAcceptableOrUnknown(data['rotation_y']!, _rotationYMeta));
    }
    if (data.containsKey('rotation_z')) {
      context.handle(_rotationZMeta,
          rotationZ.isAcceptableOrUnknown(data['rotation_z']!, _rotationZMeta));
    }
    if (data.containsKey('is_placed')) {
      context.handle(_isPlacedMeta,
          isPlaced.isAcceptableOrUnknown(data['is_placed']!, _isPlacedMeta));
    }
    if (data.containsKey('original_width')) {
      context.handle(
          _originalWidthMeta,
          originalWidth.isAcceptableOrUnknown(
              data['original_width']!, _originalWidthMeta));
    }
    if (data.containsKey('original_height')) {
      context.handle(
          _originalHeightMeta,
          originalHeight.isAcceptableOrUnknown(
              data['original_height']!, _originalHeightMeta));
    }
    if (data.containsKey('footprint_width')) {
      context.handle(
          _footprintWidthMeta,
          footprintWidth.isAcceptableOrUnknown(
              data['footprint_width']!, _footprintWidthMeta));
    }
    if (data.containsKey('footprint_height')) {
      context.handle(
          _footprintHeightMeta,
          footprintHeight.isAcceptableOrUnknown(
              data['footprint_height']!, _footprintHeightMeta));
    }
    if (data.containsKey('footprint_depth')) {
      context.handle(
          _footprintDepthMeta,
          footprintDepth.isAcceptableOrUnknown(
              data['footprint_depth']!, _footprintDepthMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {objectId};
  @override
  RoomObjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomObjectRow(
      objectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}object_id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id']),
      objectType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}object_type'])!,
      assetKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_key']),
      localAssetPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_asset_path']),
      storageKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_key']),
      placementSurface: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}placement_surface'])!,
      gridX: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_x'])!,
      gridY: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_y'])!,
      gridZ: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_z'])!,
      spanX: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}span_x'])!,
      spanY: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}span_y'])!,
      spanZ: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}span_z'])!,
      gridVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_version'])!,
      posX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_x'])!,
      posY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_y'])!,
      posZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_z'])!,
      scale: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scale'])!,
      scaleX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scale_x'])!,
      scaleY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scale_y'])!,
      scaleZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scale_z'])!,
      rotationX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rotation_x'])!,
      rotationY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rotation_y'])!,
      rotationZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rotation_z'])!,
      isPlaced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_placed'])!,
      originalWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}original_width']),
      originalHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}original_height']),
      footprintWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}footprint_width']),
      footprintHeight: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}footprint_height']),
      footprintDepth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}footprint_depth']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $RoomObjectsTable createAlias(String alias) {
    return $RoomObjectsTable(attachedDatabase, alias);
  }
}

class RoomObjectRow extends DataClass implements Insertable<RoomObjectRow> {
  final String objectId;
  final String profileId;
  final String roomId;
  final String? itemId;
  final String objectType;
  final String? assetKey;
  final String? localAssetPath;
  final String? storageKey;
  final String placementSurface;
  final int gridX;
  final int gridY;
  final int gridZ;
  final int spanX;
  final int spanY;
  final int spanZ;
  final int gridVersion;
  final double posX;
  final double posY;
  final double posZ;
  final double scale;
  final double scaleX;
  final double scaleY;
  final double scaleZ;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final bool isPlaced;
  final int? originalWidth;
  final int? originalHeight;
  final double? footprintWidth;
  final double? footprintHeight;
  final double? footprintDepth;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String syncState;
  const RoomObjectRow(
      {required this.objectId,
      required this.profileId,
      required this.roomId,
      this.itemId,
      required this.objectType,
      this.assetKey,
      this.localAssetPath,
      this.storageKey,
      required this.placementSurface,
      required this.gridX,
      required this.gridY,
      required this.gridZ,
      required this.spanX,
      required this.spanY,
      required this.spanZ,
      required this.gridVersion,
      required this.posX,
      required this.posY,
      required this.posZ,
      required this.scale,
      required this.scaleX,
      required this.scaleY,
      required this.scaleZ,
      required this.rotationX,
      required this.rotationY,
      required this.rotationZ,
      required this.isPlaced,
      this.originalWidth,
      this.originalHeight,
      this.footprintWidth,
      this.footprintHeight,
      this.footprintDepth,
      this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.version,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['object_id'] = Variable<String>(objectId);
    map['profile_id'] = Variable<String>(profileId);
    map['room_id'] = Variable<String>(roomId);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['object_type'] = Variable<String>(objectType);
    if (!nullToAbsent || assetKey != null) {
      map['asset_key'] = Variable<String>(assetKey);
    }
    if (!nullToAbsent || localAssetPath != null) {
      map['local_asset_path'] = Variable<String>(localAssetPath);
    }
    if (!nullToAbsent || storageKey != null) {
      map['storage_key'] = Variable<String>(storageKey);
    }
    map['placement_surface'] = Variable<String>(placementSurface);
    map['grid_x'] = Variable<int>(gridX);
    map['grid_y'] = Variable<int>(gridY);
    map['grid_z'] = Variable<int>(gridZ);
    map['span_x'] = Variable<int>(spanX);
    map['span_y'] = Variable<int>(spanY);
    map['span_z'] = Variable<int>(spanZ);
    map['grid_version'] = Variable<int>(gridVersion);
    map['pos_x'] = Variable<double>(posX);
    map['pos_y'] = Variable<double>(posY);
    map['pos_z'] = Variable<double>(posZ);
    map['scale'] = Variable<double>(scale);
    map['scale_x'] = Variable<double>(scaleX);
    map['scale_y'] = Variable<double>(scaleY);
    map['scale_z'] = Variable<double>(scaleZ);
    map['rotation_x'] = Variable<double>(rotationX);
    map['rotation_y'] = Variable<double>(rotationY);
    map['rotation_z'] = Variable<double>(rotationZ);
    map['is_placed'] = Variable<bool>(isPlaced);
    if (!nullToAbsent || originalWidth != null) {
      map['original_width'] = Variable<int>(originalWidth);
    }
    if (!nullToAbsent || originalHeight != null) {
      map['original_height'] = Variable<int>(originalHeight);
    }
    if (!nullToAbsent || footprintWidth != null) {
      map['footprint_width'] = Variable<double>(footprintWidth);
    }
    if (!nullToAbsent || footprintHeight != null) {
      map['footprint_height'] = Variable<double>(footprintHeight);
    }
    if (!nullToAbsent || footprintDepth != null) {
      map['footprint_depth'] = Variable<double>(footprintDepth);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  RoomObjectsCompanion toCompanion(bool nullToAbsent) {
    return RoomObjectsCompanion(
      objectId: Value(objectId),
      profileId: Value(profileId),
      roomId: Value(roomId),
      itemId:
          itemId == null && nullToAbsent ? const Value.absent() : Value(itemId),
      objectType: Value(objectType),
      assetKey: assetKey == null && nullToAbsent
          ? const Value.absent()
          : Value(assetKey),
      localAssetPath: localAssetPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localAssetPath),
      storageKey: storageKey == null && nullToAbsent
          ? const Value.absent()
          : Value(storageKey),
      placementSurface: Value(placementSurface),
      gridX: Value(gridX),
      gridY: Value(gridY),
      gridZ: Value(gridZ),
      spanX: Value(spanX),
      spanY: Value(spanY),
      spanZ: Value(spanZ),
      gridVersion: Value(gridVersion),
      posX: Value(posX),
      posY: Value(posY),
      posZ: Value(posZ),
      scale: Value(scale),
      scaleX: Value(scaleX),
      scaleY: Value(scaleY),
      scaleZ: Value(scaleZ),
      rotationX: Value(rotationX),
      rotationY: Value(rotationY),
      rotationZ: Value(rotationZ),
      isPlaced: Value(isPlaced),
      originalWidth: originalWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(originalWidth),
      originalHeight: originalHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(originalHeight),
      footprintWidth: footprintWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(footprintWidth),
      footprintHeight: footprintHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(footprintHeight),
      footprintDepth: footprintDepth == null && nullToAbsent
          ? const Value.absent()
          : Value(footprintDepth),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      syncState: Value(syncState),
    );
  }

  factory RoomObjectRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomObjectRow(
      objectId: serializer.fromJson<String>(json['objectId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      objectType: serializer.fromJson<String>(json['objectType']),
      assetKey: serializer.fromJson<String?>(json['assetKey']),
      localAssetPath: serializer.fromJson<String?>(json['localAssetPath']),
      storageKey: serializer.fromJson<String?>(json['storageKey']),
      placementSurface: serializer.fromJson<String>(json['placementSurface']),
      gridX: serializer.fromJson<int>(json['gridX']),
      gridY: serializer.fromJson<int>(json['gridY']),
      gridZ: serializer.fromJson<int>(json['gridZ']),
      spanX: serializer.fromJson<int>(json['spanX']),
      spanY: serializer.fromJson<int>(json['spanY']),
      spanZ: serializer.fromJson<int>(json['spanZ']),
      gridVersion: serializer.fromJson<int>(json['gridVersion']),
      posX: serializer.fromJson<double>(json['posX']),
      posY: serializer.fromJson<double>(json['posY']),
      posZ: serializer.fromJson<double>(json['posZ']),
      scale: serializer.fromJson<double>(json['scale']),
      scaleX: serializer.fromJson<double>(json['scaleX']),
      scaleY: serializer.fromJson<double>(json['scaleY']),
      scaleZ: serializer.fromJson<double>(json['scaleZ']),
      rotationX: serializer.fromJson<double>(json['rotationX']),
      rotationY: serializer.fromJson<double>(json['rotationY']),
      rotationZ: serializer.fromJson<double>(json['rotationZ']),
      isPlaced: serializer.fromJson<bool>(json['isPlaced']),
      originalWidth: serializer.fromJson<int?>(json['originalWidth']),
      originalHeight: serializer.fromJson<int?>(json['originalHeight']),
      footprintWidth: serializer.fromJson<double?>(json['footprintWidth']),
      footprintHeight: serializer.fromJson<double?>(json['footprintHeight']),
      footprintDepth: serializer.fromJson<double?>(json['footprintDepth']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'objectId': serializer.toJson<String>(objectId),
      'profileId': serializer.toJson<String>(profileId),
      'roomId': serializer.toJson<String>(roomId),
      'itemId': serializer.toJson<String?>(itemId),
      'objectType': serializer.toJson<String>(objectType),
      'assetKey': serializer.toJson<String?>(assetKey),
      'localAssetPath': serializer.toJson<String?>(localAssetPath),
      'storageKey': serializer.toJson<String?>(storageKey),
      'placementSurface': serializer.toJson<String>(placementSurface),
      'gridX': serializer.toJson<int>(gridX),
      'gridY': serializer.toJson<int>(gridY),
      'gridZ': serializer.toJson<int>(gridZ),
      'spanX': serializer.toJson<int>(spanX),
      'spanY': serializer.toJson<int>(spanY),
      'spanZ': serializer.toJson<int>(spanZ),
      'gridVersion': serializer.toJson<int>(gridVersion),
      'posX': serializer.toJson<double>(posX),
      'posY': serializer.toJson<double>(posY),
      'posZ': serializer.toJson<double>(posZ),
      'scale': serializer.toJson<double>(scale),
      'scaleX': serializer.toJson<double>(scaleX),
      'scaleY': serializer.toJson<double>(scaleY),
      'scaleZ': serializer.toJson<double>(scaleZ),
      'rotationX': serializer.toJson<double>(rotationX),
      'rotationY': serializer.toJson<double>(rotationY),
      'rotationZ': serializer.toJson<double>(rotationZ),
      'isPlaced': serializer.toJson<bool>(isPlaced),
      'originalWidth': serializer.toJson<int?>(originalWidth),
      'originalHeight': serializer.toJson<int?>(originalHeight),
      'footprintWidth': serializer.toJson<double?>(footprintWidth),
      'footprintHeight': serializer.toJson<double?>(footprintHeight),
      'footprintDepth': serializer.toJson<double?>(footprintDepth),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  RoomObjectRow copyWith(
          {String? objectId,
          String? profileId,
          String? roomId,
          Value<String?> itemId = const Value.absent(),
          String? objectType,
          Value<String?> assetKey = const Value.absent(),
          Value<String?> localAssetPath = const Value.absent(),
          Value<String?> storageKey = const Value.absent(),
          String? placementSurface,
          int? gridX,
          int? gridY,
          int? gridZ,
          int? spanX,
          int? spanY,
          int? spanZ,
          int? gridVersion,
          double? posX,
          double? posY,
          double? posZ,
          double? scale,
          double? scaleX,
          double? scaleY,
          double? scaleZ,
          double? rotationX,
          double? rotationY,
          double? rotationZ,
          bool? isPlaced,
          Value<int?> originalWidth = const Value.absent(),
          Value<int?> originalHeight = const Value.absent(),
          Value<double?> footprintWidth = const Value.absent(),
          Value<double?> footprintHeight = const Value.absent(),
          Value<double?> footprintDepth = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? version,
          String? syncState}) =>
      RoomObjectRow(
        objectId: objectId ?? this.objectId,
        profileId: profileId ?? this.profileId,
        roomId: roomId ?? this.roomId,
        itemId: itemId.present ? itemId.value : this.itemId,
        objectType: objectType ?? this.objectType,
        assetKey: assetKey.present ? assetKey.value : this.assetKey,
        localAssetPath:
            localAssetPath.present ? localAssetPath.value : this.localAssetPath,
        storageKey: storageKey.present ? storageKey.value : this.storageKey,
        placementSurface: placementSurface ?? this.placementSurface,
        gridX: gridX ?? this.gridX,
        gridY: gridY ?? this.gridY,
        gridZ: gridZ ?? this.gridZ,
        spanX: spanX ?? this.spanX,
        spanY: spanY ?? this.spanY,
        spanZ: spanZ ?? this.spanZ,
        gridVersion: gridVersion ?? this.gridVersion,
        posX: posX ?? this.posX,
        posY: posY ?? this.posY,
        posZ: posZ ?? this.posZ,
        scale: scale ?? this.scale,
        scaleX: scaleX ?? this.scaleX,
        scaleY: scaleY ?? this.scaleY,
        scaleZ: scaleZ ?? this.scaleZ,
        rotationX: rotationX ?? this.rotationX,
        rotationY: rotationY ?? this.rotationY,
        rotationZ: rotationZ ?? this.rotationZ,
        isPlaced: isPlaced ?? this.isPlaced,
        originalWidth:
            originalWidth.present ? originalWidth.value : this.originalWidth,
        originalHeight:
            originalHeight.present ? originalHeight.value : this.originalHeight,
        footprintWidth:
            footprintWidth.present ? footprintWidth.value : this.footprintWidth,
        footprintHeight: footprintHeight.present
            ? footprintHeight.value
            : this.footprintHeight,
        footprintDepth:
            footprintDepth.present ? footprintDepth.value : this.footprintDepth,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        version: version ?? this.version,
        syncState: syncState ?? this.syncState,
      );
  RoomObjectRow copyWithCompanion(RoomObjectsCompanion data) {
    return RoomObjectRow(
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      objectType:
          data.objectType.present ? data.objectType.value : this.objectType,
      assetKey: data.assetKey.present ? data.assetKey.value : this.assetKey,
      localAssetPath: data.localAssetPath.present
          ? data.localAssetPath.value
          : this.localAssetPath,
      storageKey:
          data.storageKey.present ? data.storageKey.value : this.storageKey,
      placementSurface: data.placementSurface.present
          ? data.placementSurface.value
          : this.placementSurface,
      gridX: data.gridX.present ? data.gridX.value : this.gridX,
      gridY: data.gridY.present ? data.gridY.value : this.gridY,
      gridZ: data.gridZ.present ? data.gridZ.value : this.gridZ,
      spanX: data.spanX.present ? data.spanX.value : this.spanX,
      spanY: data.spanY.present ? data.spanY.value : this.spanY,
      spanZ: data.spanZ.present ? data.spanZ.value : this.spanZ,
      gridVersion:
          data.gridVersion.present ? data.gridVersion.value : this.gridVersion,
      posX: data.posX.present ? data.posX.value : this.posX,
      posY: data.posY.present ? data.posY.value : this.posY,
      posZ: data.posZ.present ? data.posZ.value : this.posZ,
      scale: data.scale.present ? data.scale.value : this.scale,
      scaleX: data.scaleX.present ? data.scaleX.value : this.scaleX,
      scaleY: data.scaleY.present ? data.scaleY.value : this.scaleY,
      scaleZ: data.scaleZ.present ? data.scaleZ.value : this.scaleZ,
      rotationX: data.rotationX.present ? data.rotationX.value : this.rotationX,
      rotationY: data.rotationY.present ? data.rotationY.value : this.rotationY,
      rotationZ: data.rotationZ.present ? data.rotationZ.value : this.rotationZ,
      isPlaced: data.isPlaced.present ? data.isPlaced.value : this.isPlaced,
      originalWidth: data.originalWidth.present
          ? data.originalWidth.value
          : this.originalWidth,
      originalHeight: data.originalHeight.present
          ? data.originalHeight.value
          : this.originalHeight,
      footprintWidth: data.footprintWidth.present
          ? data.footprintWidth.value
          : this.footprintWidth,
      footprintHeight: data.footprintHeight.present
          ? data.footprintHeight.value
          : this.footprintHeight,
      footprintDepth: data.footprintDepth.present
          ? data.footprintDepth.value
          : this.footprintDepth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomObjectRow(')
          ..write('objectId: $objectId, ')
          ..write('profileId: $profileId, ')
          ..write('roomId: $roomId, ')
          ..write('itemId: $itemId, ')
          ..write('objectType: $objectType, ')
          ..write('assetKey: $assetKey, ')
          ..write('localAssetPath: $localAssetPath, ')
          ..write('storageKey: $storageKey, ')
          ..write('placementSurface: $placementSurface, ')
          ..write('gridX: $gridX, ')
          ..write('gridY: $gridY, ')
          ..write('gridZ: $gridZ, ')
          ..write('spanX: $spanX, ')
          ..write('spanY: $spanY, ')
          ..write('spanZ: $spanZ, ')
          ..write('gridVersion: $gridVersion, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('posZ: $posZ, ')
          ..write('scale: $scale, ')
          ..write('scaleX: $scaleX, ')
          ..write('scaleY: $scaleY, ')
          ..write('scaleZ: $scaleZ, ')
          ..write('rotationX: $rotationX, ')
          ..write('rotationY: $rotationY, ')
          ..write('rotationZ: $rotationZ, ')
          ..write('isPlaced: $isPlaced, ')
          ..write('originalWidth: $originalWidth, ')
          ..write('originalHeight: $originalHeight, ')
          ..write('footprintWidth: $footprintWidth, ')
          ..write('footprintHeight: $footprintHeight, ')
          ..write('footprintDepth: $footprintDepth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        objectId,
        profileId,
        roomId,
        itemId,
        objectType,
        assetKey,
        localAssetPath,
        storageKey,
        placementSurface,
        gridX,
        gridY,
        gridZ,
        spanX,
        spanY,
        spanZ,
        gridVersion,
        posX,
        posY,
        posZ,
        scale,
        scaleX,
        scaleY,
        scaleZ,
        rotationX,
        rotationY,
        rotationZ,
        isPlaced,
        originalWidth,
        originalHeight,
        footprintWidth,
        footprintHeight,
        footprintDepth,
        createdAt,
        updatedAt,
        deletedAt,
        version,
        syncState
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomObjectRow &&
          other.objectId == this.objectId &&
          other.profileId == this.profileId &&
          other.roomId == this.roomId &&
          other.itemId == this.itemId &&
          other.objectType == this.objectType &&
          other.assetKey == this.assetKey &&
          other.localAssetPath == this.localAssetPath &&
          other.storageKey == this.storageKey &&
          other.placementSurface == this.placementSurface &&
          other.gridX == this.gridX &&
          other.gridY == this.gridY &&
          other.gridZ == this.gridZ &&
          other.spanX == this.spanX &&
          other.spanY == this.spanY &&
          other.spanZ == this.spanZ &&
          other.gridVersion == this.gridVersion &&
          other.posX == this.posX &&
          other.posY == this.posY &&
          other.posZ == this.posZ &&
          other.scale == this.scale &&
          other.scaleX == this.scaleX &&
          other.scaleY == this.scaleY &&
          other.scaleZ == this.scaleZ &&
          other.rotationX == this.rotationX &&
          other.rotationY == this.rotationY &&
          other.rotationZ == this.rotationZ &&
          other.isPlaced == this.isPlaced &&
          other.originalWidth == this.originalWidth &&
          other.originalHeight == this.originalHeight &&
          other.footprintWidth == this.footprintWidth &&
          other.footprintHeight == this.footprintHeight &&
          other.footprintDepth == this.footprintDepth &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.syncState == this.syncState);
}

class RoomObjectsCompanion extends UpdateCompanion<RoomObjectRow> {
  final Value<String> objectId;
  final Value<String> profileId;
  final Value<String> roomId;
  final Value<String?> itemId;
  final Value<String> objectType;
  final Value<String?> assetKey;
  final Value<String?> localAssetPath;
  final Value<String?> storageKey;
  final Value<String> placementSurface;
  final Value<int> gridX;
  final Value<int> gridY;
  final Value<int> gridZ;
  final Value<int> spanX;
  final Value<int> spanY;
  final Value<int> spanZ;
  final Value<int> gridVersion;
  final Value<double> posX;
  final Value<double> posY;
  final Value<double> posZ;
  final Value<double> scale;
  final Value<double> scaleX;
  final Value<double> scaleY;
  final Value<double> scaleZ;
  final Value<double> rotationX;
  final Value<double> rotationY;
  final Value<double> rotationZ;
  final Value<bool> isPlaced;
  final Value<int?> originalWidth;
  final Value<int?> originalHeight;
  final Value<double?> footprintWidth;
  final Value<double?> footprintHeight;
  final Value<double?> footprintDepth;
  final Value<DateTime?> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> syncState;
  final Value<int> rowid;
  const RoomObjectsCompanion({
    this.objectId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.objectType = const Value.absent(),
    this.assetKey = const Value.absent(),
    this.localAssetPath = const Value.absent(),
    this.storageKey = const Value.absent(),
    this.placementSurface = const Value.absent(),
    this.gridX = const Value.absent(),
    this.gridY = const Value.absent(),
    this.gridZ = const Value.absent(),
    this.spanX = const Value.absent(),
    this.spanY = const Value.absent(),
    this.spanZ = const Value.absent(),
    this.gridVersion = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.posZ = const Value.absent(),
    this.scale = const Value.absent(),
    this.scaleX = const Value.absent(),
    this.scaleY = const Value.absent(),
    this.scaleZ = const Value.absent(),
    this.rotationX = const Value.absent(),
    this.rotationY = const Value.absent(),
    this.rotationZ = const Value.absent(),
    this.isPlaced = const Value.absent(),
    this.originalWidth = const Value.absent(),
    this.originalHeight = const Value.absent(),
    this.footprintWidth = const Value.absent(),
    this.footprintHeight = const Value.absent(),
    this.footprintDepth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomObjectsCompanion.insert({
    required String objectId,
    this.profileId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.objectType = const Value.absent(),
    this.assetKey = const Value.absent(),
    this.localAssetPath = const Value.absent(),
    this.storageKey = const Value.absent(),
    this.placementSurface = const Value.absent(),
    this.gridX = const Value.absent(),
    this.gridY = const Value.absent(),
    this.gridZ = const Value.absent(),
    this.spanX = const Value.absent(),
    this.spanY = const Value.absent(),
    this.spanZ = const Value.absent(),
    this.gridVersion = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.posZ = const Value.absent(),
    this.scale = const Value.absent(),
    this.scaleX = const Value.absent(),
    this.scaleY = const Value.absent(),
    this.scaleZ = const Value.absent(),
    this.rotationX = const Value.absent(),
    this.rotationY = const Value.absent(),
    this.rotationZ = const Value.absent(),
    this.isPlaced = const Value.absent(),
    this.originalWidth = const Value.absent(),
    this.originalHeight = const Value.absent(),
    this.footprintWidth = const Value.absent(),
    this.footprintHeight = const Value.absent(),
    this.footprintDepth = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : objectId = Value(objectId),
        updatedAt = Value(updatedAt);
  static Insertable<RoomObjectRow> custom({
    Expression<String>? objectId,
    Expression<String>? profileId,
    Expression<String>? roomId,
    Expression<String>? itemId,
    Expression<String>? objectType,
    Expression<String>? assetKey,
    Expression<String>? localAssetPath,
    Expression<String>? storageKey,
    Expression<String>? placementSurface,
    Expression<int>? gridX,
    Expression<int>? gridY,
    Expression<int>? gridZ,
    Expression<int>? spanX,
    Expression<int>? spanY,
    Expression<int>? spanZ,
    Expression<int>? gridVersion,
    Expression<double>? posX,
    Expression<double>? posY,
    Expression<double>? posZ,
    Expression<double>? scale,
    Expression<double>? scaleX,
    Expression<double>? scaleY,
    Expression<double>? scaleZ,
    Expression<double>? rotationX,
    Expression<double>? rotationY,
    Expression<double>? rotationZ,
    Expression<bool>? isPlaced,
    Expression<int>? originalWidth,
    Expression<int>? originalHeight,
    Expression<double>? footprintWidth,
    Expression<double>? footprintHeight,
    Expression<double>? footprintDepth,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (objectId != null) 'object_id': objectId,
      if (profileId != null) 'profile_id': profileId,
      if (roomId != null) 'room_id': roomId,
      if (itemId != null) 'item_id': itemId,
      if (objectType != null) 'object_type': objectType,
      if (assetKey != null) 'asset_key': assetKey,
      if (localAssetPath != null) 'local_asset_path': localAssetPath,
      if (storageKey != null) 'storage_key': storageKey,
      if (placementSurface != null) 'placement_surface': placementSurface,
      if (gridX != null) 'grid_x': gridX,
      if (gridY != null) 'grid_y': gridY,
      if (gridZ != null) 'grid_z': gridZ,
      if (spanX != null) 'span_x': spanX,
      if (spanY != null) 'span_y': spanY,
      if (spanZ != null) 'span_z': spanZ,
      if (gridVersion != null) 'grid_version': gridVersion,
      if (posX != null) 'pos_x': posX,
      if (posY != null) 'pos_y': posY,
      if (posZ != null) 'pos_z': posZ,
      if (scale != null) 'scale': scale,
      if (scaleX != null) 'scale_x': scaleX,
      if (scaleY != null) 'scale_y': scaleY,
      if (scaleZ != null) 'scale_z': scaleZ,
      if (rotationX != null) 'rotation_x': rotationX,
      if (rotationY != null) 'rotation_y': rotationY,
      if (rotationZ != null) 'rotation_z': rotationZ,
      if (isPlaced != null) 'is_placed': isPlaced,
      if (originalWidth != null) 'original_width': originalWidth,
      if (originalHeight != null) 'original_height': originalHeight,
      if (footprintWidth != null) 'footprint_width': footprintWidth,
      if (footprintHeight != null) 'footprint_height': footprintHeight,
      if (footprintDepth != null) 'footprint_depth': footprintDepth,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomObjectsCompanion copyWith(
      {Value<String>? objectId,
      Value<String>? profileId,
      Value<String>? roomId,
      Value<String?>? itemId,
      Value<String>? objectType,
      Value<String?>? assetKey,
      Value<String?>? localAssetPath,
      Value<String?>? storageKey,
      Value<String>? placementSurface,
      Value<int>? gridX,
      Value<int>? gridY,
      Value<int>? gridZ,
      Value<int>? spanX,
      Value<int>? spanY,
      Value<int>? spanZ,
      Value<int>? gridVersion,
      Value<double>? posX,
      Value<double>? posY,
      Value<double>? posZ,
      Value<double>? scale,
      Value<double>? scaleX,
      Value<double>? scaleY,
      Value<double>? scaleZ,
      Value<double>? rotationX,
      Value<double>? rotationY,
      Value<double>? rotationZ,
      Value<bool>? isPlaced,
      Value<int?>? originalWidth,
      Value<int?>? originalHeight,
      Value<double?>? footprintWidth,
      Value<double?>? footprintHeight,
      Value<double?>? footprintDepth,
      Value<DateTime?>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? version,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return RoomObjectsCompanion(
      objectId: objectId ?? this.objectId,
      profileId: profileId ?? this.profileId,
      roomId: roomId ?? this.roomId,
      itemId: itemId ?? this.itemId,
      objectType: objectType ?? this.objectType,
      assetKey: assetKey ?? this.assetKey,
      localAssetPath: localAssetPath ?? this.localAssetPath,
      storageKey: storageKey ?? this.storageKey,
      placementSurface: placementSurface ?? this.placementSurface,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      gridZ: gridZ ?? this.gridZ,
      spanX: spanX ?? this.spanX,
      spanY: spanY ?? this.spanY,
      spanZ: spanZ ?? this.spanZ,
      gridVersion: gridVersion ?? this.gridVersion,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      posZ: posZ ?? this.posZ,
      scale: scale ?? this.scale,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      scaleZ: scaleZ ?? this.scaleZ,
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      isPlaced: isPlaced ?? this.isPlaced,
      originalWidth: originalWidth ?? this.originalWidth,
      originalHeight: originalHeight ?? this.originalHeight,
      footprintWidth: footprintWidth ?? this.footprintWidth,
      footprintHeight: footprintHeight ?? this.footprintHeight,
      footprintDepth: footprintDepth ?? this.footprintDepth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (objectId.present) {
      map['object_id'] = Variable<String>(objectId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (objectType.present) {
      map['object_type'] = Variable<String>(objectType.value);
    }
    if (assetKey.present) {
      map['asset_key'] = Variable<String>(assetKey.value);
    }
    if (localAssetPath.present) {
      map['local_asset_path'] = Variable<String>(localAssetPath.value);
    }
    if (storageKey.present) {
      map['storage_key'] = Variable<String>(storageKey.value);
    }
    if (placementSurface.present) {
      map['placement_surface'] = Variable<String>(placementSurface.value);
    }
    if (gridX.present) {
      map['grid_x'] = Variable<int>(gridX.value);
    }
    if (gridY.present) {
      map['grid_y'] = Variable<int>(gridY.value);
    }
    if (gridZ.present) {
      map['grid_z'] = Variable<int>(gridZ.value);
    }
    if (spanX.present) {
      map['span_x'] = Variable<int>(spanX.value);
    }
    if (spanY.present) {
      map['span_y'] = Variable<int>(spanY.value);
    }
    if (spanZ.present) {
      map['span_z'] = Variable<int>(spanZ.value);
    }
    if (gridVersion.present) {
      map['grid_version'] = Variable<int>(gridVersion.value);
    }
    if (posX.present) {
      map['pos_x'] = Variable<double>(posX.value);
    }
    if (posY.present) {
      map['pos_y'] = Variable<double>(posY.value);
    }
    if (posZ.present) {
      map['pos_z'] = Variable<double>(posZ.value);
    }
    if (scale.present) {
      map['scale'] = Variable<double>(scale.value);
    }
    if (scaleX.present) {
      map['scale_x'] = Variable<double>(scaleX.value);
    }
    if (scaleY.present) {
      map['scale_y'] = Variable<double>(scaleY.value);
    }
    if (scaleZ.present) {
      map['scale_z'] = Variable<double>(scaleZ.value);
    }
    if (rotationX.present) {
      map['rotation_x'] = Variable<double>(rotationX.value);
    }
    if (rotationY.present) {
      map['rotation_y'] = Variable<double>(rotationY.value);
    }
    if (rotationZ.present) {
      map['rotation_z'] = Variable<double>(rotationZ.value);
    }
    if (isPlaced.present) {
      map['is_placed'] = Variable<bool>(isPlaced.value);
    }
    if (originalWidth.present) {
      map['original_width'] = Variable<int>(originalWidth.value);
    }
    if (originalHeight.present) {
      map['original_height'] = Variable<int>(originalHeight.value);
    }
    if (footprintWidth.present) {
      map['footprint_width'] = Variable<double>(footprintWidth.value);
    }
    if (footprintHeight.present) {
      map['footprint_height'] = Variable<double>(footprintHeight.value);
    }
    if (footprintDepth.present) {
      map['footprint_depth'] = Variable<double>(footprintDepth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomObjectsCompanion(')
          ..write('objectId: $objectId, ')
          ..write('profileId: $profileId, ')
          ..write('roomId: $roomId, ')
          ..write('itemId: $itemId, ')
          ..write('objectType: $objectType, ')
          ..write('assetKey: $assetKey, ')
          ..write('localAssetPath: $localAssetPath, ')
          ..write('storageKey: $storageKey, ')
          ..write('placementSurface: $placementSurface, ')
          ..write('gridX: $gridX, ')
          ..write('gridY: $gridY, ')
          ..write('gridZ: $gridZ, ')
          ..write('spanX: $spanX, ')
          ..write('spanY: $spanY, ')
          ..write('spanZ: $spanZ, ')
          ..write('gridVersion: $gridVersion, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('posZ: $posZ, ')
          ..write('scale: $scale, ')
          ..write('scaleX: $scaleX, ')
          ..write('scaleY: $scaleY, ')
          ..write('scaleZ: $scaleZ, ')
          ..write('rotationX: $rotationX, ')
          ..write('rotationY: $rotationY, ')
          ..write('rotationZ: $rotationZ, ')
          ..write('isPlaced: $isPlaced, ')
          ..write('originalWidth: $originalWidth, ')
          ..write('originalHeight: $originalHeight, ')
          ..write('footprintWidth: $footprintWidth, ')
          ..write('footprintHeight: $footprintHeight, ')
          ..write('footprintDepth: $footprintDepth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomObjectOccupiedCellsTable extends RoomObjectOccupiedCells
    with TableInfo<$RoomObjectOccupiedCellsTable, RoomObjectOccupiedCellRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomObjectOccupiedCellsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _objectIdMeta =
      const VerificationMeta('objectId');
  @override
  late final GeneratedColumn<String> objectId = GeneratedColumn<String>(
      'object_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES room_objects (object_id) ON DELETE CASCADE'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rooms (room_id) ON DELETE CASCADE'));
  static const VerificationMeta _gridXMeta = const VerificationMeta('gridX');
  @override
  late final GeneratedColumn<int> gridX = GeneratedColumn<int>(
      'grid_x', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gridYMeta = const VerificationMeta('gridY');
  @override
  late final GeneratedColumn<int> gridY = GeneratedColumn<int>(
      'grid_y', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gridZMeta = const VerificationMeta('gridZ');
  @override
  late final GeneratedColumn<int> gridZ = GeneratedColumn<int>(
      'grid_z', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [objectId, roomId, gridX, gridY, gridZ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'room_object_occupied_cells';
  @override
  VerificationContext validateIntegrity(
      Insertable<RoomObjectOccupiedCellRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('object_id')) {
      context.handle(_objectIdMeta,
          objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta));
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('grid_x')) {
      context.handle(
          _gridXMeta, gridX.isAcceptableOrUnknown(data['grid_x']!, _gridXMeta));
    } else if (isInserting) {
      context.missing(_gridXMeta);
    }
    if (data.containsKey('grid_y')) {
      context.handle(
          _gridYMeta, gridY.isAcceptableOrUnknown(data['grid_y']!, _gridYMeta));
    } else if (isInserting) {
      context.missing(_gridYMeta);
    }
    if (data.containsKey('grid_z')) {
      context.handle(
          _gridZMeta, gridZ.isAcceptableOrUnknown(data['grid_z']!, _gridZMeta));
    } else if (isInserting) {
      context.missing(_gridZMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {objectId, gridX, gridY, gridZ};
  @override
  RoomObjectOccupiedCellRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomObjectOccupiedCellRow(
      objectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}object_id'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
      gridX: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_x'])!,
      gridY: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_y'])!,
      gridZ: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grid_z'])!,
    );
  }

  @override
  $RoomObjectOccupiedCellsTable createAlias(String alias) {
    return $RoomObjectOccupiedCellsTable(attachedDatabase, alias);
  }
}

class RoomObjectOccupiedCellRow extends DataClass
    implements Insertable<RoomObjectOccupiedCellRow> {
  final String objectId;
  final String roomId;
  final int gridX;
  final int gridY;
  final int gridZ;
  const RoomObjectOccupiedCellRow(
      {required this.objectId,
      required this.roomId,
      required this.gridX,
      required this.gridY,
      required this.gridZ});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['object_id'] = Variable<String>(objectId);
    map['room_id'] = Variable<String>(roomId);
    map['grid_x'] = Variable<int>(gridX);
    map['grid_y'] = Variable<int>(gridY);
    map['grid_z'] = Variable<int>(gridZ);
    return map;
  }

  RoomObjectOccupiedCellsCompanion toCompanion(bool nullToAbsent) {
    return RoomObjectOccupiedCellsCompanion(
      objectId: Value(objectId),
      roomId: Value(roomId),
      gridX: Value(gridX),
      gridY: Value(gridY),
      gridZ: Value(gridZ),
    );
  }

  factory RoomObjectOccupiedCellRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomObjectOccupiedCellRow(
      objectId: serializer.fromJson<String>(json['objectId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      gridX: serializer.fromJson<int>(json['gridX']),
      gridY: serializer.fromJson<int>(json['gridY']),
      gridZ: serializer.fromJson<int>(json['gridZ']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'objectId': serializer.toJson<String>(objectId),
      'roomId': serializer.toJson<String>(roomId),
      'gridX': serializer.toJson<int>(gridX),
      'gridY': serializer.toJson<int>(gridY),
      'gridZ': serializer.toJson<int>(gridZ),
    };
  }

  RoomObjectOccupiedCellRow copyWith(
          {String? objectId,
          String? roomId,
          int? gridX,
          int? gridY,
          int? gridZ}) =>
      RoomObjectOccupiedCellRow(
        objectId: objectId ?? this.objectId,
        roomId: roomId ?? this.roomId,
        gridX: gridX ?? this.gridX,
        gridY: gridY ?? this.gridY,
        gridZ: gridZ ?? this.gridZ,
      );
  RoomObjectOccupiedCellRow copyWithCompanion(
      RoomObjectOccupiedCellsCompanion data) {
    return RoomObjectOccupiedCellRow(
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      gridX: data.gridX.present ? data.gridX.value : this.gridX,
      gridY: data.gridY.present ? data.gridY.value : this.gridY,
      gridZ: data.gridZ.present ? data.gridZ.value : this.gridZ,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomObjectOccupiedCellRow(')
          ..write('objectId: $objectId, ')
          ..write('roomId: $roomId, ')
          ..write('gridX: $gridX, ')
          ..write('gridY: $gridY, ')
          ..write('gridZ: $gridZ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(objectId, roomId, gridX, gridY, gridZ);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomObjectOccupiedCellRow &&
          other.objectId == this.objectId &&
          other.roomId == this.roomId &&
          other.gridX == this.gridX &&
          other.gridY == this.gridY &&
          other.gridZ == this.gridZ);
}

class RoomObjectOccupiedCellsCompanion
    extends UpdateCompanion<RoomObjectOccupiedCellRow> {
  final Value<String> objectId;
  final Value<String> roomId;
  final Value<int> gridX;
  final Value<int> gridY;
  final Value<int> gridZ;
  final Value<int> rowid;
  const RoomObjectOccupiedCellsCompanion({
    this.objectId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.gridX = const Value.absent(),
    this.gridY = const Value.absent(),
    this.gridZ = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomObjectOccupiedCellsCompanion.insert({
    required String objectId,
    required String roomId,
    required int gridX,
    required int gridY,
    required int gridZ,
    this.rowid = const Value.absent(),
  })  : objectId = Value(objectId),
        roomId = Value(roomId),
        gridX = Value(gridX),
        gridY = Value(gridY),
        gridZ = Value(gridZ);
  static Insertable<RoomObjectOccupiedCellRow> custom({
    Expression<String>? objectId,
    Expression<String>? roomId,
    Expression<int>? gridX,
    Expression<int>? gridY,
    Expression<int>? gridZ,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (objectId != null) 'object_id': objectId,
      if (roomId != null) 'room_id': roomId,
      if (gridX != null) 'grid_x': gridX,
      if (gridY != null) 'grid_y': gridY,
      if (gridZ != null) 'grid_z': gridZ,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomObjectOccupiedCellsCompanion copyWith(
      {Value<String>? objectId,
      Value<String>? roomId,
      Value<int>? gridX,
      Value<int>? gridY,
      Value<int>? gridZ,
      Value<int>? rowid}) {
    return RoomObjectOccupiedCellsCompanion(
      objectId: objectId ?? this.objectId,
      roomId: roomId ?? this.roomId,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      gridZ: gridZ ?? this.gridZ,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (objectId.present) {
      map['object_id'] = Variable<String>(objectId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (gridX.present) {
      map['grid_x'] = Variable<int>(gridX.value);
    }
    if (gridY.present) {
      map['grid_y'] = Variable<int>(gridY.value);
    }
    if (gridZ.present) {
      map['grid_z'] = Variable<int>(gridZ.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomObjectOccupiedCellsCompanion(')
          ..write('objectId: $objectId, ')
          ..write('roomId: $roomId, ')
          ..write('gridX: $gridX, ')
          ..write('gridY: $gridY, ')
          ..write('gridZ: $gridZ, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AvatarsTable avatars = $AvatarsTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $UserPreferencesTable userPreferences =
      $UserPreferencesTable(this);
  late final $RoomAvatarAssignmentsTable roomAvatarAssignments =
      $RoomAvatarAssignmentsTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $ItemMediaTable itemMedia = $ItemMediaTable(this);
  late final $ItemAvatarLinksTable itemAvatarLinks =
      $ItemAvatarLinksTable(this);
  late final $RoomObjectsTable roomObjects = $RoomObjectsTable(this);
  late final $RoomObjectOccupiedCellsTable roomObjectOccupiedCells =
      $RoomObjectOccupiedCellsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        avatars,
        rooms,
        userPreferences,
        roomAvatarAssignments,
        items,
        itemMedia,
        itemAvatarLinks,
        roomObjects,
        roomObjectOccupiedCells
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('avatars',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('rooms', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('rooms',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('user_preferences', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('rooms',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('room_avatar_assignments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('items',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('item_media', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('items',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('item_avatar_links', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('avatars',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('item_avatar_links', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('rooms',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('room_objects', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('items',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('room_objects', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('room_objects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('room_object_occupied_cells',
                  kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('rooms',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('room_object_occupied_cells',
                  kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$AvatarsTableCreateCompanionBuilder = AvatarsCompanion Function({
  required String avatarId,
  required String displayName,
  Value<String?> assetPath,
  Value<String?> previewImagePath,
  Value<double> defaultScale,
  Value<int> assetVersion,
  Value<bool> isEnabled,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$AvatarsTableUpdateCompanionBuilder = AvatarsCompanion Function({
  Value<String> avatarId,
  Value<String> displayName,
  Value<String?> assetPath,
  Value<String?> previewImagePath,
  Value<double> defaultScale,
  Value<int> assetVersion,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

final class $$AvatarsTableReferences
    extends BaseReferences<_$AppDatabase, $AvatarsTable, AvatarRow> {
  $$AvatarsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoomsTable, List<RoomRow>> _roomsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.rooms,
          aliasName: $_aliasNameGenerator(
              db.avatars.avatarId, db.rooms.defaultAvatarId));

  $$RoomsTableProcessedTableManager get roomsRefs {
    final manager = $$RoomsTableTableManager($_db, $_db.rooms)
        .filter((f) => f.defaultAvatarId.avatarId($_item.avatarId));

    final cache = $_typedResult.readTableOrNull(_roomsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoomAvatarAssignmentsTable,
      List<RoomAvatarAssignmentRow>> _roomAvatarAssignmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.roomAvatarAssignments,
          aliasName: $_aliasNameGenerator(
              db.avatars.avatarId, db.roomAvatarAssignments.avatarId));

  $$RoomAvatarAssignmentsTableProcessedTableManager
      get roomAvatarAssignmentsRefs {
    final manager = $$RoomAvatarAssignmentsTableTableManager(
            $_db, $_db.roomAvatarAssignments)
        .filter((f) => f.avatarId.avatarId($_item.avatarId));

    final cache =
        $_typedResult.readTableOrNull(_roomAvatarAssignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ItemAvatarLinksTable, List<ItemAvatarLinkRow>>
      _itemAvatarLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.itemAvatarLinks,
              aliasName: $_aliasNameGenerator(
                  db.avatars.avatarId, db.itemAvatarLinks.avatarId));

  $$ItemAvatarLinksTableProcessedTableManager get itemAvatarLinksRefs {
    final manager =
        $$ItemAvatarLinksTableTableManager($_db, $_db.itemAvatarLinks)
            .filter((f) => f.avatarId.avatarId($_item.avatarId));

    final cache =
        $_typedResult.readTableOrNull(_itemAvatarLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AvatarsTableFilterComposer
    extends Composer<_$AppDatabase, $AvatarsTable> {
  $$AvatarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get avatarId => $composableBuilder(
      column: $table.avatarId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetPath => $composableBuilder(
      column: $table.assetPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewImagePath => $composableBuilder(
      column: $table.previewImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultScale => $composableBuilder(
      column: $table.defaultScale, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get assetVersion => $composableBuilder(
      column: $table.assetVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> roomsRefs(
      Expression<bool> Function($$RoomsTableFilterComposer f) f) {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.defaultAvatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableFilterComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> roomAvatarAssignmentsRefs(
      Expression<bool> Function($$RoomAvatarAssignmentsTableFilterComposer f)
          f) {
    final $$RoomAvatarAssignmentsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.avatarId,
            referencedTable: $db.roomAvatarAssignments,
            getReferencedColumn: (t) => t.avatarId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoomAvatarAssignmentsTableFilterComposer(
                  $db: $db,
                  $table: $db.roomAvatarAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> itemAvatarLinksRefs(
      Expression<bool> Function($$ItemAvatarLinksTableFilterComposer f) f) {
    final $$ItemAvatarLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.itemAvatarLinks,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemAvatarLinksTableFilterComposer(
              $db: $db,
              $table: $db.itemAvatarLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AvatarsTableOrderingComposer
    extends Composer<_$AppDatabase, $AvatarsTable> {
  $$AvatarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get avatarId => $composableBuilder(
      column: $table.avatarId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetPath => $composableBuilder(
      column: $table.assetPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewImagePath => $composableBuilder(
      column: $table.previewImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultScale => $composableBuilder(
      column: $table.defaultScale,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get assetVersion => $composableBuilder(
      column: $table.assetVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AvatarsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AvatarsTable> {
  $$AvatarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get avatarId =>
      $composableBuilder(column: $table.avatarId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get assetPath =>
      $composableBuilder(column: $table.assetPath, builder: (column) => column);

  GeneratedColumn<String> get previewImagePath => $composableBuilder(
      column: $table.previewImagePath, builder: (column) => column);

  GeneratedColumn<double> get defaultScale => $composableBuilder(
      column: $table.defaultScale, builder: (column) => column);

  GeneratedColumn<int> get assetVersion => $composableBuilder(
      column: $table.assetVersion, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> roomsRefs<T extends Object>(
      Expression<T> Function($$RoomsTableAnnotationComposer a) f) {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.defaultAvatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableAnnotationComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> roomAvatarAssignmentsRefs<T extends Object>(
      Expression<T> Function($$RoomAvatarAssignmentsTableAnnotationComposer a)
          f) {
    final $$RoomAvatarAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.avatarId,
            referencedTable: $db.roomAvatarAssignments,
            getReferencedColumn: (t) => t.avatarId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoomAvatarAssignmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.roomAvatarAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> itemAvatarLinksRefs<T extends Object>(
      Expression<T> Function($$ItemAvatarLinksTableAnnotationComposer a) f) {
    final $$ItemAvatarLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.itemAvatarLinks,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemAvatarLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.itemAvatarLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AvatarsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AvatarsTable,
    AvatarRow,
    $$AvatarsTableFilterComposer,
    $$AvatarsTableOrderingComposer,
    $$AvatarsTableAnnotationComposer,
    $$AvatarsTableCreateCompanionBuilder,
    $$AvatarsTableUpdateCompanionBuilder,
    (AvatarRow, $$AvatarsTableReferences),
    AvatarRow,
    PrefetchHooks Function(
        {bool roomsRefs,
        bool roomAvatarAssignmentsRefs,
        bool itemAvatarLinksRefs})> {
  $$AvatarsTableTableManager(_$AppDatabase db, $AvatarsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AvatarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AvatarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AvatarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> avatarId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> assetPath = const Value.absent(),
            Value<String?> previewImagePath = const Value.absent(),
            Value<double> defaultScale = const Value.absent(),
            Value<int> assetVersion = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AvatarsCompanion(
            avatarId: avatarId,
            displayName: displayName,
            assetPath: assetPath,
            previewImagePath: previewImagePath,
            defaultScale: defaultScale,
            assetVersion: assetVersion,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String avatarId,
            required String displayName,
            Value<String?> assetPath = const Value.absent(),
            Value<String?> previewImagePath = const Value.absent(),
            Value<double> defaultScale = const Value.absent(),
            Value<int> assetVersion = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AvatarsCompanion.insert(
            avatarId: avatarId,
            displayName: displayName,
            assetPath: assetPath,
            previewImagePath: previewImagePath,
            defaultScale: defaultScale,
            assetVersion: assetVersion,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AvatarsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {roomsRefs = false,
              roomAvatarAssignmentsRefs = false,
              itemAvatarLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (roomsRefs) db.rooms,
                if (roomAvatarAssignmentsRefs) db.roomAvatarAssignments,
                if (itemAvatarLinksRefs) db.itemAvatarLinks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roomsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$AvatarsTableReferences._roomsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AvatarsTableReferences(db, table, p0).roomsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.defaultAvatarId == item.avatarId),
                        typedResults: items),
                  if (roomAvatarAssignmentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$AvatarsTableReferences
                            ._roomAvatarAssignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AvatarsTableReferences(db, table, p0)
                                .roomAvatarAssignmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.avatarId == item.avatarId),
                        typedResults: items),
                  if (itemAvatarLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$AvatarsTableReferences
                            ._itemAvatarLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AvatarsTableReferences(db, table, p0)
                                .itemAvatarLinksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.avatarId == item.avatarId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AvatarsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AvatarsTable,
    AvatarRow,
    $$AvatarsTableFilterComposer,
    $$AvatarsTableOrderingComposer,
    $$AvatarsTableAnnotationComposer,
    $$AvatarsTableCreateCompanionBuilder,
    $$AvatarsTableUpdateCompanionBuilder,
    (AvatarRow, $$AvatarsTableReferences),
    AvatarRow,
    PrefetchHooks Function(
        {bool roomsRefs,
        bool roomAvatarAssignmentsRefs,
        bool itemAvatarLinksRefs})>;
typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  required String roomId,
  required String name,
  required String assetPath,
  Value<String?> previewImagePath,
  Value<bool> isEnabled,
  Value<int> displayOrder,
  Value<int> assetVersion,
  Value<String?> defaultAvatarId,
  Value<double> cameraAzimuth,
  Value<double> cameraElevation,
  Value<double> cameraDistance,
  Value<double> orthographicSize,
  Value<double> targetX,
  Value<double> targetY,
  Value<double> targetZ,
  Value<double> floorY,
  Value<double> gridOriginX,
  Value<double> gridOriginY,
  Value<double> gridOriginZ,
  Value<double> cellSizeX,
  Value<double> cellSizeY,
  Value<double> cellSizeZ,
  Value<int> gridCountX,
  Value<int> gridCountY,
  Value<int> gridCountZ,
  Value<int> gridVersion,
  Value<double> walkMinX,
  Value<double> walkMaxX,
  Value<double> walkMinZ,
  Value<double> walkMaxZ,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<String> roomId,
  Value<String> name,
  Value<String> assetPath,
  Value<String?> previewImagePath,
  Value<bool> isEnabled,
  Value<int> displayOrder,
  Value<int> assetVersion,
  Value<String?> defaultAvatarId,
  Value<double> cameraAzimuth,
  Value<double> cameraElevation,
  Value<double> cameraDistance,
  Value<double> orthographicSize,
  Value<double> targetX,
  Value<double> targetY,
  Value<double> targetZ,
  Value<double> floorY,
  Value<double> gridOriginX,
  Value<double> gridOriginY,
  Value<double> gridOriginZ,
  Value<double> cellSizeX,
  Value<double> cellSizeY,
  Value<double> cellSizeZ,
  Value<int> gridCountX,
  Value<int> gridCountY,
  Value<int> gridCountZ,
  Value<int> gridVersion,
  Value<double> walkMinX,
  Value<double> walkMaxX,
  Value<double> walkMinZ,
  Value<double> walkMaxZ,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$RoomsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomsTable, RoomRow> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AvatarsTable _defaultAvatarIdTable(_$AppDatabase db) =>
      db.avatars.createAlias(
          $_aliasNameGenerator(db.rooms.defaultAvatarId, db.avatars.avatarId));

  $$AvatarsTableProcessedTableManager? get defaultAvatarId {
    if ($_item.defaultAvatarId == null) return null;
    final manager = $$AvatarsTableTableManager($_db, $_db.avatars)
        .filter((f) => f.avatarId($_item.defaultAvatarId!));
    final item = $_typedResult.readTableOrNull(_defaultAvatarIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$UserPreferencesTable, List<UserPreferenceRow>>
      _userPreferencesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.userPreferences,
              aliasName: $_aliasNameGenerator(
                  db.rooms.roomId, db.userPreferences.selectedRoomId));

  $$UserPreferencesTableProcessedTableManager get userPreferencesRefs {
    final manager =
        $$UserPreferencesTableTableManager($_db, $_db.userPreferences)
            .filter((f) => f.selectedRoomId.roomId($_item.roomId));

    final cache =
        $_typedResult.readTableOrNull(_userPreferencesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoomAvatarAssignmentsTable,
      List<RoomAvatarAssignmentRow>> _roomAvatarAssignmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.roomAvatarAssignments,
          aliasName: $_aliasNameGenerator(
              db.rooms.roomId, db.roomAvatarAssignments.roomId));

  $$RoomAvatarAssignmentsTableProcessedTableManager
      get roomAvatarAssignmentsRefs {
    final manager = $$RoomAvatarAssignmentsTableTableManager(
            $_db, $_db.roomAvatarAssignments)
        .filter((f) => f.roomId.roomId($_item.roomId));

    final cache =
        $_typedResult.readTableOrNull(_roomAvatarAssignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoomObjectsTable, List<RoomObjectRow>>
      _roomObjectsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.roomObjects,
              aliasName:
                  $_aliasNameGenerator(db.rooms.roomId, db.roomObjects.roomId));

  $$RoomObjectsTableProcessedTableManager get roomObjectsRefs {
    final manager = $$RoomObjectsTableTableManager($_db, $_db.roomObjects)
        .filter((f) => f.roomId.roomId($_item.roomId));

    final cache = $_typedResult.readTableOrNull(_roomObjectsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoomObjectOccupiedCellsTable,
      List<RoomObjectOccupiedCellRow>> _roomObjectOccupiedCellsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.roomObjectOccupiedCells,
          aliasName: $_aliasNameGenerator(
              db.rooms.roomId, db.roomObjectOccupiedCells.roomId));

  $$RoomObjectOccupiedCellsTableProcessedTableManager
      get roomObjectOccupiedCellsRefs {
    final manager = $$RoomObjectOccupiedCellsTableTableManager(
            $_db, $_db.roomObjectOccupiedCells)
        .filter((f) => f.roomId.roomId($_item.roomId));

    final cache =
        $_typedResult.readTableOrNull(_roomObjectOccupiedCellsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetPath => $composableBuilder(
      column: $table.assetPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewImagePath => $composableBuilder(
      column: $table.previewImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get assetVersion => $composableBuilder(
      column: $table.assetVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cameraAzimuth => $composableBuilder(
      column: $table.cameraAzimuth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cameraElevation => $composableBuilder(
      column: $table.cameraElevation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cameraDistance => $composableBuilder(
      column: $table.cameraDistance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get orthographicSize => $composableBuilder(
      column: $table.orthographicSize,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetX => $composableBuilder(
      column: $table.targetX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetY => $composableBuilder(
      column: $table.targetY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetZ => $composableBuilder(
      column: $table.targetZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get floorY => $composableBuilder(
      column: $table.floorY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gridOriginX => $composableBuilder(
      column: $table.gridOriginX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gridOriginY => $composableBuilder(
      column: $table.gridOriginY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gridOriginZ => $composableBuilder(
      column: $table.gridOriginZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cellSizeX => $composableBuilder(
      column: $table.cellSizeX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cellSizeY => $composableBuilder(
      column: $table.cellSizeY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cellSizeZ => $composableBuilder(
      column: $table.cellSizeZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridCountX => $composableBuilder(
      column: $table.gridCountX, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridCountY => $composableBuilder(
      column: $table.gridCountY, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridCountZ => $composableBuilder(
      column: $table.gridCountZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridVersion => $composableBuilder(
      column: $table.gridVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get walkMinX => $composableBuilder(
      column: $table.walkMinX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get walkMaxX => $composableBuilder(
      column: $table.walkMaxX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get walkMinZ => $composableBuilder(
      column: $table.walkMinZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get walkMaxZ => $composableBuilder(
      column: $table.walkMaxZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AvatarsTableFilterComposer get defaultAvatarId {
    final $$AvatarsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.defaultAvatarId,
        referencedTable: $db.avatars,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AvatarsTableFilterComposer(
              $db: $db,
              $table: $db.avatars,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> userPreferencesRefs(
      Expression<bool> Function($$UserPreferencesTableFilterComposer f) f) {
    final $$UserPreferencesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.userPreferences,
        getReferencedColumn: (t) => t.selectedRoomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserPreferencesTableFilterComposer(
              $db: $db,
              $table: $db.userPreferences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> roomAvatarAssignmentsRefs(
      Expression<bool> Function($$RoomAvatarAssignmentsTableFilterComposer f)
          f) {
    final $$RoomAvatarAssignmentsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.roomId,
            referencedTable: $db.roomAvatarAssignments,
            getReferencedColumn: (t) => t.roomId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoomAvatarAssignmentsTableFilterComposer(
                  $db: $db,
                  $table: $db.roomAvatarAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> roomObjectsRefs(
      Expression<bool> Function($$RoomObjectsTableFilterComposer f) f) {
    final $$RoomObjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.roomObjects,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomObjectsTableFilterComposer(
              $db: $db,
              $table: $db.roomObjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> roomObjectOccupiedCellsRefs(
      Expression<bool> Function($$RoomObjectOccupiedCellsTableFilterComposer f)
          f) {
    final $$RoomObjectOccupiedCellsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.roomId,
            referencedTable: $db.roomObjectOccupiedCells,
            getReferencedColumn: (t) => t.roomId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoomObjectOccupiedCellsTableFilterComposer(
                  $db: $db,
                  $table: $db.roomObjectOccupiedCells,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetPath => $composableBuilder(
      column: $table.assetPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewImagePath => $composableBuilder(
      column: $table.previewImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get assetVersion => $composableBuilder(
      column: $table.assetVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cameraAzimuth => $composableBuilder(
      column: $table.cameraAzimuth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cameraElevation => $composableBuilder(
      column: $table.cameraElevation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cameraDistance => $composableBuilder(
      column: $table.cameraDistance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get orthographicSize => $composableBuilder(
      column: $table.orthographicSize,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetX => $composableBuilder(
      column: $table.targetX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetY => $composableBuilder(
      column: $table.targetY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetZ => $composableBuilder(
      column: $table.targetZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get floorY => $composableBuilder(
      column: $table.floorY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gridOriginX => $composableBuilder(
      column: $table.gridOriginX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gridOriginY => $composableBuilder(
      column: $table.gridOriginY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gridOriginZ => $composableBuilder(
      column: $table.gridOriginZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cellSizeX => $composableBuilder(
      column: $table.cellSizeX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cellSizeY => $composableBuilder(
      column: $table.cellSizeY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cellSizeZ => $composableBuilder(
      column: $table.cellSizeZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridCountX => $composableBuilder(
      column: $table.gridCountX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridCountY => $composableBuilder(
      column: $table.gridCountY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridCountZ => $composableBuilder(
      column: $table.gridCountZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridVersion => $composableBuilder(
      column: $table.gridVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get walkMinX => $composableBuilder(
      column: $table.walkMinX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get walkMaxX => $composableBuilder(
      column: $table.walkMaxX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get walkMinZ => $composableBuilder(
      column: $table.walkMinZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get walkMaxZ => $composableBuilder(
      column: $table.walkMaxZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AvatarsTableOrderingComposer get defaultAvatarId {
    final $$AvatarsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.defaultAvatarId,
        referencedTable: $db.avatars,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AvatarsTableOrderingComposer(
              $db: $db,
              $table: $db.avatars,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get assetPath =>
      $composableBuilder(column: $table.assetPath, builder: (column) => column);

  GeneratedColumn<String> get previewImagePath => $composableBuilder(
      column: $table.previewImagePath, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

  GeneratedColumn<int> get assetVersion => $composableBuilder(
      column: $table.assetVersion, builder: (column) => column);

  GeneratedColumn<double> get cameraAzimuth => $composableBuilder(
      column: $table.cameraAzimuth, builder: (column) => column);

  GeneratedColumn<double> get cameraElevation => $composableBuilder(
      column: $table.cameraElevation, builder: (column) => column);

  GeneratedColumn<double> get cameraDistance => $composableBuilder(
      column: $table.cameraDistance, builder: (column) => column);

  GeneratedColumn<double> get orthographicSize => $composableBuilder(
      column: $table.orthographicSize, builder: (column) => column);

  GeneratedColumn<double> get targetX =>
      $composableBuilder(column: $table.targetX, builder: (column) => column);

  GeneratedColumn<double> get targetY =>
      $composableBuilder(column: $table.targetY, builder: (column) => column);

  GeneratedColumn<double> get targetZ =>
      $composableBuilder(column: $table.targetZ, builder: (column) => column);

  GeneratedColumn<double> get floorY =>
      $composableBuilder(column: $table.floorY, builder: (column) => column);

  GeneratedColumn<double> get gridOriginX => $composableBuilder(
      column: $table.gridOriginX, builder: (column) => column);

  GeneratedColumn<double> get gridOriginY => $composableBuilder(
      column: $table.gridOriginY, builder: (column) => column);

  GeneratedColumn<double> get gridOriginZ => $composableBuilder(
      column: $table.gridOriginZ, builder: (column) => column);

  GeneratedColumn<double> get cellSizeX =>
      $composableBuilder(column: $table.cellSizeX, builder: (column) => column);

  GeneratedColumn<double> get cellSizeY =>
      $composableBuilder(column: $table.cellSizeY, builder: (column) => column);

  GeneratedColumn<double> get cellSizeZ =>
      $composableBuilder(column: $table.cellSizeZ, builder: (column) => column);

  GeneratedColumn<int> get gridCountX => $composableBuilder(
      column: $table.gridCountX, builder: (column) => column);

  GeneratedColumn<int> get gridCountY => $composableBuilder(
      column: $table.gridCountY, builder: (column) => column);

  GeneratedColumn<int> get gridCountZ => $composableBuilder(
      column: $table.gridCountZ, builder: (column) => column);

  GeneratedColumn<int> get gridVersion => $composableBuilder(
      column: $table.gridVersion, builder: (column) => column);

  GeneratedColumn<double> get walkMinX =>
      $composableBuilder(column: $table.walkMinX, builder: (column) => column);

  GeneratedColumn<double> get walkMaxX =>
      $composableBuilder(column: $table.walkMaxX, builder: (column) => column);

  GeneratedColumn<double> get walkMinZ =>
      $composableBuilder(column: $table.walkMinZ, builder: (column) => column);

  GeneratedColumn<double> get walkMaxZ =>
      $composableBuilder(column: $table.walkMaxZ, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AvatarsTableAnnotationComposer get defaultAvatarId {
    final $$AvatarsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.defaultAvatarId,
        referencedTable: $db.avatars,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AvatarsTableAnnotationComposer(
              $db: $db,
              $table: $db.avatars,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> userPreferencesRefs<T extends Object>(
      Expression<T> Function($$UserPreferencesTableAnnotationComposer a) f) {
    final $$UserPreferencesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.userPreferences,
        getReferencedColumn: (t) => t.selectedRoomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserPreferencesTableAnnotationComposer(
              $db: $db,
              $table: $db.userPreferences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> roomAvatarAssignmentsRefs<T extends Object>(
      Expression<T> Function($$RoomAvatarAssignmentsTableAnnotationComposer a)
          f) {
    final $$RoomAvatarAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.roomId,
            referencedTable: $db.roomAvatarAssignments,
            getReferencedColumn: (t) => t.roomId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoomAvatarAssignmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.roomAvatarAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> roomObjectsRefs<T extends Object>(
      Expression<T> Function($$RoomObjectsTableAnnotationComposer a) f) {
    final $$RoomObjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.roomObjects,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomObjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.roomObjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> roomObjectOccupiedCellsRefs<T extends Object>(
      Expression<T> Function($$RoomObjectOccupiedCellsTableAnnotationComposer a)
          f) {
    final $$RoomObjectOccupiedCellsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.roomId,
            referencedTable: $db.roomObjectOccupiedCells,
            getReferencedColumn: (t) => t.roomId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoomObjectOccupiedCellsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.roomObjectOccupiedCells,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RoomsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoomsTable,
    RoomRow,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (RoomRow, $$RoomsTableReferences),
    RoomRow,
    PrefetchHooks Function(
        {bool defaultAvatarId,
        bool userPreferencesRefs,
        bool roomAvatarAssignmentsRefs,
        bool roomObjectsRefs,
        bool roomObjectOccupiedCellsRefs})> {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> roomId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> assetPath = const Value.absent(),
            Value<String?> previewImagePath = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<int> assetVersion = const Value.absent(),
            Value<String?> defaultAvatarId = const Value.absent(),
            Value<double> cameraAzimuth = const Value.absent(),
            Value<double> cameraElevation = const Value.absent(),
            Value<double> cameraDistance = const Value.absent(),
            Value<double> orthographicSize = const Value.absent(),
            Value<double> targetX = const Value.absent(),
            Value<double> targetY = const Value.absent(),
            Value<double> targetZ = const Value.absent(),
            Value<double> floorY = const Value.absent(),
            Value<double> gridOriginX = const Value.absent(),
            Value<double> gridOriginY = const Value.absent(),
            Value<double> gridOriginZ = const Value.absent(),
            Value<double> cellSizeX = const Value.absent(),
            Value<double> cellSizeY = const Value.absent(),
            Value<double> cellSizeZ = const Value.absent(),
            Value<int> gridCountX = const Value.absent(),
            Value<int> gridCountY = const Value.absent(),
            Value<int> gridCountZ = const Value.absent(),
            Value<int> gridVersion = const Value.absent(),
            Value<double> walkMinX = const Value.absent(),
            Value<double> walkMaxX = const Value.absent(),
            Value<double> walkMinZ = const Value.absent(),
            Value<double> walkMaxZ = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomsCompanion(
            roomId: roomId,
            name: name,
            assetPath: assetPath,
            previewImagePath: previewImagePath,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
            assetVersion: assetVersion,
            defaultAvatarId: defaultAvatarId,
            cameraAzimuth: cameraAzimuth,
            cameraElevation: cameraElevation,
            cameraDistance: cameraDistance,
            orthographicSize: orthographicSize,
            targetX: targetX,
            targetY: targetY,
            targetZ: targetZ,
            floorY: floorY,
            gridOriginX: gridOriginX,
            gridOriginY: gridOriginY,
            gridOriginZ: gridOriginZ,
            cellSizeX: cellSizeX,
            cellSizeY: cellSizeY,
            cellSizeZ: cellSizeZ,
            gridCountX: gridCountX,
            gridCountY: gridCountY,
            gridCountZ: gridCountZ,
            gridVersion: gridVersion,
            walkMinX: walkMinX,
            walkMaxX: walkMaxX,
            walkMinZ: walkMinZ,
            walkMaxZ: walkMaxZ,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String roomId,
            required String name,
            required String assetPath,
            Value<String?> previewImagePath = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<int> assetVersion = const Value.absent(),
            Value<String?> defaultAvatarId = const Value.absent(),
            Value<double> cameraAzimuth = const Value.absent(),
            Value<double> cameraElevation = const Value.absent(),
            Value<double> cameraDistance = const Value.absent(),
            Value<double> orthographicSize = const Value.absent(),
            Value<double> targetX = const Value.absent(),
            Value<double> targetY = const Value.absent(),
            Value<double> targetZ = const Value.absent(),
            Value<double> floorY = const Value.absent(),
            Value<double> gridOriginX = const Value.absent(),
            Value<double> gridOriginY = const Value.absent(),
            Value<double> gridOriginZ = const Value.absent(),
            Value<double> cellSizeX = const Value.absent(),
            Value<double> cellSizeY = const Value.absent(),
            Value<double> cellSizeZ = const Value.absent(),
            Value<int> gridCountX = const Value.absent(),
            Value<int> gridCountY = const Value.absent(),
            Value<int> gridCountZ = const Value.absent(),
            Value<int> gridVersion = const Value.absent(),
            Value<double> walkMinX = const Value.absent(),
            Value<double> walkMaxX = const Value.absent(),
            Value<double> walkMinZ = const Value.absent(),
            Value<double> walkMaxZ = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomsCompanion.insert(
            roomId: roomId,
            name: name,
            assetPath: assetPath,
            previewImagePath: previewImagePath,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
            assetVersion: assetVersion,
            defaultAvatarId: defaultAvatarId,
            cameraAzimuth: cameraAzimuth,
            cameraElevation: cameraElevation,
            cameraDistance: cameraDistance,
            orthographicSize: orthographicSize,
            targetX: targetX,
            targetY: targetY,
            targetZ: targetZ,
            floorY: floorY,
            gridOriginX: gridOriginX,
            gridOriginY: gridOriginY,
            gridOriginZ: gridOriginZ,
            cellSizeX: cellSizeX,
            cellSizeY: cellSizeY,
            cellSizeZ: cellSizeZ,
            gridCountX: gridCountX,
            gridCountY: gridCountY,
            gridCountZ: gridCountZ,
            gridVersion: gridVersion,
            walkMinX: walkMinX,
            walkMaxX: walkMaxX,
            walkMinZ: walkMinZ,
            walkMaxZ: walkMaxZ,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RoomsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {defaultAvatarId = false,
              userPreferencesRefs = false,
              roomAvatarAssignmentsRefs = false,
              roomObjectsRefs = false,
              roomObjectOccupiedCellsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userPreferencesRefs) db.userPreferences,
                if (roomAvatarAssignmentsRefs) db.roomAvatarAssignments,
                if (roomObjectsRefs) db.roomObjects,
                if (roomObjectOccupiedCellsRefs) db.roomObjectOccupiedCells
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (defaultAvatarId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.defaultAvatarId,
                    referencedTable:
                        $$RoomsTableReferences._defaultAvatarIdTable(db),
                    referencedColumn: $$RoomsTableReferences
                        ._defaultAvatarIdTable(db)
                        .avatarId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userPreferencesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RoomsTableReferences
                            ._userPreferencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoomsTableReferences(db, table, p0)
                                .userPreferencesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.selectedRoomId == item.roomId),
                        typedResults: items),
                  if (roomAvatarAssignmentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RoomsTableReferences
                            ._roomAvatarAssignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoomsTableReferences(db, table, p0)
                                .roomAvatarAssignmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.roomId == item.roomId),
                        typedResults: items),
                  if (roomObjectsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$RoomsTableReferences._roomObjectsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoomsTableReferences(db, table, p0)
                                .roomObjectsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.roomId == item.roomId),
                        typedResults: items),
                  if (roomObjectOccupiedCellsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RoomsTableReferences
                            ._roomObjectOccupiedCellsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoomsTableReferences(db, table, p0)
                                .roomObjectOccupiedCellsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.roomId == item.roomId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RoomsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoomsTable,
    RoomRow,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (RoomRow, $$RoomsTableReferences),
    RoomRow,
    PrefetchHooks Function(
        {bool defaultAvatarId,
        bool userPreferencesRefs,
        bool roomAvatarAssignmentsRefs,
        bool roomObjectsRefs,
        bool roomObjectOccupiedCellsRefs})>;
typedef $$UserPreferencesTableCreateCompanionBuilder = UserPreferencesCompanion
    Function({
  required String profileId,
  Value<String?> selectedRoomId,
  Value<bool> onboardingCompleted,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> lastOpenedAt,
  Value<int> version,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$UserPreferencesTableUpdateCompanionBuilder = UserPreferencesCompanion
    Function({
  Value<String> profileId,
  Value<String?> selectedRoomId,
  Value<bool> onboardingCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastOpenedAt,
  Value<int> version,
  Value<String> syncState,
  Value<int> rowid,
});

final class $$UserPreferencesTableReferences extends BaseReferences<
    _$AppDatabase, $UserPreferencesTable, UserPreferenceRow> {
  $$UserPreferencesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RoomsTable _selectedRoomIdTable(_$AppDatabase db) =>
      db.rooms.createAlias($_aliasNameGenerator(
          db.userPreferences.selectedRoomId, db.rooms.roomId));

  $$RoomsTableProcessedTableManager? get selectedRoomId {
    if ($_item.selectedRoomId == null) return null;
    final manager = $$RoomsTableTableManager($_db, $_db.rooms)
        .filter((f) => f.roomId($_item.selectedRoomId!));
    final item = $_typedResult.readTableOrNull(_selectedRoomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
      column: $table.lastOpenedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  $$RoomsTableFilterComposer get selectedRoomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.selectedRoomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableFilterComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
      column: $table.lastOpenedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  $$RoomsTableOrderingComposer get selectedRoomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.selectedRoomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableOrderingComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
      column: $table.lastOpenedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$RoomsTableAnnotationComposer get selectedRoomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.selectedRoomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableAnnotationComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserPreferencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserPreferencesTable,
    UserPreferenceRow,
    $$UserPreferencesTableFilterComposer,
    $$UserPreferencesTableOrderingComposer,
    $$UserPreferencesTableAnnotationComposer,
    $$UserPreferencesTableCreateCompanionBuilder,
    $$UserPreferencesTableUpdateCompanionBuilder,
    (UserPreferenceRow, $$UserPreferencesTableReferences),
    UserPreferenceRow,
    PrefetchHooks Function({bool selectedRoomId})> {
  $$UserPreferencesTableTableManager(
      _$AppDatabase db, $UserPreferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> profileId = const Value.absent(),
            Value<String?> selectedRoomId = const Value.absent(),
            Value<bool> onboardingCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastOpenedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserPreferencesCompanion(
            profileId: profileId,
            selectedRoomId: selectedRoomId,
            onboardingCompleted: onboardingCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastOpenedAt: lastOpenedAt,
            version: version,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String profileId,
            Value<String?> selectedRoomId = const Value.absent(),
            Value<bool> onboardingCompleted = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> lastOpenedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserPreferencesCompanion.insert(
            profileId: profileId,
            selectedRoomId: selectedRoomId,
            onboardingCompleted: onboardingCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastOpenedAt: lastOpenedAt,
            version: version,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserPreferencesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({selectedRoomId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (selectedRoomId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.selectedRoomId,
                    referencedTable: $$UserPreferencesTableReferences
                        ._selectedRoomIdTable(db),
                    referencedColumn: $$UserPreferencesTableReferences
                        ._selectedRoomIdTable(db)
                        .roomId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UserPreferencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserPreferencesTable,
    UserPreferenceRow,
    $$UserPreferencesTableFilterComposer,
    $$UserPreferencesTableOrderingComposer,
    $$UserPreferencesTableAnnotationComposer,
    $$UserPreferencesTableCreateCompanionBuilder,
    $$UserPreferencesTableUpdateCompanionBuilder,
    (UserPreferenceRow, $$UserPreferencesTableReferences),
    UserPreferenceRow,
    PrefetchHooks Function({bool selectedRoomId})>;
typedef $$RoomAvatarAssignmentsTableCreateCompanionBuilder
    = RoomAvatarAssignmentsCompanion Function({
  Value<String> assignmentId,
  required String profileId,
  required String roomId,
  required String avatarId,
  Value<double> posX,
  Value<double> posY,
  Value<double> posZ,
  Value<double> scaleX,
  Value<double> scaleY,
  Value<double> scaleZ,
  Value<double> rotationX,
  Value<double> rotationY,
  Value<double> rotationZ,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> version,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$RoomAvatarAssignmentsTableUpdateCompanionBuilder
    = RoomAvatarAssignmentsCompanion Function({
  Value<String> assignmentId,
  Value<String> profileId,
  Value<String> roomId,
  Value<String> avatarId,
  Value<double> posX,
  Value<double> posY,
  Value<double> posZ,
  Value<double> scaleX,
  Value<double> scaleY,
  Value<double> scaleZ,
  Value<double> rotationX,
  Value<double> rotationY,
  Value<double> rotationZ,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> version,
  Value<String> syncState,
  Value<int> rowid,
});

final class $$RoomAvatarAssignmentsTableReferences extends BaseReferences<
    _$AppDatabase, $RoomAvatarAssignmentsTable, RoomAvatarAssignmentRow> {
  $$RoomAvatarAssignmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RoomsTable _roomIdTable(_$AppDatabase db) => db.rooms.createAlias(
      $_aliasNameGenerator(db.roomAvatarAssignments.roomId, db.rooms.roomId));

  $$RoomsTableProcessedTableManager? get roomId {
    if ($_item.roomId == null) return null;
    final manager = $$RoomsTableTableManager($_db, $_db.rooms)
        .filter((f) => f.roomId($_item.roomId!));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AvatarsTable _avatarIdTable(_$AppDatabase db) =>
      db.avatars.createAlias($_aliasNameGenerator(
          db.roomAvatarAssignments.avatarId, db.avatars.avatarId));

  $$AvatarsTableProcessedTableManager? get avatarId {
    if ($_item.avatarId == null) return null;
    final manager = $$AvatarsTableTableManager($_db, $_db.avatars)
        .filter((f) => f.avatarId($_item.avatarId!));
    final item = $_typedResult.readTableOrNull(_avatarIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoomAvatarAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $RoomAvatarAssignmentsTable> {
  $$RoomAvatarAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assignmentId => $composableBuilder(
      column: $table.assignmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posX => $composableBuilder(
      column: $table.posX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posY => $composableBuilder(
      column: $table.posY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posZ => $composableBuilder(
      column: $table.posZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scaleX => $composableBuilder(
      column: $table.scaleX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scaleY => $composableBuilder(
      column: $table.scaleY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scaleZ => $composableBuilder(
      column: $table.scaleZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rotationX => $composableBuilder(
      column: $table.rotationX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rotationY => $composableBuilder(
      column: $table.rotationY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rotationZ => $composableBuilder(
      column: $table.rotationZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableFilterComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AvatarsTableFilterComposer get avatarId {
    final $$AvatarsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.avatars,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AvatarsTableFilterComposer(
              $db: $db,
              $table: $db.avatars,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomAvatarAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomAvatarAssignmentsTable> {
  $$RoomAvatarAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assignmentId => $composableBuilder(
      column: $table.assignmentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posX => $composableBuilder(
      column: $table.posX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posY => $composableBuilder(
      column: $table.posY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posZ => $composableBuilder(
      column: $table.posZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scaleX => $composableBuilder(
      column: $table.scaleX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scaleY => $composableBuilder(
      column: $table.scaleY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scaleZ => $composableBuilder(
      column: $table.scaleZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rotationX => $composableBuilder(
      column: $table.rotationX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rotationY => $composableBuilder(
      column: $table.rotationY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rotationZ => $composableBuilder(
      column: $table.rotationZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableOrderingComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AvatarsTableOrderingComposer get avatarId {
    final $$AvatarsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.avatars,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AvatarsTableOrderingComposer(
              $db: $db,
              $table: $db.avatars,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomAvatarAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomAvatarAssignmentsTable> {
  $$RoomAvatarAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assignmentId => $composableBuilder(
      column: $table.assignmentId, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<double> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => column);

  GeneratedColumn<double> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => column);

  GeneratedColumn<double> get posZ =>
      $composableBuilder(column: $table.posZ, builder: (column) => column);

  GeneratedColumn<double> get scaleX =>
      $composableBuilder(column: $table.scaleX, builder: (column) => column);

  GeneratedColumn<double> get scaleY =>
      $composableBuilder(column: $table.scaleY, builder: (column) => column);

  GeneratedColumn<double> get scaleZ =>
      $composableBuilder(column: $table.scaleZ, builder: (column) => column);

  GeneratedColumn<double> get rotationX =>
      $composableBuilder(column: $table.rotationX, builder: (column) => column);

  GeneratedColumn<double> get rotationY =>
      $composableBuilder(column: $table.rotationY, builder: (column) => column);

  GeneratedColumn<double> get rotationZ =>
      $composableBuilder(column: $table.rotationZ, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableAnnotationComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AvatarsTableAnnotationComposer get avatarId {
    final $$AvatarsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.avatars,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AvatarsTableAnnotationComposer(
              $db: $db,
              $table: $db.avatars,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomAvatarAssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoomAvatarAssignmentsTable,
    RoomAvatarAssignmentRow,
    $$RoomAvatarAssignmentsTableFilterComposer,
    $$RoomAvatarAssignmentsTableOrderingComposer,
    $$RoomAvatarAssignmentsTableAnnotationComposer,
    $$RoomAvatarAssignmentsTableCreateCompanionBuilder,
    $$RoomAvatarAssignmentsTableUpdateCompanionBuilder,
    (RoomAvatarAssignmentRow, $$RoomAvatarAssignmentsTableReferences),
    RoomAvatarAssignmentRow,
    PrefetchHooks Function({bool roomId, bool avatarId})> {
  $$RoomAvatarAssignmentsTableTableManager(
      _$AppDatabase db, $RoomAvatarAssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomAvatarAssignmentsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomAvatarAssignmentsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomAvatarAssignmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> assignmentId = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> roomId = const Value.absent(),
            Value<String> avatarId = const Value.absent(),
            Value<double> posX = const Value.absent(),
            Value<double> posY = const Value.absent(),
            Value<double> posZ = const Value.absent(),
            Value<double> scaleX = const Value.absent(),
            Value<double> scaleY = const Value.absent(),
            Value<double> scaleZ = const Value.absent(),
            Value<double> rotationX = const Value.absent(),
            Value<double> rotationY = const Value.absent(),
            Value<double> rotationZ = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomAvatarAssignmentsCompanion(
            assignmentId: assignmentId,
            profileId: profileId,
            roomId: roomId,
            avatarId: avatarId,
            posX: posX,
            posY: posY,
            posZ: posZ,
            scaleX: scaleX,
            scaleY: scaleY,
            scaleZ: scaleZ,
            rotationX: rotationX,
            rotationY: rotationY,
            rotationZ: rotationZ,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> assignmentId = const Value.absent(),
            required String profileId,
            required String roomId,
            required String avatarId,
            Value<double> posX = const Value.absent(),
            Value<double> posY = const Value.absent(),
            Value<double> posZ = const Value.absent(),
            Value<double> scaleX = const Value.absent(),
            Value<double> scaleY = const Value.absent(),
            Value<double> scaleZ = const Value.absent(),
            Value<double> rotationX = const Value.absent(),
            Value<double> rotationY = const Value.absent(),
            Value<double> rotationZ = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> version = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomAvatarAssignmentsCompanion.insert(
            assignmentId: assignmentId,
            profileId: profileId,
            roomId: roomId,
            avatarId: avatarId,
            posX: posX,
            posY: posY,
            posZ: posZ,
            scaleX: scaleX,
            scaleY: scaleY,
            scaleZ: scaleZ,
            rotationX: rotationX,
            rotationY: rotationY,
            rotationZ: rotationZ,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RoomAvatarAssignmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({roomId = false, avatarId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (roomId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.roomId,
                    referencedTable:
                        $$RoomAvatarAssignmentsTableReferences._roomIdTable(db),
                    referencedColumn: $$RoomAvatarAssignmentsTableReferences
                        ._roomIdTable(db)
                        .roomId,
                  ) as T;
                }
                if (avatarId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.avatarId,
                    referencedTable: $$RoomAvatarAssignmentsTableReferences
                        ._avatarIdTable(db),
                    referencedColumn: $$RoomAvatarAssignmentsTableReferences
                        ._avatarIdTable(db)
                        .avatarId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RoomAvatarAssignmentsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RoomAvatarAssignmentsTable,
        RoomAvatarAssignmentRow,
        $$RoomAvatarAssignmentsTableFilterComposer,
        $$RoomAvatarAssignmentsTableOrderingComposer,
        $$RoomAvatarAssignmentsTableAnnotationComposer,
        $$RoomAvatarAssignmentsTableCreateCompanionBuilder,
        $$RoomAvatarAssignmentsTableUpdateCompanionBuilder,
        (RoomAvatarAssignmentRow, $$RoomAvatarAssignmentsTableReferences),
        RoomAvatarAssignmentRow,
        PrefetchHooks Function({bool roomId, bool avatarId})>;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String itemId,
  Value<String> ownerId,
  required String title,
  Value<String> memo,
  Value<String> status,
  Value<bool> transferable,
  Value<String?> localImagePath,
  Value<String?> originalImageKey,
  Value<String?> processedImageKey,
  Value<String?> processedLocalImagePath,
  Value<String> outputType,
  Value<String> processStatus,
  Value<String?> processErrorMessage,
  Value<String?> processFailureStage,
  Value<DateTime?> usedFrom,
  Value<DateTime?> usedUntil,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> itemId,
  Value<String> ownerId,
  Value<String> title,
  Value<String> memo,
  Value<String> status,
  Value<bool> transferable,
  Value<String?> localImagePath,
  Value<String?> originalImageKey,
  Value<String?> processedImageKey,
  Value<String?> processedLocalImagePath,
  Value<String> outputType,
  Value<String> processStatus,
  Value<String?> processErrorMessage,
  Value<String?> processFailureStage,
  Value<DateTime?> usedFrom,
  Value<DateTime?> usedUntil,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, Item> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemMediaTable, List<ItemMediaRow>>
      _itemMediaRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.itemMedia,
              aliasName:
                  $_aliasNameGenerator(db.items.itemId, db.itemMedia.itemId));

  $$ItemMediaTableProcessedTableManager get itemMediaRefs {
    final manager = $$ItemMediaTableTableManager($_db, $_db.itemMedia)
        .filter((f) => f.itemId.itemId($_item.itemId));

    final cache = $_typedResult.readTableOrNull(_itemMediaRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ItemAvatarLinksTable, List<ItemAvatarLinkRow>>
      _itemAvatarLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.itemAvatarLinks,
              aliasName: $_aliasNameGenerator(
                  db.items.itemId, db.itemAvatarLinks.itemId));

  $$ItemAvatarLinksTableProcessedTableManager get itemAvatarLinksRefs {
    final manager =
        $$ItemAvatarLinksTableTableManager($_db, $_db.itemAvatarLinks)
            .filter((f) => f.itemId.itemId($_item.itemId));

    final cache =
        $_typedResult.readTableOrNull(_itemAvatarLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoomObjectsTable, List<RoomObjectRow>>
      _roomObjectsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.roomObjects,
              aliasName:
                  $_aliasNameGenerator(db.items.itemId, db.roomObjects.itemId));

  $$RoomObjectsTableProcessedTableManager get roomObjectsRefs {
    final manager = $$RoomObjectsTableTableManager($_db, $_db.roomObjects)
        .filter((f) => f.itemId.itemId($_item.itemId));

    final cache = $_typedResult.readTableOrNull(_roomObjectsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get transferable => $composableBuilder(
      column: $table.transferable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalImageKey => $composableBuilder(
      column: $table.originalImageKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processedImageKey => $composableBuilder(
      column: $table.processedImageKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processedLocalImagePath => $composableBuilder(
      column: $table.processedLocalImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outputType => $composableBuilder(
      column: $table.outputType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processStatus => $composableBuilder(
      column: $table.processStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processErrorMessage => $composableBuilder(
      column: $table.processErrorMessage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processFailureStage => $composableBuilder(
      column: $table.processFailureStage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get usedFrom => $composableBuilder(
      column: $table.usedFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get usedUntil => $composableBuilder(
      column: $table.usedUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> itemMediaRefs(
      Expression<bool> Function($$ItemMediaTableFilterComposer f) f) {
    final $$ItemMediaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.itemMedia,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemMediaTableFilterComposer(
              $db: $db,
              $table: $db.itemMedia,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> itemAvatarLinksRefs(
      Expression<bool> Function($$ItemAvatarLinksTableFilterComposer f) f) {
    final $$ItemAvatarLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.itemAvatarLinks,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemAvatarLinksTableFilterComposer(
              $db: $db,
              $table: $db.itemAvatarLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> roomObjectsRefs(
      Expression<bool> Function($$RoomObjectsTableFilterComposer f) f) {
    final $$RoomObjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.roomObjects,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomObjectsTableFilterComposer(
              $db: $db,
              $table: $db.roomObjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get transferable => $composableBuilder(
      column: $table.transferable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalImageKey => $composableBuilder(
      column: $table.originalImageKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processedImageKey => $composableBuilder(
      column: $table.processedImageKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processedLocalImagePath => $composableBuilder(
      column: $table.processedLocalImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outputType => $composableBuilder(
      column: $table.outputType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processStatus => $composableBuilder(
      column: $table.processStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processErrorMessage => $composableBuilder(
      column: $table.processErrorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processFailureStage => $composableBuilder(
      column: $table.processFailureStage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get usedFrom => $composableBuilder(
      column: $table.usedFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get usedUntil => $composableBuilder(
      column: $table.usedUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get transferable => $composableBuilder(
      column: $table.transferable, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath, builder: (column) => column);

  GeneratedColumn<String> get originalImageKey => $composableBuilder(
      column: $table.originalImageKey, builder: (column) => column);

  GeneratedColumn<String> get processedImageKey => $composableBuilder(
      column: $table.processedImageKey, builder: (column) => column);

  GeneratedColumn<String> get processedLocalImagePath => $composableBuilder(
      column: $table.processedLocalImagePath, builder: (column) => column);

  GeneratedColumn<String> get outputType => $composableBuilder(
      column: $table.outputType, builder: (column) => column);

  GeneratedColumn<String> get processStatus => $composableBuilder(
      column: $table.processStatus, builder: (column) => column);

  GeneratedColumn<String> get processErrorMessage => $composableBuilder(
      column: $table.processErrorMessage, builder: (column) => column);

  GeneratedColumn<String> get processFailureStage => $composableBuilder(
      column: $table.processFailureStage, builder: (column) => column);

  GeneratedColumn<DateTime> get usedFrom =>
      $composableBuilder(column: $table.usedFrom, builder: (column) => column);

  GeneratedColumn<DateTime> get usedUntil =>
      $composableBuilder(column: $table.usedUntil, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> itemMediaRefs<T extends Object>(
      Expression<T> Function($$ItemMediaTableAnnotationComposer a) f) {
    final $$ItemMediaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.itemMedia,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemMediaTableAnnotationComposer(
              $db: $db,
              $table: $db.itemMedia,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> itemAvatarLinksRefs<T extends Object>(
      Expression<T> Function($$ItemAvatarLinksTableAnnotationComposer a) f) {
    final $$ItemAvatarLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.itemAvatarLinks,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemAvatarLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.itemAvatarLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> roomObjectsRefs<T extends Object>(
      Expression<T> Function($$RoomObjectsTableAnnotationComposer a) f) {
    final $$RoomObjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.roomObjects,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomObjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.roomObjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, $$ItemsTableReferences),
    Item,
    PrefetchHooks Function(
        {bool itemMediaRefs, bool itemAvatarLinksRefs, bool roomObjectsRefs})> {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> memo = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> transferable = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<String?> originalImageKey = const Value.absent(),
            Value<String?> processedImageKey = const Value.absent(),
            Value<String?> processedLocalImagePath = const Value.absent(),
            Value<String> outputType = const Value.absent(),
            Value<String> processStatus = const Value.absent(),
            Value<String?> processErrorMessage = const Value.absent(),
            Value<String?> processFailureStage = const Value.absent(),
            Value<DateTime?> usedFrom = const Value.absent(),
            Value<DateTime?> usedUntil = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion(
            itemId: itemId,
            ownerId: ownerId,
            title: title,
            memo: memo,
            status: status,
            transferable: transferable,
            localImagePath: localImagePath,
            originalImageKey: originalImageKey,
            processedImageKey: processedImageKey,
            processedLocalImagePath: processedLocalImagePath,
            outputType: outputType,
            processStatus: processStatus,
            processErrorMessage: processErrorMessage,
            processFailureStage: processFailureStage,
            usedFrom: usedFrom,
            usedUntil: usedUntil,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            Value<String> ownerId = const Value.absent(),
            required String title,
            Value<String> memo = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> transferable = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<String?> originalImageKey = const Value.absent(),
            Value<String?> processedImageKey = const Value.absent(),
            Value<String?> processedLocalImagePath = const Value.absent(),
            Value<String> outputType = const Value.absent(),
            Value<String> processStatus = const Value.absent(),
            Value<String?> processErrorMessage = const Value.absent(),
            Value<String?> processFailureStage = const Value.absent(),
            Value<DateTime?> usedFrom = const Value.absent(),
            Value<DateTime?> usedUntil = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion.insert(
            itemId: itemId,
            ownerId: ownerId,
            title: title,
            memo: memo,
            status: status,
            transferable: transferable,
            localImagePath: localImagePath,
            originalImageKey: originalImageKey,
            processedImageKey: processedImageKey,
            processedLocalImagePath: processedLocalImagePath,
            outputType: outputType,
            processStatus: processStatus,
            processErrorMessage: processErrorMessage,
            processFailureStage: processFailureStage,
            usedFrom: usedFrom,
            usedUntil: usedUntil,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ItemsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {itemMediaRefs = false,
              itemAvatarLinksRefs = false,
              roomObjectsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (itemMediaRefs) db.itemMedia,
                if (itemAvatarLinksRefs) db.itemAvatarLinks,
                if (roomObjectsRefs) db.roomObjects
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemMediaRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ItemsTableReferences._itemMediaRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ItemsTableReferences(db, table, p0).itemMediaRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.itemId == item.itemId),
                        typedResults: items),
                  if (itemAvatarLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ItemsTableReferences
                            ._itemAvatarLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ItemsTableReferences(db, table, p0)
                                .itemAvatarLinksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.itemId == item.itemId),
                        typedResults: items),
                  if (roomObjectsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ItemsTableReferences._roomObjectsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ItemsTableReferences(db, table, p0)
                                .roomObjectsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.itemId == item.itemId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, $$ItemsTableReferences),
    Item,
    PrefetchHooks Function(
        {bool itemMediaRefs, bool itemAvatarLinksRefs, bool roomObjectsRefs})>;
typedef $$ItemMediaTableCreateCompanionBuilder = ItemMediaCompanion Function({
  required String mediaId,
  required String itemId,
  required String mediaType,
  required String localPath,
  Value<String?> storageKey,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ItemMediaTableUpdateCompanionBuilder = ItemMediaCompanion Function({
  Value<String> mediaId,
  Value<String> itemId,
  Value<String> mediaType,
  Value<String> localPath,
  Value<String?> storageKey,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ItemMediaTableReferences
    extends BaseReferences<_$AppDatabase, $ItemMediaTable, ItemMediaRow> {
  $$ItemMediaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items
      .createAlias($_aliasNameGenerator(db.itemMedia.itemId, db.items.itemId));

  $$ItemsTableProcessedTableManager? get itemId {
    if ($_item.itemId == null) return null;
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.itemId($_item.itemId!));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ItemMediaTableFilterComposer
    extends Composer<_$AppDatabase, $ItemMediaTable> {
  $$ItemMediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageKey => $composableBuilder(
      column: $table.storageKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableFilterComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemMediaTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemMediaTable> {
  $$ItemMediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageKey => $composableBuilder(
      column: $table.storageKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableOrderingComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemMediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemMediaTable> {
  $$ItemMediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get storageKey => $composableBuilder(
      column: $table.storageKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemMediaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemMediaTable,
    ItemMediaRow,
    $$ItemMediaTableFilterComposer,
    $$ItemMediaTableOrderingComposer,
    $$ItemMediaTableAnnotationComposer,
    $$ItemMediaTableCreateCompanionBuilder,
    $$ItemMediaTableUpdateCompanionBuilder,
    (ItemMediaRow, $$ItemMediaTableReferences),
    ItemMediaRow,
    PrefetchHooks Function({bool itemId})> {
  $$ItemMediaTableTableManager(_$AppDatabase db, $ItemMediaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemMediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemMediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemMediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> mediaId = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> mediaType = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String?> storageKey = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemMediaCompanion(
            mediaId: mediaId,
            itemId: itemId,
            mediaType: mediaType,
            localPath: localPath,
            storageKey: storageKey,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String mediaId,
            required String itemId,
            required String mediaType,
            required String localPath,
            Value<String?> storageKey = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemMediaCompanion.insert(
            mediaId: mediaId,
            itemId: itemId,
            mediaType: mediaType,
            localPath: localPath,
            storageKey: storageKey,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ItemMediaTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (itemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.itemId,
                    referencedTable:
                        $$ItemMediaTableReferences._itemIdTable(db),
                    referencedColumn:
                        $$ItemMediaTableReferences._itemIdTable(db).itemId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ItemMediaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemMediaTable,
    ItemMediaRow,
    $$ItemMediaTableFilterComposer,
    $$ItemMediaTableOrderingComposer,
    $$ItemMediaTableAnnotationComposer,
    $$ItemMediaTableCreateCompanionBuilder,
    $$ItemMediaTableUpdateCompanionBuilder,
    (ItemMediaRow, $$ItemMediaTableReferences),
    ItemMediaRow,
    PrefetchHooks Function({bool itemId})>;
typedef $$ItemAvatarLinksTableCreateCompanionBuilder = ItemAvatarLinksCompanion
    Function({
  required String itemId,
  required String avatarId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ItemAvatarLinksTableUpdateCompanionBuilder = ItemAvatarLinksCompanion
    Function({
  Value<String> itemId,
  Value<String> avatarId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ItemAvatarLinksTableReferences extends BaseReferences<
    _$AppDatabase, $ItemAvatarLinksTable, ItemAvatarLinkRow> {
  $$ItemAvatarLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
      $_aliasNameGenerator(db.itemAvatarLinks.itemId, db.items.itemId));

  $$ItemsTableProcessedTableManager? get itemId {
    if ($_item.itemId == null) return null;
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.itemId($_item.itemId!));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AvatarsTable _avatarIdTable(_$AppDatabase db) =>
      db.avatars.createAlias($_aliasNameGenerator(
          db.itemAvatarLinks.avatarId, db.avatars.avatarId));

  $$AvatarsTableProcessedTableManager? get avatarId {
    if ($_item.avatarId == null) return null;
    final manager = $$AvatarsTableTableManager($_db, $_db.avatars)
        .filter((f) => f.avatarId($_item.avatarId!));
    final item = $_typedResult.readTableOrNull(_avatarIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ItemAvatarLinksTableFilterComposer
    extends Composer<_$AppDatabase, $ItemAvatarLinksTable> {
  $$ItemAvatarLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableFilterComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AvatarsTableFilterComposer get avatarId {
    final $$AvatarsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.avatars,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AvatarsTableFilterComposer(
              $db: $db,
              $table: $db.avatars,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemAvatarLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemAvatarLinksTable> {
  $$ItemAvatarLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableOrderingComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AvatarsTableOrderingComposer get avatarId {
    final $$AvatarsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.avatars,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AvatarsTableOrderingComposer(
              $db: $db,
              $table: $db.avatars,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemAvatarLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemAvatarLinksTable> {
  $$ItemAvatarLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AvatarsTableAnnotationComposer get avatarId {
    final $$AvatarsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.avatarId,
        referencedTable: $db.avatars,
        getReferencedColumn: (t) => t.avatarId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AvatarsTableAnnotationComposer(
              $db: $db,
              $table: $db.avatars,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemAvatarLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemAvatarLinksTable,
    ItemAvatarLinkRow,
    $$ItemAvatarLinksTableFilterComposer,
    $$ItemAvatarLinksTableOrderingComposer,
    $$ItemAvatarLinksTableAnnotationComposer,
    $$ItemAvatarLinksTableCreateCompanionBuilder,
    $$ItemAvatarLinksTableUpdateCompanionBuilder,
    (ItemAvatarLinkRow, $$ItemAvatarLinksTableReferences),
    ItemAvatarLinkRow,
    PrefetchHooks Function({bool itemId, bool avatarId})> {
  $$ItemAvatarLinksTableTableManager(
      _$AppDatabase db, $ItemAvatarLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemAvatarLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemAvatarLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemAvatarLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> avatarId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemAvatarLinksCompanion(
            itemId: itemId,
            avatarId: avatarId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String avatarId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemAvatarLinksCompanion.insert(
            itemId: itemId,
            avatarId: avatarId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ItemAvatarLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({itemId = false, avatarId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (itemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.itemId,
                    referencedTable:
                        $$ItemAvatarLinksTableReferences._itemIdTable(db),
                    referencedColumn: $$ItemAvatarLinksTableReferences
                        ._itemIdTable(db)
                        .itemId,
                  ) as T;
                }
                if (avatarId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.avatarId,
                    referencedTable:
                        $$ItemAvatarLinksTableReferences._avatarIdTable(db),
                    referencedColumn: $$ItemAvatarLinksTableReferences
                        ._avatarIdTable(db)
                        .avatarId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ItemAvatarLinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemAvatarLinksTable,
    ItemAvatarLinkRow,
    $$ItemAvatarLinksTableFilterComposer,
    $$ItemAvatarLinksTableOrderingComposer,
    $$ItemAvatarLinksTableAnnotationComposer,
    $$ItemAvatarLinksTableCreateCompanionBuilder,
    $$ItemAvatarLinksTableUpdateCompanionBuilder,
    (ItemAvatarLinkRow, $$ItemAvatarLinksTableReferences),
    ItemAvatarLinkRow,
    PrefetchHooks Function({bool itemId, bool avatarId})>;
typedef $$RoomObjectsTableCreateCompanionBuilder = RoomObjectsCompanion
    Function({
  required String objectId,
  Value<String> profileId,
  Value<String> roomId,
  Value<String?> itemId,
  Value<String> objectType,
  Value<String?> assetKey,
  Value<String?> localAssetPath,
  Value<String?> storageKey,
  Value<String> placementSurface,
  Value<int> gridX,
  Value<int> gridY,
  Value<int> gridZ,
  Value<int> spanX,
  Value<int> spanY,
  Value<int> spanZ,
  Value<int> gridVersion,
  Value<double> posX,
  Value<double> posY,
  Value<double> posZ,
  Value<double> scale,
  Value<double> scaleX,
  Value<double> scaleY,
  Value<double> scaleZ,
  Value<double> rotationX,
  Value<double> rotationY,
  Value<double> rotationZ,
  Value<bool> isPlaced,
  Value<int?> originalWidth,
  Value<int?> originalHeight,
  Value<double?> footprintWidth,
  Value<double?> footprintHeight,
  Value<double?> footprintDepth,
  Value<DateTime?> createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$RoomObjectsTableUpdateCompanionBuilder = RoomObjectsCompanion
    Function({
  Value<String> objectId,
  Value<String> profileId,
  Value<String> roomId,
  Value<String?> itemId,
  Value<String> objectType,
  Value<String?> assetKey,
  Value<String?> localAssetPath,
  Value<String?> storageKey,
  Value<String> placementSurface,
  Value<int> gridX,
  Value<int> gridY,
  Value<int> gridZ,
  Value<int> spanX,
  Value<int> spanY,
  Value<int> spanZ,
  Value<int> gridVersion,
  Value<double> posX,
  Value<double> posY,
  Value<double> posZ,
  Value<double> scale,
  Value<double> scaleX,
  Value<double> scaleY,
  Value<double> scaleZ,
  Value<double> rotationX,
  Value<double> rotationY,
  Value<double> rotationZ,
  Value<bool> isPlaced,
  Value<int?> originalWidth,
  Value<int?> originalHeight,
  Value<double?> footprintWidth,
  Value<double?> footprintHeight,
  Value<double?> footprintDepth,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> syncState,
  Value<int> rowid,
});

final class $$RoomObjectsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomObjectsTable, RoomObjectRow> {
  $$RoomObjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoomsTable _roomIdTable(_$AppDatabase db) => db.rooms.createAlias(
      $_aliasNameGenerator(db.roomObjects.roomId, db.rooms.roomId));

  $$RoomsTableProcessedTableManager? get roomId {
    if ($_item.roomId == null) return null;
    final manager = $$RoomsTableTableManager($_db, $_db.rooms)
        .filter((f) => f.roomId($_item.roomId!));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
      $_aliasNameGenerator(db.roomObjects.itemId, db.items.itemId));

  $$ItemsTableProcessedTableManager? get itemId {
    if ($_item.itemId == null) return null;
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.itemId($_item.itemId!));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RoomObjectOccupiedCellsTable,
      List<RoomObjectOccupiedCellRow>> _roomObjectOccupiedCellsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.roomObjectOccupiedCells,
          aliasName: $_aliasNameGenerator(
              db.roomObjects.objectId, db.roomObjectOccupiedCells.objectId));

  $$RoomObjectOccupiedCellsTableProcessedTableManager
      get roomObjectOccupiedCellsRefs {
    final manager = $$RoomObjectOccupiedCellsTableTableManager(
            $_db, $_db.roomObjectOccupiedCells)
        .filter((f) => f.objectId.objectId($_item.objectId));

    final cache =
        $_typedResult.readTableOrNull(_roomObjectOccupiedCellsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoomObjectsTableFilterComposer
    extends Composer<_$AppDatabase, $RoomObjectsTable> {
  $$RoomObjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get objectId => $composableBuilder(
      column: $table.objectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objectType => $composableBuilder(
      column: $table.objectType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetKey => $composableBuilder(
      column: $table.assetKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localAssetPath => $composableBuilder(
      column: $table.localAssetPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageKey => $composableBuilder(
      column: $table.storageKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placementSurface => $composableBuilder(
      column: $table.placementSurface,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridX => $composableBuilder(
      column: $table.gridX, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridY => $composableBuilder(
      column: $table.gridY, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridZ => $composableBuilder(
      column: $table.gridZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get spanX => $composableBuilder(
      column: $table.spanX, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get spanY => $composableBuilder(
      column: $table.spanY, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get spanZ => $composableBuilder(
      column: $table.spanZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridVersion => $composableBuilder(
      column: $table.gridVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posX => $composableBuilder(
      column: $table.posX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posY => $composableBuilder(
      column: $table.posY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posZ => $composableBuilder(
      column: $table.posZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scale => $composableBuilder(
      column: $table.scale, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scaleX => $composableBuilder(
      column: $table.scaleX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scaleY => $composableBuilder(
      column: $table.scaleY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scaleZ => $composableBuilder(
      column: $table.scaleZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rotationX => $composableBuilder(
      column: $table.rotationX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rotationY => $composableBuilder(
      column: $table.rotationY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rotationZ => $composableBuilder(
      column: $table.rotationZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPlaced => $composableBuilder(
      column: $table.isPlaced, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get originalWidth => $composableBuilder(
      column: $table.originalWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get originalHeight => $composableBuilder(
      column: $table.originalHeight,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get footprintWidth => $composableBuilder(
      column: $table.footprintWidth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get footprintHeight => $composableBuilder(
      column: $table.footprintHeight,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get footprintDepth => $composableBuilder(
      column: $table.footprintDepth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableFilterComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableFilterComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> roomObjectOccupiedCellsRefs(
      Expression<bool> Function($$RoomObjectOccupiedCellsTableFilterComposer f)
          f) {
    final $$RoomObjectOccupiedCellsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.objectId,
            referencedTable: $db.roomObjectOccupiedCells,
            getReferencedColumn: (t) => t.objectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoomObjectOccupiedCellsTableFilterComposer(
                  $db: $db,
                  $table: $db.roomObjectOccupiedCells,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RoomObjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomObjectsTable> {
  $$RoomObjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get objectId => $composableBuilder(
      column: $table.objectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objectType => $composableBuilder(
      column: $table.objectType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetKey => $composableBuilder(
      column: $table.assetKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localAssetPath => $composableBuilder(
      column: $table.localAssetPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageKey => $composableBuilder(
      column: $table.storageKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placementSurface => $composableBuilder(
      column: $table.placementSurface,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridX => $composableBuilder(
      column: $table.gridX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridY => $composableBuilder(
      column: $table.gridY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridZ => $composableBuilder(
      column: $table.gridZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get spanX => $composableBuilder(
      column: $table.spanX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get spanY => $composableBuilder(
      column: $table.spanY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get spanZ => $composableBuilder(
      column: $table.spanZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridVersion => $composableBuilder(
      column: $table.gridVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posX => $composableBuilder(
      column: $table.posX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posY => $composableBuilder(
      column: $table.posY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posZ => $composableBuilder(
      column: $table.posZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scale => $composableBuilder(
      column: $table.scale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scaleX => $composableBuilder(
      column: $table.scaleX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scaleY => $composableBuilder(
      column: $table.scaleY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scaleZ => $composableBuilder(
      column: $table.scaleZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rotationX => $composableBuilder(
      column: $table.rotationX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rotationY => $composableBuilder(
      column: $table.rotationY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rotationZ => $composableBuilder(
      column: $table.rotationZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPlaced => $composableBuilder(
      column: $table.isPlaced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get originalWidth => $composableBuilder(
      column: $table.originalWidth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get originalHeight => $composableBuilder(
      column: $table.originalHeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get footprintWidth => $composableBuilder(
      column: $table.footprintWidth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get footprintHeight => $composableBuilder(
      column: $table.footprintHeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get footprintDepth => $composableBuilder(
      column: $table.footprintDepth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableOrderingComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableOrderingComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomObjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomObjectsTable> {
  $$RoomObjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get objectType => $composableBuilder(
      column: $table.objectType, builder: (column) => column);

  GeneratedColumn<String> get assetKey =>
      $composableBuilder(column: $table.assetKey, builder: (column) => column);

  GeneratedColumn<String> get localAssetPath => $composableBuilder(
      column: $table.localAssetPath, builder: (column) => column);

  GeneratedColumn<String> get storageKey => $composableBuilder(
      column: $table.storageKey, builder: (column) => column);

  GeneratedColumn<String> get placementSurface => $composableBuilder(
      column: $table.placementSurface, builder: (column) => column);

  GeneratedColumn<int> get gridX =>
      $composableBuilder(column: $table.gridX, builder: (column) => column);

  GeneratedColumn<int> get gridY =>
      $composableBuilder(column: $table.gridY, builder: (column) => column);

  GeneratedColumn<int> get gridZ =>
      $composableBuilder(column: $table.gridZ, builder: (column) => column);

  GeneratedColumn<int> get spanX =>
      $composableBuilder(column: $table.spanX, builder: (column) => column);

  GeneratedColumn<int> get spanY =>
      $composableBuilder(column: $table.spanY, builder: (column) => column);

  GeneratedColumn<int> get spanZ =>
      $composableBuilder(column: $table.spanZ, builder: (column) => column);

  GeneratedColumn<int> get gridVersion => $composableBuilder(
      column: $table.gridVersion, builder: (column) => column);

  GeneratedColumn<double> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => column);

  GeneratedColumn<double> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => column);

  GeneratedColumn<double> get posZ =>
      $composableBuilder(column: $table.posZ, builder: (column) => column);

  GeneratedColumn<double> get scale =>
      $composableBuilder(column: $table.scale, builder: (column) => column);

  GeneratedColumn<double> get scaleX =>
      $composableBuilder(column: $table.scaleX, builder: (column) => column);

  GeneratedColumn<double> get scaleY =>
      $composableBuilder(column: $table.scaleY, builder: (column) => column);

  GeneratedColumn<double> get scaleZ =>
      $composableBuilder(column: $table.scaleZ, builder: (column) => column);

  GeneratedColumn<double> get rotationX =>
      $composableBuilder(column: $table.rotationX, builder: (column) => column);

  GeneratedColumn<double> get rotationY =>
      $composableBuilder(column: $table.rotationY, builder: (column) => column);

  GeneratedColumn<double> get rotationZ =>
      $composableBuilder(column: $table.rotationZ, builder: (column) => column);

  GeneratedColumn<bool> get isPlaced =>
      $composableBuilder(column: $table.isPlaced, builder: (column) => column);

  GeneratedColumn<int> get originalWidth => $composableBuilder(
      column: $table.originalWidth, builder: (column) => column);

  GeneratedColumn<int> get originalHeight => $composableBuilder(
      column: $table.originalHeight, builder: (column) => column);

  GeneratedColumn<double> get footprintWidth => $composableBuilder(
      column: $table.footprintWidth, builder: (column) => column);

  GeneratedColumn<double> get footprintHeight => $composableBuilder(
      column: $table.footprintHeight, builder: (column) => column);

  GeneratedColumn<double> get footprintDepth => $composableBuilder(
      column: $table.footprintDepth, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableAnnotationComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> roomObjectOccupiedCellsRefs<T extends Object>(
      Expression<T> Function($$RoomObjectOccupiedCellsTableAnnotationComposer a)
          f) {
    final $$RoomObjectOccupiedCellsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.objectId,
            referencedTable: $db.roomObjectOccupiedCells,
            getReferencedColumn: (t) => t.objectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoomObjectOccupiedCellsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.roomObjectOccupiedCells,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RoomObjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoomObjectsTable,
    RoomObjectRow,
    $$RoomObjectsTableFilterComposer,
    $$RoomObjectsTableOrderingComposer,
    $$RoomObjectsTableAnnotationComposer,
    $$RoomObjectsTableCreateCompanionBuilder,
    $$RoomObjectsTableUpdateCompanionBuilder,
    (RoomObjectRow, $$RoomObjectsTableReferences),
    RoomObjectRow,
    PrefetchHooks Function(
        {bool roomId, bool itemId, bool roomObjectOccupiedCellsRefs})> {
  $$RoomObjectsTableTableManager(_$AppDatabase db, $RoomObjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomObjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomObjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomObjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> objectId = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> roomId = const Value.absent(),
            Value<String?> itemId = const Value.absent(),
            Value<String> objectType = const Value.absent(),
            Value<String?> assetKey = const Value.absent(),
            Value<String?> localAssetPath = const Value.absent(),
            Value<String?> storageKey = const Value.absent(),
            Value<String> placementSurface = const Value.absent(),
            Value<int> gridX = const Value.absent(),
            Value<int> gridY = const Value.absent(),
            Value<int> gridZ = const Value.absent(),
            Value<int> spanX = const Value.absent(),
            Value<int> spanY = const Value.absent(),
            Value<int> spanZ = const Value.absent(),
            Value<int> gridVersion = const Value.absent(),
            Value<double> posX = const Value.absent(),
            Value<double> posY = const Value.absent(),
            Value<double> posZ = const Value.absent(),
            Value<double> scale = const Value.absent(),
            Value<double> scaleX = const Value.absent(),
            Value<double> scaleY = const Value.absent(),
            Value<double> scaleZ = const Value.absent(),
            Value<double> rotationX = const Value.absent(),
            Value<double> rotationY = const Value.absent(),
            Value<double> rotationZ = const Value.absent(),
            Value<bool> isPlaced = const Value.absent(),
            Value<int?> originalWidth = const Value.absent(),
            Value<int?> originalHeight = const Value.absent(),
            Value<double?> footprintWidth = const Value.absent(),
            Value<double?> footprintHeight = const Value.absent(),
            Value<double?> footprintDepth = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomObjectsCompanion(
            objectId: objectId,
            profileId: profileId,
            roomId: roomId,
            itemId: itemId,
            objectType: objectType,
            assetKey: assetKey,
            localAssetPath: localAssetPath,
            storageKey: storageKey,
            placementSurface: placementSurface,
            gridX: gridX,
            gridY: gridY,
            gridZ: gridZ,
            spanX: spanX,
            spanY: spanY,
            spanZ: spanZ,
            gridVersion: gridVersion,
            posX: posX,
            posY: posY,
            posZ: posZ,
            scale: scale,
            scaleX: scaleX,
            scaleY: scaleY,
            scaleZ: scaleZ,
            rotationX: rotationX,
            rotationY: rotationY,
            rotationZ: rotationZ,
            isPlaced: isPlaced,
            originalWidth: originalWidth,
            originalHeight: originalHeight,
            footprintWidth: footprintWidth,
            footprintHeight: footprintHeight,
            footprintDepth: footprintDepth,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            version: version,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String objectId,
            Value<String> profileId = const Value.absent(),
            Value<String> roomId = const Value.absent(),
            Value<String?> itemId = const Value.absent(),
            Value<String> objectType = const Value.absent(),
            Value<String?> assetKey = const Value.absent(),
            Value<String?> localAssetPath = const Value.absent(),
            Value<String?> storageKey = const Value.absent(),
            Value<String> placementSurface = const Value.absent(),
            Value<int> gridX = const Value.absent(),
            Value<int> gridY = const Value.absent(),
            Value<int> gridZ = const Value.absent(),
            Value<int> spanX = const Value.absent(),
            Value<int> spanY = const Value.absent(),
            Value<int> spanZ = const Value.absent(),
            Value<int> gridVersion = const Value.absent(),
            Value<double> posX = const Value.absent(),
            Value<double> posY = const Value.absent(),
            Value<double> posZ = const Value.absent(),
            Value<double> scale = const Value.absent(),
            Value<double> scaleX = const Value.absent(),
            Value<double> scaleY = const Value.absent(),
            Value<double> scaleZ = const Value.absent(),
            Value<double> rotationX = const Value.absent(),
            Value<double> rotationY = const Value.absent(),
            Value<double> rotationZ = const Value.absent(),
            Value<bool> isPlaced = const Value.absent(),
            Value<int?> originalWidth = const Value.absent(),
            Value<int?> originalHeight = const Value.absent(),
            Value<double?> footprintWidth = const Value.absent(),
            Value<double?> footprintHeight = const Value.absent(),
            Value<double?> footprintDepth = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomObjectsCompanion.insert(
            objectId: objectId,
            profileId: profileId,
            roomId: roomId,
            itemId: itemId,
            objectType: objectType,
            assetKey: assetKey,
            localAssetPath: localAssetPath,
            storageKey: storageKey,
            placementSurface: placementSurface,
            gridX: gridX,
            gridY: gridY,
            gridZ: gridZ,
            spanX: spanX,
            spanY: spanY,
            spanZ: spanZ,
            gridVersion: gridVersion,
            posX: posX,
            posY: posY,
            posZ: posZ,
            scale: scale,
            scaleX: scaleX,
            scaleY: scaleY,
            scaleZ: scaleZ,
            rotationX: rotationX,
            rotationY: rotationY,
            rotationZ: rotationZ,
            isPlaced: isPlaced,
            originalWidth: originalWidth,
            originalHeight: originalHeight,
            footprintWidth: footprintWidth,
            footprintHeight: footprintHeight,
            footprintDepth: footprintDepth,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            version: version,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RoomObjectsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {roomId = false,
              itemId = false,
              roomObjectOccupiedCellsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (roomObjectOccupiedCellsRefs) db.roomObjectOccupiedCells
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (roomId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.roomId,
                    referencedTable:
                        $$RoomObjectsTableReferences._roomIdTable(db),
                    referencedColumn:
                        $$RoomObjectsTableReferences._roomIdTable(db).roomId,
                  ) as T;
                }
                if (itemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.itemId,
                    referencedTable:
                        $$RoomObjectsTableReferences._itemIdTable(db),
                    referencedColumn:
                        $$RoomObjectsTableReferences._itemIdTable(db).itemId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roomObjectOccupiedCellsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RoomObjectsTableReferences
                            ._roomObjectOccupiedCellsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoomObjectsTableReferences(db, table, p0)
                                .roomObjectOccupiedCellsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.objectId == item.objectId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RoomObjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoomObjectsTable,
    RoomObjectRow,
    $$RoomObjectsTableFilterComposer,
    $$RoomObjectsTableOrderingComposer,
    $$RoomObjectsTableAnnotationComposer,
    $$RoomObjectsTableCreateCompanionBuilder,
    $$RoomObjectsTableUpdateCompanionBuilder,
    (RoomObjectRow, $$RoomObjectsTableReferences),
    RoomObjectRow,
    PrefetchHooks Function(
        {bool roomId, bool itemId, bool roomObjectOccupiedCellsRefs})>;
typedef $$RoomObjectOccupiedCellsTableCreateCompanionBuilder
    = RoomObjectOccupiedCellsCompanion Function({
  required String objectId,
  required String roomId,
  required int gridX,
  required int gridY,
  required int gridZ,
  Value<int> rowid,
});
typedef $$RoomObjectOccupiedCellsTableUpdateCompanionBuilder
    = RoomObjectOccupiedCellsCompanion Function({
  Value<String> objectId,
  Value<String> roomId,
  Value<int> gridX,
  Value<int> gridY,
  Value<int> gridZ,
  Value<int> rowid,
});

final class $$RoomObjectOccupiedCellsTableReferences extends BaseReferences<
    _$AppDatabase, $RoomObjectOccupiedCellsTable, RoomObjectOccupiedCellRow> {
  $$RoomObjectOccupiedCellsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RoomObjectsTable _objectIdTable(_$AppDatabase db) =>
      db.roomObjects.createAlias($_aliasNameGenerator(
          db.roomObjectOccupiedCells.objectId, db.roomObjects.objectId));

  $$RoomObjectsTableProcessedTableManager? get objectId {
    if ($_item.objectId == null) return null;
    final manager = $$RoomObjectsTableTableManager($_db, $_db.roomObjects)
        .filter((f) => f.objectId($_item.objectId!));
    final item = $_typedResult.readTableOrNull(_objectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $RoomsTable _roomIdTable(_$AppDatabase db) => db.rooms.createAlias(
      $_aliasNameGenerator(db.roomObjectOccupiedCells.roomId, db.rooms.roomId));

  $$RoomsTableProcessedTableManager? get roomId {
    if ($_item.roomId == null) return null;
    final manager = $$RoomsTableTableManager($_db, $_db.rooms)
        .filter((f) => f.roomId($_item.roomId!));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoomObjectOccupiedCellsTableFilterComposer
    extends Composer<_$AppDatabase, $RoomObjectOccupiedCellsTable> {
  $$RoomObjectOccupiedCellsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get gridX => $composableBuilder(
      column: $table.gridX, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridY => $composableBuilder(
      column: $table.gridY, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gridZ => $composableBuilder(
      column: $table.gridZ, builder: (column) => ColumnFilters(column));

  $$RoomObjectsTableFilterComposer get objectId {
    final $$RoomObjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.objectId,
        referencedTable: $db.roomObjects,
        getReferencedColumn: (t) => t.objectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomObjectsTableFilterComposer(
              $db: $db,
              $table: $db.roomObjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableFilterComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomObjectOccupiedCellsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomObjectOccupiedCellsTable> {
  $$RoomObjectOccupiedCellsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get gridX => $composableBuilder(
      column: $table.gridX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridY => $composableBuilder(
      column: $table.gridY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gridZ => $composableBuilder(
      column: $table.gridZ, builder: (column) => ColumnOrderings(column));

  $$RoomObjectsTableOrderingComposer get objectId {
    final $$RoomObjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.objectId,
        referencedTable: $db.roomObjects,
        getReferencedColumn: (t) => t.objectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomObjectsTableOrderingComposer(
              $db: $db,
              $table: $db.roomObjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableOrderingComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomObjectOccupiedCellsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomObjectOccupiedCellsTable> {
  $$RoomObjectOccupiedCellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get gridX =>
      $composableBuilder(column: $table.gridX, builder: (column) => column);

  GeneratedColumn<int> get gridY =>
      $composableBuilder(column: $table.gridY, builder: (column) => column);

  GeneratedColumn<int> get gridZ =>
      $composableBuilder(column: $table.gridZ, builder: (column) => column);

  $$RoomObjectsTableAnnotationComposer get objectId {
    final $$RoomObjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.objectId,
        referencedTable: $db.roomObjects,
        getReferencedColumn: (t) => t.objectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomObjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.roomObjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableAnnotationComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomObjectOccupiedCellsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoomObjectOccupiedCellsTable,
    RoomObjectOccupiedCellRow,
    $$RoomObjectOccupiedCellsTableFilterComposer,
    $$RoomObjectOccupiedCellsTableOrderingComposer,
    $$RoomObjectOccupiedCellsTableAnnotationComposer,
    $$RoomObjectOccupiedCellsTableCreateCompanionBuilder,
    $$RoomObjectOccupiedCellsTableUpdateCompanionBuilder,
    (RoomObjectOccupiedCellRow, $$RoomObjectOccupiedCellsTableReferences),
    RoomObjectOccupiedCellRow,
    PrefetchHooks Function({bool objectId, bool roomId})> {
  $$RoomObjectOccupiedCellsTableTableManager(
      _$AppDatabase db, $RoomObjectOccupiedCellsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomObjectOccupiedCellsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomObjectOccupiedCellsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomObjectOccupiedCellsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> objectId = const Value.absent(),
            Value<String> roomId = const Value.absent(),
            Value<int> gridX = const Value.absent(),
            Value<int> gridY = const Value.absent(),
            Value<int> gridZ = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomObjectOccupiedCellsCompanion(
            objectId: objectId,
            roomId: roomId,
            gridX: gridX,
            gridY: gridY,
            gridZ: gridZ,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String objectId,
            required String roomId,
            required int gridX,
            required int gridY,
            required int gridZ,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomObjectOccupiedCellsCompanion.insert(
            objectId: objectId,
            roomId: roomId,
            gridX: gridX,
            gridY: gridY,
            gridZ: gridZ,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RoomObjectOccupiedCellsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({objectId = false, roomId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (objectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.objectId,
                    referencedTable: $$RoomObjectOccupiedCellsTableReferences
                        ._objectIdTable(db),
                    referencedColumn: $$RoomObjectOccupiedCellsTableReferences
                        ._objectIdTable(db)
                        .objectId,
                  ) as T;
                }
                if (roomId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.roomId,
                    referencedTable: $$RoomObjectOccupiedCellsTableReferences
                        ._roomIdTable(db),
                    referencedColumn: $$RoomObjectOccupiedCellsTableReferences
                        ._roomIdTable(db)
                        .roomId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RoomObjectOccupiedCellsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RoomObjectOccupiedCellsTable,
        RoomObjectOccupiedCellRow,
        $$RoomObjectOccupiedCellsTableFilterComposer,
        $$RoomObjectOccupiedCellsTableOrderingComposer,
        $$RoomObjectOccupiedCellsTableAnnotationComposer,
        $$RoomObjectOccupiedCellsTableCreateCompanionBuilder,
        $$RoomObjectOccupiedCellsTableUpdateCompanionBuilder,
        (RoomObjectOccupiedCellRow, $$RoomObjectOccupiedCellsTableReferences),
        RoomObjectOccupiedCellRow,
        PrefetchHooks Function({bool objectId, bool roomId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AvatarsTableTableManager get avatars =>
      $$AvatarsTableTableManager(_db, _db.avatars);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$RoomAvatarAssignmentsTableTableManager get roomAvatarAssignments =>
      $$RoomAvatarAssignmentsTableTableManager(_db, _db.roomAvatarAssignments);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$ItemMediaTableTableManager get itemMedia =>
      $$ItemMediaTableTableManager(_db, _db.itemMedia);
  $$ItemAvatarLinksTableTableManager get itemAvatarLinks =>
      $$ItemAvatarLinksTableTableManager(_db, _db.itemAvatarLinks);
  $$RoomObjectsTableTableManager get roomObjects =>
      $$RoomObjectsTableTableManager(_db, _db.roomObjects);
  $$RoomObjectOccupiedCellsTableTableManager get roomObjectOccupiedCells =>
      $$RoomObjectOccupiedCellsTableTableManager(
          _db, _db.roomObjectOccupiedCells);
}
