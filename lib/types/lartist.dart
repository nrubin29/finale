import 'package:json_annotation/json_annotation.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lalbum.dart';
import 'package:simplescrobble/types/lcommon.dart';

part 'lartist.g.dart';

@JsonSerializable()
class LTopArtistsResponseArtist extends BasicScrobbledArtist {
  String name;
  String url;

  @JsonKey(name: 'playcount', fromJson: int.parse)
  int playCount;

  LTopArtistsResponseArtist(this.name, this.url, this.playCount);

  factory LTopArtistsResponseArtist.fromJson(Map<String, dynamic> json) =>
      _$LTopArtistsResponseArtistFromJson(json);

  Map<String, dynamic> toJson() => _$LTopArtistsResponseArtistToJson(this);
}

@JsonSerializable()
class LTopArtistsResponseTopArtists {
  @JsonKey(name: 'artist')
  List<LTopArtistsResponseArtist> artists;

  LTopArtistsResponseTopArtists(this.artists);

  factory LTopArtistsResponseTopArtists.fromJson(Map<String, dynamic> json) =>
      _$LTopArtistsResponseTopArtistsFromJson(json);

  Map<String, dynamic> toJson() => _$LTopArtistsResponseTopArtistsToJson(this);
}

@JsonSerializable()
class LArtistMatch extends BasicArtist {
  String name;
  String url;

  LArtistMatch(this.name, this.url);

  factory LArtistMatch.fromJson(Map<String, dynamic> json) =>
      _$LArtistMatchFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistMatchToJson(this);
}

@JsonSerializable()
class LArtistSearchResponse {
  @JsonKey(name: 'artist')
  List<LArtistMatch> artists;

  LArtistSearchResponse(this.artists);

  factory LArtistSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistSearchResponseToJson(this);
}

@JsonSerializable()
class LArtistStats {
  @JsonKey(name: 'playcount', fromJson: int.parse)
  int playCount;

  @JsonKey(fromJson: int.parse)
  int listeners;

  @JsonKey(name: 'userplaycount', fromJson: int.parse)
  int userPlayCount;

  LArtistStats(this.playCount, this.userPlayCount, this.listeners);

  factory LArtistStats.fromJson(Map<String, dynamic> json) =>
      _$LArtistStatsFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistStatsToJson(this);
}

@JsonSerializable()
class LArtist extends FullArtist {
  String name;
  String url;

  LArtistStats stats;

  @JsonKey(name: 'tags')
  LTopTags topTags;

  LArtist(this.name, this.url, this.stats, this.topTags);

  factory LArtist.fromJson(Map<String, dynamic> json) =>
      _$LArtistFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistToJson(this);
}

@JsonSerializable()
class LArtistTopAlbum extends BasicAlbum {
  String name;

  @JsonKey(name: 'playcount')
  int playCount;

  LTopAlbumsResponseAlbumArtist artist;

  @JsonKey(name: 'image')
  List<LImage> images;

  LArtistTopAlbum(this.name, this.playCount, this.artist, this.images);

  factory LArtistTopAlbum.fromJson(Map<String, dynamic> json) =>
      _$LArtistTopAlbumFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistTopAlbumToJson(this);
}

@JsonSerializable()
class LArtistGetTopAlbumsResponse {
  @JsonKey(name: 'album')
  List<LArtistTopAlbum> albums;

  LArtistGetTopAlbumsResponse(this.albums);

  factory LArtistGetTopAlbumsResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistGetTopAlbumsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistGetTopAlbumsResponseToJson(this);
}

@JsonSerializable()
class LArtistTopTrack extends BasicTrack {
  String name;

  @JsonKey(name: 'artist')
  LTopAlbumsResponseAlbumArtist artistObject;

  String get artist => artistObject.name;

  String get album => null;

  Future<List<LImage>> get images async {
    final fullTrack = await Lastfm.getTrack(this);
    return fullTrack.album.images;
  }

  LArtistTopTrack(this.name, this.artistObject);

  factory LArtistTopTrack.fromJson(Map<String, dynamic> json) =>
      _$LArtistTopTrackFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistTopTrackToJson(this);
}

@JsonSerializable()
class LArtistGetTopTracksResponse {
  @JsonKey(name: 'track')
  List<LArtistTopTrack> tracks;

  LArtistGetTopTracksResponse(this.tracks);

  factory LArtistGetTopTracksResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistGetTopTracksResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistGetTopTracksResponseToJson(this);
}
