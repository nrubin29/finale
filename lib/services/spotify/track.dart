import 'package:finale/services/generic.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

@JsonSerializable()
class STrack extends Track {
  @JsonKey(name: 'album')
  SAlbumSimple albumObject;

  List<SArtistSimple> artists; // Should be SArtist

  @JsonKey(name: 'duration_ms')
  int durationMs;

  @JsonKey(name: 'href')
  String url;

  String name;

  String get albumName => albumObject.name;

  String get artistName => artists.first.name;

  STrack(this.albumObject, this.artists, this.durationMs, this.url, this.name);

  factory STrack.fromJson(Map<String, dynamic> json) => _$STrackFromJson(json);
}
