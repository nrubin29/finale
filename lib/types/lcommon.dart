import 'package:json_annotation/json_annotation.dart';
import 'package:simplescrobble/types/generic.dart';

part 'lcommon.g.dart';

@JsonSerializable()
class LImage extends GenericImage {
  @JsonKey(name: '#text')
  String url;

  String size;

  LImage(this.url, this.size);

  factory LImage.fromJson(Map<String, dynamic> json) => _$LImageFromJson(json);

  Map<String, dynamic> toJson() => _$LImageToJson(this);
}

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
