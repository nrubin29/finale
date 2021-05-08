import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

@JsonSerializable()
class STrackSimple extends ScrobbleableTrack {
  List<SArtistSimple> artists;

  @JsonKey(name: 'duration_ms')
  int durationMs;

  @JsonKey(name: 'href')
  String url;

  String name;

  String get albumName => null;

  String get artistName => artists.first.name;

  int get duration => durationMs ~/ 1000;

  STrackSimple(this.artists, this.durationMs, this.url, this.name);

  factory STrackSimple.fromJson(Map<String, dynamic> json) =>
      _$STrackSimpleFromJson(json);
}

@JsonSerializable()
class STrack extends ScrobbleableTrack {
  SAlbumSimple album;

  List<SArtistSimple> artists; // Should be SArtist

  @JsonKey(name: 'duration_ms')
  int durationMs;

  @JsonKey(name: 'href')
  String url;

  String name;

  String get albumName => album.name;

  String get artistName => artists.first.name;

  @override
  ImageId get imageId => album.imageId;

  int get duration => durationMs ~/ 1000;

  STrack(this.album, this.artists, this.durationMs, this.url, this.name);

  factory STrack.fromJson(Map<String, dynamic> json) => _$STrackFromJson(json);
}
