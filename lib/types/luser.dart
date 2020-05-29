import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import 'lcommon.dart';

part 'luser.g.dart';

@JsonSerializable()
class LUserRegistered {
  @JsonKey(name: '#text')
  int timestamp;

  LUserRegistered(this.timestamp);

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  String get dateFormatted => DateFormat('dd MMM yyyy').format(date);

  factory LUserRegistered.fromJson(Map<String, dynamic> json) =>
      _$LUserRegisteredFromJson(json);

  Map<String, dynamic> toJson() => _$LUserRegisteredToJson(this);
}

@JsonSerializable()
class LUser {
  String id;
  String name;
  String realname;
  String url;

  @JsonKey(name: 'image')
  List<LImage> images;

  String country;
  String age;
  String gender;
  String subscriber;

  @JsonKey(name: 'playcount')
  String playCount;

  String playlists;
  String bootstrap;
  LUserRegistered registered;

  String get playCountFormatted => NumberFormat().format(int.parse(playCount));

  LUser(
      this.id,
      this.name,
      this.realname,
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
