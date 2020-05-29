// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'luser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LUserRegistered _$LUserRegisteredFromJson(Map<String, dynamic> json) {
  return LUserRegistered(
    json['#text'] as int,
  );
}

Map<String, dynamic> _$LUserRegisteredToJson(LUserRegistered instance) =>
    <String, dynamic>{
      '#text': instance.timestamp,
    };

LUser _$LUserFromJson(Map<String, dynamic> json) {
  return LUser(
    json['id'] as String,
    json['name'] as String,
    json['realname'] as String,
    json['url'] as String,
    (json['image'] as List)
        ?.map((e) =>
            e == null ? null : LImage.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['country'] as String,
    json['age'] as String,
    json['gender'] as String,
    json['subscriber'] as String,
    json['playcount'] as String,
    json['playlists'] as String,
    json['bootstrap'] as String,
    json['registered'] == null
        ? null
        : LUserRegistered.fromJson(json['registered'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LUserToJson(LUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'realname': instance.realname,
      'url': instance.url,
      'image': instance.images,
      'country': instance.country,
      'age': instance.age,
      'gender': instance.gender,
      'subscriber': instance.subscriber,
      'playcount': instance.playCount,
      'playlists': instance.playlists,
      'bootstrap': instance.bootstrap,
      'registered': instance.registered,
    };

LAuthenticationResponseSession _$LAuthenticationResponseSessionFromJson(
    Map<String, dynamic> json) {
  return LAuthenticationResponseSession(
    json['name'] as String,
    json['key'] as String,
  );
}

Map<String, dynamic> _$LAuthenticationResponseSessionToJson(
        LAuthenticationResponseSession instance) =>
    <String, dynamic>{
      'name': instance.name,
      'key': instance.key,
    };
