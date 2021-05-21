import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class LTopAlbumsResponseAlbumArtist extends BasicArtist {
  @override
  final String name;

  @override
  final String url;

  LTopAlbumsResponseAlbumArtist(this.name, this.url);

  factory LTopAlbumsResponseAlbumArtist.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumArtistFromJson(json);
}

@JsonSerializable()
class LTopAlbumsResponseAlbum extends BasicScrobbledAlbum with HasPlayCount {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(name: 'playcount', fromJson: parseInt)
  final int playCount;

  @override
  final LTopAlbumsResponseAlbumArtist artist;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  final ImageId? imageId;

  LTopAlbumsResponseAlbum(
      this.name, this.url, this.playCount, this.artist, this.imageId);

  factory LTopAlbumsResponseAlbum.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumFromJson(json);
}

@JsonSerializable()
class LTopAlbumsResponseTopAlbums {
  @JsonKey(name: 'album')
  final List<LTopAlbumsResponseAlbum> albums;

  @JsonKey(name: '@attr')
  final LAttr attr;

  const LTopAlbumsResponseTopAlbums(this.albums, this.attr);

  factory LTopAlbumsResponseTopAlbums.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseTopAlbumsFromJson(json);
}

@JsonSerializable()
class LAlbumMatch extends BasicAlbum {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(name: 'artist')
  final String artistName;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  final ImageId? imageId;

  @override
  BasicArtist get artist =>
      ConcreteBasicArtist(artistName, url.substring(0, url.lastIndexOf('/')));

  LAlbumMatch(this.name, this.url, this.artistName, this.imageId);

  factory LAlbumMatch.fromJson(Map<String, dynamic> json) =>
      _$LAlbumMatchFromJson(json);
}

@JsonSerializable()
class LAlbumSearchResponse {
  @JsonKey(name: 'album')
  final List<LAlbumMatch> albums;

  const LAlbumSearchResponse(this.albums);

  factory LAlbumSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LAlbumSearchResponseFromJson(json);
}

@JsonSerializable()
class LAlbumTrack extends ScrobbleableTrack {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(fromJson: intParseSafe)
  @override
  final int? duration;

  // Not final because it's set by LAlbum.
  String? album;

  final LTopAlbumsResponseAlbumArtist artist;

  // The non-null assertion is safe because [album] will be set before this is
  // called.
  @override
  String get albumName => album!;

  @override
  String get artistName => artist.name;

  @override
  String? get displaySubtitle => null;

  LAlbumTrack(this.name, this.url, this.duration, this.album, this.artist);

  factory LAlbumTrack.fromJson(Map<String, dynamic> json) =>
      _$LAlbumTrackFromJson(json);
}

@JsonSerializable()
class LAlbumTracks {
  @JsonKey(name: 'track', fromJson: parseTracks)
  final List<LAlbumTrack> tracks;

  const LAlbumTracks(this.tracks);

  factory LAlbumTracks.fromJson(Map<String, dynamic> json) =>
      _$LAlbumTracksFromJson(json);

  static List<LAlbumTrack> parseTracks(json) => json == null
      ? const []
      : json is List<dynamic>
          ? json.map((e) => LAlbumTrack.fromJson(e)).toList(growable: false)
          : List.unmodifiable([LAlbumTrack.fromJson(json)]);
}

@JsonSerializable()
class LAlbum extends FullAlbum {
  @override
  final String name;

  @JsonKey(name: 'artist')
  final String artistName;

  @override
  final String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  final ImageId? imageId;

  @JsonKey(name: 'playcount', fromJson: parseInt)
  final int playCount;

  @JsonKey(fromJson: parseInt)
  final int listeners;

  @JsonKey(name: 'userplaycount', fromJson: parseInt)
  final int userPlayCount;

  @JsonKey(name: 'tracks')
  final LAlbumTracks? tracksObject;

  @JsonKey(name: 'tags', fromJson: LTopTags.fromJsonSafe)
  final LTopTags topTags;

  final LWiki? wiki;

  @override
  BasicArtist get artist =>
      ConcreteBasicArtist(artistName, url.substring(0, url.lastIndexOf('/')));

  @override
  List<LAlbumTrack> get tracks => (tracksObject?.tracks ?? const [])
    ..forEach((element) {
      element.album = name;
    });

  LAlbum(
      this.name,
      this.artistName,
      this.url,
      this.imageId,
      this.playCount,
      this.userPlayCount,
      this.listeners,
      this.tracksObject,
      this.topTags,
      this.wiki);

  factory LAlbum.fromJson(Map<String, dynamic> json) => _$LAlbumFromJson(json);
}
