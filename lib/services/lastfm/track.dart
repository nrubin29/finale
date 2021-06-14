import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

@JsonSerializable()
class LRecentTracksResponseTrackArtist {
  @JsonKey(name: '#text')
  final String name;

  const LRecentTracksResponseTrackArtist(this.name);

  factory LRecentTracksResponseTrackArtist.fromJson(
          Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackArtistFromJson(json);
}

@JsonSerializable()
class LRecentTracksResponseTrackAlbum {
  @JsonKey(name: '#text')
  final String title;

  const LRecentTracksResponseTrackAlbum(this.title);

  factory LRecentTracksResponseTrackAlbum.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackAlbumFromJson(json);
}

@JsonSerializable()
class LRecentTracksResponseTrackDate {
  @JsonKey(name: 'uts', fromJson: fromSecondsSinceEpoch)
  final DateTime date;

  const LRecentTracksResponseTrackDate(this.date);

  factory LRecentTracksResponseTrackDate.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackDateFromJson(json);
}

@JsonSerializable()
class LRecentTracksResponseTrack extends BasicScrobbledTrack {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  final ImageId? imageId;

  final LRecentTracksResponseTrackArtist artist;

  final LRecentTracksResponseTrackAlbum album;

  @JsonKey(name: 'date')
  final LRecentTracksResponseTrackDate? timestamp;

  LRecentTracksResponseTrack(this.name, this.url, this.imageId, this.artist,
      this.album, this.timestamp);

  @override
  String get artistName => artist.name;

  @override
  String get albumName => album.title;

  @override
  DateTime? get date => timestamp?.date;

  factory LRecentTracksResponseTrack.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackFromJson(json);

  @override
  String toString() =>
      'LRecentTracksResponseTrack(name=$name, artist=$artistName, '
      'album=$albumName)';
}

@JsonSerializable()
class LRecentTracksResponseRecentTracks {
  @JsonKey(name: 'track')
  final List<LRecentTracksResponseTrack> tracks;

  const LRecentTracksResponseRecentTracks(this.tracks);

  factory LRecentTracksResponseRecentTracks.fromJson(
          Map<String, dynamic> json) =>
      _$LRecentTracksResponseRecentTracksFromJson(json);
}

@JsonSerializable()
class LTrackMatch extends Track {
  final String name;

  @override
  final String url;

  final String artist;

  // LTrackMatches don't give us any indication of the their album, so we need
  // to fetch the full track in order to get the album.
  @override
  String? get albumName => null;

  @override
  String get artistName => artist;

  @override
  Future<ImageId?> get imageId async {
    final fullTrack = await Lastfm.getTrack(this);
    return fullTrack.album?.imageId;
  }

  LTrackMatch(this.name, this.url, this.artist);

  factory LTrackMatch.fromJson(Map<String, dynamic> json) =>
      _$LTrackMatchFromJson(json);
}

@JsonSerializable()
class LTrackSearchResponse {
  @JsonKey(name: 'track')
  final List<LTrackMatch> tracks;

  const LTrackSearchResponse(this.tracks);

  factory LTrackSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LTrackSearchResponseFromJson(json);
}

@JsonSerializable()
class LTrackArtist extends BasicArtist {
  @override
  final String name;

  @override
  final String url;

  LTrackArtist(this.name, this.url);

  factory LTrackArtist.fromJson(Map<String, dynamic> json) =>
      _$LTrackArtistFromJson(json);
}

@JsonSerializable()
class LTrackAlbum extends BasicAlbum {
  @JsonKey(name: 'title')
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
  BasicArtist get artist => ConcreteBasicArtist(artistName);

  LTrackAlbum(this.name, this.url, this.artistName, this.imageId);

  factory LTrackAlbum.fromJson(Map<String, dynamic> json) =>
      _$LTrackAlbumFromJson(json);
}

@JsonSerializable()
class LTrack extends Track {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(fromJson: parseInt)
  final int listeners;

  @JsonKey(name: 'playcount', fromJson: parseInt)
  final int playCount;

  @JsonKey(name: 'userplaycount', fromJson: parseInt)
  final int userPlayCount;

  @JsonKey(name: 'userloved', fromJson: convertStringToBoolean)
  final bool userLoved;

  final LTrackArtist? artist;
  final LTrackAlbum? album;

  @JsonKey(name: 'toptags', fromJson: LTopTags.fromJsonSafe)
  final LTopTags topTags;

  final LWiki? wiki;

  @override
  String? get artistName => artist?.name;

  @override
  String? get albumName => album?.name;

  LTrack(
      this.name,
      this.url,
      this.listeners,
      this.playCount,
      this.userPlayCount,
      this.userLoved,
      this.artist,
      this.album,
      this.topTags,
      this.wiki);

  factory LTrack.fromJson(Map<String, dynamic> json) => _$LTrackFromJson(json);
}

@JsonSerializable()
class LTopTracksResponseTrack extends Track with HasPlayCount {
  @override
  final String name;

  @override
  final String url;

  final LTrackArtist artist;

  @JsonKey(name: 'playcount', fromJson: parseInt)
  @override
  final int playCount;

  @override
  String get artistName => artist.name;

  @override
  String? get albumName => null;

  @override
  Future<ImageId?> get imageId async {
    final fullTrack = await Lastfm.getTrack(this);
    return fullTrack.album?.imageId;
  }

  @override
  String get displayTrailing => formatScrobbles(playCount);

  LTopTracksResponseTrack(this.name, this.url, this.artist, this.playCount);

  factory LTopTracksResponseTrack.fromJson(Map<String, dynamic> json) =>
      _$LTopTracksResponseTrackFromJson(json);
}

@JsonSerializable()
class LTopTracksResponseTopTracks {
  @JsonKey(name: 'track')
  final List<LTopTracksResponseTrack> tracks;

  @JsonKey(name: '@attr')
  final LAttr attr;

  const LTopTracksResponseTopTracks(this.tracks, this.attr);

  factory LTopTracksResponseTopTracks.fromJson(Map<String, dynamic> json) =>
      _$LTopTracksResponseTopTracksFromJson(json);
}
