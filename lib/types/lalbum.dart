import 'package:json_annotation/json_annotation.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lcommon.dart';

part 'lalbum.g.dart';

@JsonSerializable()
class LTopAlbumsResponseAlbumArtist extends BasicArtist {
  String name;

  LTopAlbumsResponseAlbumArtist(this.name);

  factory LTopAlbumsResponseAlbumArtist.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumArtistFromJson(json);

  Map<String, dynamic> toJson() => _$LTopAlbumsResponseAlbumArtistToJson(this);
}

@JsonSerializable()
class LTopAlbumsResponseAlbum extends BasicScrobbledAlbum {
  String name;

  @JsonKey(name: 'playcount', fromJson: int.parse)
  int playCount;

  LTopAlbumsResponseAlbumArtist artist;

  @JsonKey(name: 'image')
  List<LImage> images;

  LTopAlbumsResponseAlbum(this.name, this.playCount, this.artist, this.images);

  factory LTopAlbumsResponseAlbum.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumFromJson(json);

  Map<String, dynamic> toJson() => _$LTopAlbumsResponseAlbumToJson(this);
}

@JsonSerializable()
class LTopAlbumsResponseTopAlbums {
  @JsonKey(name: 'album')
  List<LTopAlbumsResponseAlbum> albums;

  LTopAlbumsResponseTopAlbums(this.albums);

  factory LTopAlbumsResponseTopAlbums.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseTopAlbumsFromJson(json);

  Map<String, dynamic> toJson() => _$LTopAlbumsResponseTopAlbumsToJson(this);
}

@JsonSerializable()
class LAlbumMatch extends BasicAlbum {
  String name;

  @JsonKey(name: 'artist')
  String artistName;

  @JsonKey(name: 'image')
  List<LImage> images;

  BasicArtist get artist => ConcreteBasicArtist(artistName, null);

  LAlbumMatch(this.name, this.artistName, this.images);

  factory LAlbumMatch.fromJson(Map<String, dynamic> json) =>
      _$LAlbumMatchFromJson(json);

  Map<String, dynamic> toJson() => _$LAlbumMatchToJson(this);
}

@JsonSerializable()
class LAlbumSearchResponse {
  @JsonKey(name: 'album')
  List<LAlbumMatch> albums;

  LAlbumSearchResponse(this.albums);

  factory LAlbumSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LAlbumSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LAlbumSearchResponseToJson(this);
}

@JsonSerializable()
class LAlbumTrack extends BasicTrack {
  String name;

  @JsonKey(fromJson: int.parse)
  int duration;

  String album;

  @JsonKey(name: 'artist')
  LTopAlbumsResponseAlbumArtist artistObject;

  String get artist => artistObject.name;

  String get displaySubtitle => null;

  LAlbumTrack(this.name, this.duration, this.artistObject);

  factory LAlbumTrack.fromJson(Map<String, dynamic> json) =>
      _$LAlbumTrackFromJson(json);

  Map<String, dynamic> toJson() => _$LAlbumTrackToJson(this);
}

@JsonSerializable()
class LAlbumTracks {
  @JsonKey(name: 'track')
  List<LAlbumTrack> tracks;

  LAlbumTracks(this.tracks);

  factory LAlbumTracks.fromJson(Map<String, dynamic> json) =>
      _$LAlbumTracksFromJson(json);

  Map<String, dynamic> toJson() => _$LAlbumTracksToJson(this);
}

@JsonSerializable()
class LAlbum extends FullAlbum {
  String name;

  @JsonKey(name: 'artist')
  String artistName;

  @JsonKey(name: 'image')
  List<LImage> images;

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

  BasicArtist get artist => ConcreteBasicArtist(artistName, null);

  List<LAlbumTrack> get tracks => tracksObject.tracks
    ..forEach((element) {
      element.album = name;
    });

  LAlbum(this.name, this.artistName, this.images, this.playCount,
      this.userPlayCount, this.listeners, this.tracksObject, this.topTags);

  factory LAlbum.fromJson(Map<String, dynamic> json) => _$LAlbumFromJson(json);

  Map<String, dynamic> toJson() => _$LAlbumToJson(this);
}
