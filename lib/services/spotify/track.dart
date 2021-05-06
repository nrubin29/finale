import 'package:finale/services/generic.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

@JsonSerializable()
class STrack extends Track {
  SAlbumSimple album;

  List<SArtistSimple> artists; // Should be SArtist

  @JsonKey(name: 'duration_ms')
  int durationMs;

  @JsonKey(name: 'href')
  String url;

  String name;

  String get albumName => album.name;

  String get artistName => artists.first.name;

  String get imageUrl => album.imageUrl;

  STrack(this.album, this.artists, this.durationMs, this.url, this.name);

  factory STrack.fromJson(Map<String, dynamic> json) => _$STrackFromJson(json);
}
