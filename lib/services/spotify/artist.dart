import 'package:finale/services/generic.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class SArtistSimple extends BasicArtist {
  String id;
  String name;

  @JsonKey(name: 'href')
  String url;

  SArtistSimple(this.id, this.name, this.url);

  factory SArtistSimple.fromJson(Map<String, dynamic> json) =>
      _$SArtistSimpleFromJson(json);
}

@JsonSerializable()
class SArtist extends FullArtist {
  String id;
  String name;

  @JsonKey(name: 'href')
  String url;

  @JsonKey(name: 'images', fromJson: extractImageUrl)
  String imageUrl;

  SArtist(this.id, this.name, this.url, this.imageUrl);

  factory SArtist.fromJson(Map<String, dynamic> json) =>
      _$SArtistFromJson(json);
}
