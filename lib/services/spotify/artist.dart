import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class SArtistSimple extends BasicArtist {
  final String id;

  @override
  final String name;

  @JsonKey(name: 'href')
  @override
  final String url;

  @override
  Future<ImageId> get imageId async =>
      (await Spotify.getFullArtist(this)).imageId;

  SArtistSimple(this.id, this.name, this.url);

  factory SArtistSimple.fromJson(Map<String, dynamic> json) =>
      _$SArtistSimpleFromJson(json);
}

@JsonSerializable()
class SArtist extends FullArtist {
  final String id;

  @override
  final String name;

  @JsonKey(name: 'href')
  @override
  final String url;

  @JsonKey(name: 'images', fromJson: extractImageId)
  @override
  final ImageId imageId;

  SArtist(this.id, this.name, this.url, this.imageId);

  factory SArtist.fromJson(Map<String, dynamic> json) =>
      _$SArtistFromJson(json);
}
