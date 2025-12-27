import 'package:finale/services/generic.dart';
import 'package:finale/services/image_provider.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class SArtistSimple extends BasicArtist {
  final String? id;

  @override
  final String name;

  @JsonKey(name: 'href')
  @override
  final String? url;

  @override
  late final imageProvider = .delegated(url, Spotify.getFullArtist(this));

  SArtistSimple(this.id, this.name, this.url);

  factory SArtistSimple.fromJson(Map<String, dynamic> json) =>
      _$SArtistSimpleFromJson(json);

  @override
  String toString() => 'SArtistSimple(name=$name)';
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
  final ImageProvider? imageProvider;

  SArtist(this.id, this.name, this.url, this.imageProvider);

  factory SArtist.fromJson(Map<String, dynamic> json) =>
      _$SArtistFromJson(json);

  @override
  String toString() => 'SArtist(name=$name)';
}
