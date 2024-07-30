// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_changes_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserChangesModel _$UserChangesModelFromJson(Map<String, dynamic> json) =>
    UserChangesModel(
      changes: (json['changes'] as List<dynamic>)
          .map((e) => UserChangeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserChangesModelToJson(UserChangesModel instance) =>
    <String, dynamic>{
      'changes': instance.changes.map((e) => e.toJson()).toList(),
    };
