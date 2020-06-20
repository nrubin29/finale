import 'package:finale/lastfm.dart';
import 'package:finale/types/generic.dart';
import 'package:finale/types/lalbum.dart';
import 'package:finale/types/lcommon.dart';
import 'package:json_annotation/json_annotation.dart';

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
}

@JsonSerializable()
class LTopArtistsResponseTopArtists {
  @JsonKey(name: 'artist')
  List<LTopArtistsResponseArtist> artists;

  @JsonKey(name: '@attr')
  LAttr attr;

  LTopArtistsResponseTopArtists(this.artists, this.attr);

  factory LTopArtistsResponseTopArtists.fromJson(Map<String, dynamic> json) =>
      _$LTopArtistsResponseTopArtistsFromJson(json);
}

@JsonSerializable()
class LArtistMatch extends BasicArtist {
  String name;
  String url;

  LArtistMatch(this.name, this.url);

  factory LArtistMatch.fromJson(Map<String, dynamic> json) =>
      _$LArtistMatchFromJson(json);
}

@JsonSerializable()
class LArtistSearchResponse {
  @JsonKey(name: 'artist')
  List<LArtistMatch> artists;

  LArtistSearchResponse(this.artists);

  factory LArtistSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistSearchResponseFromJson(json);
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
}

@JsonSerializable()
class LArtist extends FullArtist {
  String name;
  String url;

  LArtistStats stats;

  @JsonKey(name: 'tags')
  LTopTags topTags;

  LWiki bio;

  LArtist(this.name, this.url, this.stats, this.topTags, this.bio);

  factory LArtist.fromJson(Map<String, dynamic> json) =>
      _$LArtistFromJson(json);
}

@JsonSerializable()
class LArtistTopAlbum extends BasicAlbum {
  String name;
  String url;

  @JsonKey(name: 'playcount')
  int playCount;

  LTopAlbumsResponseAlbumArtist artist;

  @JsonKey(name: 'image', fromJson: extractImageId)
  String imageId;

  LArtistTopAlbum(
      this.name, this.url, this.playCount, this.artist, this.imageId);

  factory LArtistTopAlbum.fromJson(Map<String, dynamic> json) =>
      _$LArtistTopAlbumFromJson(json);
}

@JsonSerializable()
class LArtistGetTopAlbumsResponse {
  @JsonKey(name: 'album')
  List<LArtistTopAlbum> albums;

  LArtistGetTopAlbumsResponse(this.albums);

  factory LArtistGetTopAlbumsResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistGetTopAlbumsResponseFromJson(json);
}

@JsonSerializable()
class LArtistTopTrack extends BasicTrack {
  String name;
  String url;

  @JsonKey(name: 'artist')
  LTopAlbumsResponseAlbumArtist artistObject;

  String get artist => artistObject.name;

  String get album => null;

  Future<String> get imageId async {
    final fullTrack = await Lastfm.getTrack(this);
    return fullTrack.album?.imageId;
  }

  LArtistTopTrack(this.name, this.url, this.artistObject);

  factory LArtistTopTrack.fromJson(Map<String, dynamic> json) =>
      _$LArtistTopTrackFromJson(json);
}

@JsonSerializable()
class LArtistGetTopTracksResponse {
  @JsonKey(name: 'track')
  List<LArtistTopTrack> tracks;

  LArtistGetTopTracksResponse(this.tracks);

  factory LArtistGetTopTracksResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistGetTopTracksResponseFromJson(json);
}

@JsonSerializable()
class LChartTopArtists {
  @JsonKey(name: 'artist')
  List<LTopArtistsResponseArtist> artists;

  LChartTopArtists(this.artists);

  factory LChartTopArtists.fromJson(Map<String, dynamic> json) =>
      _$LChartTopArtistsFromJson(json);
}
