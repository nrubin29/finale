import 'package:json_annotation/json_annotation.dart';

part 'lcommon.g.dart';

@JsonSerializable()
class LScrobbleResponseScrobblesAttr {
  int accepted;
  int ignored;

  LScrobbleResponseScrobblesAttr(this.accepted, this.ignored);

  factory LScrobbleResponseScrobblesAttr.fromJson(Map<String, dynamic> json) =>
      _$LScrobbleResponseScrobblesAttrFromJson(json);
}

@JsonSerializable()
class LTag {
  String name;

  LTag(this.name);

  factory LTag.fromJson(Map<String, dynamic> json) => _$LTagFromJson(json);
}

@JsonSerializable()
class LTopTags {
  @JsonKey(name: 'tag')
  List<LTag> tags;

  LTopTags(this.tags);

  factory LTopTags.fromJson(Map<String, dynamic> json) =>
      _$LTopTagsFromJson(json);
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
}

@JsonSerializable()
class LWiki {
  String published;
  String summary;
  String content;

  LWiki(this.published, this.summary, this.content);

  factory LWiki.fromJson(Map<String, dynamic> json) => _$LWikiFromJson(json);
}
