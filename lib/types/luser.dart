import 'package:finale/types/generic.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'luser.g.dart';

@JsonSerializable()
class LUserRegistered {
  @JsonKey(name: 'unixtime', fromJson: fromSecondsSinceEpoch)
  DateTime date;

  LUserRegistered(this.date);

  String get dateFormatted => DateFormat('dd MMM yyyy').format(date);

  factory LUserRegistered.fromJson(Map<String, dynamic> json) =>
      _$LUserRegisteredFromJson(json);
}

@JsonSerializable()
class LUser extends Displayable {
  String name;

  @JsonKey(name: 'realname')
  String realName;

  String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  String imageId;

  String country;

  @JsonKey(fromJson: intParseSafe)
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

  LUser(
      this.name,
      this.realName,
      this.url,
      this.imageId,
      this.country,
      this.age,
      this.gender,
      this.subscriber,
      this.playCount,
      this.playlists,
      this.bootstrap,
      this.registered);

  @override
  DisplayableType get type => DisplayableType.user;

  @override
  String get displayTitle => name;

  @override
  String get displaySubtitle => realName;

  factory LUser.fromJson(Map<String, dynamic> json) => _$LUserFromJson(json);
}

@JsonSerializable()
class LUserFriendsResponse {
  @JsonKey(name: 'user')
  List<LUser> friends;

  LUserFriendsResponse(this.friends);

  factory LUserFriendsResponse.fromJson(Map<String, dynamic> json) =>
      _$LUserFriendsResponseFromJson(json);
}

@JsonSerializable()
class LAuthenticationResponseSession {
  String name;
  String key;

  LAuthenticationResponseSession(this.name, this.key);

  factory LAuthenticationResponseSession.fromJson(Map<String, dynamic> json) =>
      _$LAuthenticationResponseSessionFromJson(json);
}
