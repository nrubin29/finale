import 'package:json_annotation/json_annotation.dart';

part 'lcommon.g.dart';

@JsonSerializable()
class LScrobbleResponseScrobblesAttr {
  int accepted;
  int ignored;

  LScrobbleResponseScrobblesAttr(this.accepted, this.ignored);

  factory LScrobbleResponseScrobblesAttr.fromJson(Map<String, dynamic> json) =>
      _$LScrobbleResponseScrobblesAttrFromJson(json);

  Map<String, dynamic> toJson() => _$LScrobbleResponseScrobblesAttrToJson(this);
}

@JsonSerializable()
class LTag {
  String name;

  LTag(this.name);

  factory LTag.fromJson(Map<String, dynamic> json) => _$LTagFromJson(json);

  Map<String, dynamic> toJson() => _$LTagToJson(this);
}

@JsonSerializable()
class LTopTags {
  @JsonKey(name: 'tag')
  List<LTag> tags;

  LTopTags(this.tags);

  factory LTopTags.fromJson(Map<String, dynamic> json) =>
      _$LTopTagsFromJson(json);

  Map<String, dynamic> toJson() => _$LTopTagsToJson(this);
}

@JsonSerializable()
class LAttr {
  @JsonKey(fromJson: int.parse)
  int page;

  @JsonKey(fromJson: int.parse)
  int total;

  String user;

  @JsonKey(fromJson: int.parse)
  int perPage;

  @JsonKey(fromJson: int.parse)
  int totalPages;

  LAttr(this.page, this.total, this.user, this.perPage, this.totalPages);

  factory LAttr.fromJson(Map<String, dynamic> json) => _$LAttrFromJson(json);

  Map<String, dynamic> toJson() => _$LAttrToJson(this);
}
