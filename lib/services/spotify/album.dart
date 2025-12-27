import 'package:finale/services/generic.dart';
import 'package:finale/services/image_provider.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class SAlbumSimple extends BasicAlbum {
  final List<SArtistSimple> artists;

  @JsonKey(name: 'href')
  @override
  final String? url;

  @override
  final String name;

  final String? id;

  @JsonKey(name: 'images', fromJson: extractImageId)
  @override
  final ImageProvider? imageProvider;

  @override
  BasicArtist get artist => artists.first;

  SAlbumSimple(this.artists, this.url, this.name, this.id, this.imageProvider);

  factory SAlbumSimple.fromJson(Map<String, dynamic> json) =>
      _$SAlbumSimpleFromJson(json);

  @override
  String toString() => 'SAlbumSimple(name=$name, artist=${artist.name})';
}

@JsonSerializable()
class SAlbumFull extends FullAlbum {
  final List<SArtistSimple> artists;

  @JsonKey(name: 'href')
  @override
  final String url;

  @override
  final String name;

  final String id;

  @JsonKey(name: 'images', fromJson: extractImageId)
  @override
  final ImageProvider? imageProvider;

  @JsonKey(name: 'tracks', fromJson: extractItems)
  final List<STrackSimple> rawTracks;

  @override
  BasicArtist get artist => artists.first;

  @override
  List<SAlbumTrack> get tracks => rawTracks
      .map((track) => SAlbumTrack(track, name))
      .toList(growable: false);

  SAlbumFull(
    this.artists,
    this.url,
    this.name,
    this.id,
    this.imageProvider,
    this.rawTracks,
  );

  factory SAlbumFull.fromJson(Map<String, dynamic> json) =>
      _$SAlbumFullFromJson(json);

  static List<STrackSimple> extractItems(Map<String, dynamic> object) =>
      (object['items'] as List<dynamic>)
          .map((item) => STrackSimple.fromJson(item))
          .toList(growable: false);
}

class SAlbumTrack extends STrackSimple {
  @override
  final String albumName;

  SAlbumTrack(STrackSimple track, this.albumName)
    : super(track.artists, track.durationMs, track.url, track.name);

  @override
  String? get displaySubtitle => null;
}
