import 'package:finale/services/generic.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class SArtistSimple extends BasicArtist {
  String name;

  @JsonKey(name: 'href')
  String url;

  SArtistSimple(this.name, this.url);

  factory SArtistSimple.fromJson(Map<String, dynamic> json) =>
      _$SArtistSimpleFromJson(json);
}
