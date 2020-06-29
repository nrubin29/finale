import 'package:finale/lastfm.dart';
import 'package:finale/types/generic.dart';
import 'package:finale/types/lcommon.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ltrack.g.dart';

@JsonSerializable()
class LRecentTracksResponseTrackArtist {
  @JsonKey(name: '#text')
  String name;

  LRecentTracksResponseTrackArtist(this.name);

  factory LRecentTracksResponseTrackArtist.fromJson(
          Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackArtistFromJson(json);
}

@JsonSerializable()
class LRecentTracksResponseTrackAlbum {
  @JsonKey(name: '#text')
  String title;

  LRecentTracksResponseTrackAlbum(this.title);

  factory LRecentTracksResponseTrackAlbum.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackAlbumFromJson(json);
}

@JsonSerializable()
class LRecentTracksResponseTrackDate {
  @JsonKey(name: 'uts', fromJson: fromSecondsSinceEpoch)
  DateTime date;

  LRecentTracksResponseTrackDate(this.date);

  factory LRecentTracksResponseTrackDate.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackDateFromJson(json);
}

@JsonSerializable()
class LRecentTracksResponseTrack extends BasicScrobbledTrack {
  String name;
  String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  String imageId;

  @JsonKey(name: 'artist')
  LRecentTracksResponseTrackArtist artistObject;

  @JsonKey(name: 'album')
  LRecentTracksResponseTrackAlbum albumObject;

  @JsonKey(name: 'date')
  LRecentTracksResponseTrackDate timestamp;

  LRecentTracksResponseTrack(this.name, this.url, this.imageId,
      this.artistObject, this.albumObject, this.timestamp);

  String get artist => artistObject.name;

  String get album => albumObject.title;

  DateTime get date => timestamp?.date ?? null;

  factory LRecentTracksResponseTrack.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackFromJson(json);
}

@JsonSerializable()
class LRecentTracksResponseRecentTracks {
  @JsonKey(name: 'track')
  List<LRecentTracksResponseTrack> tracks;

  LRecentTracksResponseRecentTracks(this.tracks);

  factory LRecentTracksResponseRecentTracks.fromJson(
          Map<String, dynamic> json) =>
      _$LRecentTracksResponseRecentTracksFromJson(json);
}

@JsonSerializable()
class LTrackMatch extends BasicTrack {
  String name;
  String url;
  String artist;

  // LTrackMatches don't give us any indication of the their album, so we need
  // to fetch the full track in order to get the album.
  String get album => null;

  Future<String> get imageIdFuture async {
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
  List<LTrackMatch> tracks;

  LTrackSearchResponse(this.tracks);

  factory LTrackSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LTrackSearchResponseFromJson(json);
}

@JsonSerializable()
class LTrackArtist extends BasicArtist {
  String name;
  String url;

  LTrackArtist(this.name, this.url);

  factory LTrackArtist.fromJson(Map<String, dynamic> json) =>
      _$LTrackArtistFromJson(json);
}

@JsonSerializable()
class LTrackAlbum extends BasicAlbum {
  @JsonKey(name: 'title')
  String name;

  String url;

  @JsonKey(name: 'artist')
  String artistName;

  @JsonKey(name: 'image', fromJson: extractImageId)
  String imageId;

  BasicArtist get artist => ConcreteBasicArtist(artistName, null);

  LTrackAlbum(this.name, this.url, this.artistName, this.imageId);

  factory LTrackAlbum.fromJson(Map<String, dynamic> json) =>
      _$LTrackAlbumFromJson(json);
}

@JsonSerializable()
class LTrack extends FullTrack {
  String name;
  String url;

  @JsonKey(fromJson: int.parse)
  int listeners;

  @JsonKey(fromJson: int.parse)
  int duration;

  @JsonKey(name: 'playcount', fromJson: int.parse)
  int playCount;

  @JsonKey(name: 'userplaycount', fromJson: int.parse)
  int userPlayCount;

  @JsonKey(name: 'userloved', fromJson: convertStringToBoolean)
  bool userLoved;

  LTrackArtist artist;
  LTrackAlbum album;

  @JsonKey(name: 'toptags')
  LTopTags topTags;

  LWiki wiki;

  LTrack(this.name, this.url, this.listeners, this.duration, this.playCount,
      this.artist, this.album, this.topTags, this.wiki);

  factory LTrack.fromJson(Map<String, dynamic> json) => _$LTrackFromJson(json);
}

@JsonSerializable()
class LTopTracksResponseTrack extends BasicTrack {
  String name;
  String url;

  @JsonKey(name: 'artist')
  LRecentTracksResponseTrack artistObject;

  @JsonKey(name: 'playcount', fromJson: int.parse)
  int playCount;

  String get artist => artistObject.name;

  String get album => null;

  Future<String> get imageIdFuture async {
    final fullTrack = await Lastfm.getTrack(this);
    return fullTrack.album?.imageId;
  }

  @override
  String get displayTrailing => '$playCount scrobbles';

  LTopTracksResponseTrack(
      this.name, this.url, this.artistObject, this.playCount);

  factory LTopTracksResponseTrack.fromJson(Map<String, dynamic> json) =>
      _$LTopTracksResponseTrackFromJson(json);
}

@JsonSerializable()
class LTopTracksResponseTopTracks {
  @JsonKey(name: 'track')
  List<LTopTracksResponseTrack> tracks;

  @JsonKey(name: '@attr')
  LAttr attr;

  LTopTracksResponseTopTracks(this.tracks, this.attr);

  factory LTopTracksResponseTopTracks.fromJson(Map<String, dynamic> json) =>
      _$LTopTracksResponseTopTracksFromJson(json);
}
