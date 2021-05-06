import 'package:finale/services/generic.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class SAlbumSimple extends BasicAlbum {
  List<SArtistSimple> artists;

  @JsonKey(name: 'href')
  String url;

  String name;
  String id;

  @JsonKey(name: 'images', fromJson: extractImageUrl)
  String imageUrl;

  BasicArtist get artist => artists.first;

  SAlbumSimple(this.artists, this.url, this.name, this.id, this.imageUrl);

  factory SAlbumSimple.fromJson(Map<String, dynamic> json) =>
      _$SAlbumSimpleFromJson(json);
}

@JsonSerializable()
class SAlbumFull extends FullAlbum {
  List<SArtistSimple> artists; // Should be SArtistFull

  @JsonKey(name: 'href')
  String url;

  String name;
  String id;

  @JsonKey(name: 'images', fromJson: extractImageUrl)
  String imageUrl;

  @JsonKey(fromJson: extractItems)
  List<STrackSimple> tracks;

  BasicArtist get artist => artists.first;

  SAlbumFull(
      this.artists, this.url, this.name, this.id, this.imageUrl, this.tracks);

  factory SAlbumFull.fromJson(Map<String, dynamic> json) =>
      _$SAlbumFullFromJson(json);

  static List<STrackSimple> extractItems(Map<String, dynamic> object) =>
      (object['items'] as List<dynamic>)
          .map((item) => STrackSimple.fromJson(item))
          .toList(growable: false);
}
