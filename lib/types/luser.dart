import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lcommon.dart';

part 'luser.g.dart';

@JsonSerializable()
class LUserRegistered {
  @JsonKey(name: '#text', fromJson: fromSecondsSinceEpoch)
  DateTime date;

  LUserRegistered(this.date);

  String get dateFormatted => DateFormat('dd MMM yyyy').format(date);

  factory LUserRegistered.fromJson(Map<String, dynamic> json) =>
      _$LUserRegisteredFromJson(json);

  Map<String, dynamic> toJson() => _$LUserRegisteredToJson(this);
}

@JsonSerializable()
class LUser {
//  @JsonKey(fromJson: int.parse)
//  int id;

  String name;

  @JsonKey(name: 'realname')
  String realName;

  String url;

  @JsonKey(name: 'image')
  List<LImage> images;

  String country;

  @JsonKey(fromJson: int.parse)
  int age;

  String gender;

  @JsonKey(fromJson: convertStringToBoolean)
  bool subscriber;

  @JsonKey(name: 'playcount', fromJson: int.parse)
  int playCount;

  @JsonKey(fromJson: int.parse)
  int playlists;

  @JsonKey(fromJson: int.parse)
  int bootstrap;

  LUserRegistered registered;

  String get playCountFormatted => NumberFormat().format(playCount);

  LUser(
      //      this.id,
      this.name,
      this.realName,
      this.url,
      this.images,
      this.country,
      this.age,
      this.gender,
      this.subscriber,
      this.playCount,
      this.playlists,
      this.bootstrap,
      this.registered);

  factory LUser.fromJson(Map<String, dynamic> json) => _$LUserFromJson(json);

  Map<String, dynamic> toJson() => _$LUserToJson(this);
}

@JsonSerializable()
class LAuthenticationResponseSession {
  String name;
  String key;

  LAuthenticationResponseSession(this.name, this.key);

  factory LAuthenticationResponseSession.fromJson(Map<String, dynamic> json) =>
      _$LAuthenticationResponseSessionFromJson(json);

  Map<String, dynamic> toJson() => _$LAuthenticationResponseSessionToJson(this);
}
