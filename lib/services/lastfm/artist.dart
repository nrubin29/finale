import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/formatters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class LTopArtistsResponseArtist extends BasicScrobbledArtist with HasPlayCount {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(name: 'playcount', fromJson: parseInt)
  @override
  final int playCount;

  LTopArtistsResponseArtist(this.name, this.url, this.playCount);

  factory LTopArtistsResponseArtist.fromJson(Map<String, dynamic> json) =>
      _$LTopArtistsResponseArtistFromJson(json);
}

@JsonSerializable()
class LTopArtistsResponseTopArtists
    extends LPagedResponse<LTopArtistsResponseArtist> {
  @JsonKey(name: 'artist')
  @override
  final List<LTopArtistsResponseArtist> items;

  const LTopArtistsResponseTopArtists(super.attr, this.items);

  factory LTopArtistsResponseTopArtists.fromJson(Map<String, dynamic> json) =>
      _$LTopArtistsResponseTopArtistsFromJson(json);
}

@JsonSerializable()
class LArtistMatch extends BasicArtist {
  @override
  final String name;

  @override
  final String url;

  LArtistMatch(this.name, this.url);

  factory LArtistMatch.fromJson(Map<String, dynamic> json) =>
      _$LArtistMatchFromJson(json);
}

@JsonSerializable()
class LArtistSearchResponse {
  @JsonKey(name: 'artist')
  final List<LArtistMatch> artists;

  const LArtistSearchResponse(this.artists);

  factory LArtistSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistSearchResponseFromJson(json);
}

@JsonSerializable()
class LSimilarArtist extends BasicArtist {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(name: 'match', fromJson: double.parse)
  final double similarity;

  LSimilarArtist(this.name, {required this.url, required this.similarity});

  factory LSimilarArtist.fromJson(Map<String, dynamic> json) =>
      _$LSimilarArtistFromJson(json);
}

@JsonSerializable()
class LSimilarArtistsResponse {
  @JsonKey(name: 'artist')
  final List<LSimilarArtist> artists;

  const LSimilarArtistsResponse(this.artists);

  factory LSimilarArtistsResponse.fromJson(Map<String, dynamic> json) =>
      _$LSimilarArtistsResponseFromJson(json);
}

@JsonSerializable()
class LArtistStats {
  @JsonKey(name: 'playcount', fromJson: parseInt)
  final int playCount;

  @JsonKey(fromJson: parseInt)
  final int listeners;

  @JsonKey(name: 'userplaycount', fromJson: parseInt)
  final int userPlayCount;

  const LArtistStats(this.playCount, this.userPlayCount, this.listeners);

  factory LArtistStats.fromJson(Map<String, dynamic> json) =>
      _$LArtistStatsFromJson(json);
}

@JsonSerializable()
class LArtist extends FullArtist {
  @override
  final String name;

  @override
  final String url;

  final LArtistStats stats;

  @JsonKey(name: 'tags', fromJson: LTopTags.fromJsonSafe)
  final LTopTags topTags;

  final LWiki? bio;

  @override
  String get displayTrailing => pluralize(stats.userPlayCount);

  LArtist(this.name, this.url, this.stats, this.topTags, this.bio);

  factory LArtist.fromJson(Map<String, dynamic> json) =>
      _$LArtistFromJson(json);
}

@JsonSerializable()
class LArtistTopAlbum extends BasicAlbum {
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

  LArtistTopAlbum(
      this.name, this.url, this.playCount, this.artist, this.imageId);

  factory LArtistTopAlbum.fromJson(Map<String, dynamic> json) =>
      _$LArtistTopAlbumFromJson(json);
}

@JsonSerializable()
class LArtistGetTopAlbumsResponse {
  @JsonKey(name: 'album')
  final List<LArtistTopAlbum> albums;

  const LArtistGetTopAlbumsResponse(this.albums);

  factory LArtistGetTopAlbumsResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistGetTopAlbumsResponseFromJson(json);
}

@JsonSerializable()
class LArtistTopTrack extends Track {
  @override
  final String name;

  @override
  final String url;

  final LTopAlbumsResponseAlbumArtist artist;

  @override
  String get artistName => artist.name;

  @override
  String? get albumName => null;

  @override
  ImageIdProvider get imageIdProvider =>
      () async => (await Lastfm.getTrack(this)).imageId;

  LArtistTopTrack(this.name, this.url, this.artist);

  factory LArtistTopTrack.fromJson(Map<String, dynamic> json) =>
      _$LArtistTopTrackFromJson(json);
}

@JsonSerializable()
class LArtistGetTopTracksResponse {
  @JsonKey(name: 'track')
  final List<LArtistTopTrack> tracks;

  const LArtistGetTopTracksResponse(this.tracks);

  factory LArtistGetTopTracksResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistGetTopTracksResponseFromJson(json);
}

@JsonSerializable()
class LChartTopArtists {
  @JsonKey(name: 'artist')
  final List<LTopArtistsResponseArtist> artists;

  const LChartTopArtists(this.artists);

  factory LChartTopArtists.fromJson(Map<String, dynamic> json) =>
      _$LChartTopArtistsFromJson(json);
}
