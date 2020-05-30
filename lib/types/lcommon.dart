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
