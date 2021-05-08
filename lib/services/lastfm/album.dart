import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class LTopAlbumsResponseAlbumArtist extends BasicArtist {
  String name;
  String url;

  LTopAlbumsResponseAlbumArtist(this.name, this.url);

  factory LTopAlbumsResponseAlbumArtist.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumArtistFromJson(json);
}

@JsonSerializable()
class LTopAlbumsResponseAlbum extends BasicScrobbledAlbum with HasPlayCount {
  String name;
  String url;

  @JsonKey(name: 'playcount', fromJson: int.parse)
  int playCount;

  LTopAlbumsResponseAlbumArtist artist;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  ImageId imageId;

  LTopAlbumsResponseAlbum(
      this.name, this.url, this.playCount, this.artist, this.imageId);

  factory LTopAlbumsResponseAlbum.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumFromJson(json);
}

@JsonSerializable()
class LTopAlbumsResponseTopAlbums {
  @JsonKey(name: 'album')
  List<LTopAlbumsResponseAlbum> albums;

  @JsonKey(name: '@attr')
  LAttr attr;

  LTopAlbumsResponseTopAlbums(this.albums, this.attr);

  factory LTopAlbumsResponseTopAlbums.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseTopAlbumsFromJson(json);
}

@JsonSerializable()
class LAlbumMatch extends BasicAlbum {
  String name;
  String url;

  @JsonKey(name: 'artist')
  String artistName;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  ImageId imageId;

  BasicArtist get artist =>
      ConcreteBasicArtist(artistName, url.substring(0, url.lastIndexOf('/')));

  LAlbumMatch(this.name, this.url, this.artistName, this.imageId);

  factory LAlbumMatch.fromJson(Map<String, dynamic> json) =>
      _$LAlbumMatchFromJson(json);
}

@JsonSerializable()
class LAlbumSearchResponse {
  @JsonKey(name: 'album')
  List<LAlbumMatch> albums;

  LAlbumSearchResponse(this.albums);

  factory LAlbumSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LAlbumSearchResponseFromJson(json);
}

@JsonSerializable()
class LAlbumTrack extends ScrobbleableTrack {
  String name;
  String url;

  @JsonKey(fromJson: intParseSafe)
  int duration;

  String album;

  LTopAlbumsResponseAlbumArtist artist;

  String get albumName => album;

  String get artistName => artist.name;

  String get displaySubtitle => null;

  LAlbumTrack(this.name, this.url, this.duration, this.album, this.artist);

  factory LAlbumTrack.fromJson(Map<String, dynamic> json) =>
      _$LAlbumTrackFromJson(json);
}

@JsonSerializable()
class LAlbumTracks {
  @JsonKey(name: 'track')
  List<LAlbumTrack> tracks;

  LAlbumTracks(this.tracks);

  factory LAlbumTracks.fromJson(Map<String, dynamic> json) =>
      _$LAlbumTracksFromJson(json);
}

@JsonSerializable()
class LAlbum extends FullAlbum {
  String name;

  @JsonKey(name: 'artist')
  String artistName;

  String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  ImageId imageId;

  @JsonKey(name: 'playcount', fromJson: int.parse)
  int playCount;

  @JsonKey(fromJson: int.parse)
  int listeners;

  @JsonKey(name: 'userplaycount', fromJson: int.parse)
  int userPlayCount;

  @JsonKey(name: 'tracks')
  LAlbumTracks tracksObject;

  @JsonKey(name: 'tags')
  LTopTags topTags;

  LWiki wiki;

  BasicArtist get artist =>
      ConcreteBasicArtist(artistName, url.substring(0, url.lastIndexOf('/')));

  List<LAlbumTrack> get tracks => tracksObject.tracks
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
