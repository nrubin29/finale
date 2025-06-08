import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/formatters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

@JsonSerializable()
class LRecentTracksResponseTrackArtist extends BasicArtist {
  // extended = false
  @JsonKey(name: '#text')
  final String? text;

  // extended = true
  @JsonKey(name: 'name')
  final String? nameString;

  // extended = true
  @JsonKey(name: 'url')
  @override
  final String? url;

  @override
  String get name => text ?? nameString!;

  LRecentTracksResponseTrackArtist(this.text, this.nameString, this.url);

  factory LRecentTracksResponseTrackArtist.fromJson(
    Map<String, dynamic> json,
  ) => _$LRecentTracksResponseTrackArtistFromJson(json);
}

@JsonSerializable()
class LRecentTracksResponseTrackAlbum extends BasicAlbum {
  @JsonKey(name: '#text')
  @override
  final String name;

  // Set by LRecentTracksResponseTrack.
  @JsonKey(includeFromJson: false)
  @override
  late LRecentTracksResponseTrackArtist artist;

  LRecentTracksResponseTrackAlbum(this.name);

  factory LRecentTracksResponseTrackAlbum.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackAlbumFromJson(json);

  @override
  String? get url => null;
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

  @JsonKey(name: 'loved', fromJson: convertStringToBoolean)
  final bool isLoved;

  LRecentTracksResponseTrack(
    this.name,
    this.url,
    this.imageId,
    this.artist,
    this.album,
    this.timestamp,
    this.isLoved,
  ) {
    album.artist = artist;
  }

  @override
  String get artistName => artist.name;

  @override
  String get albumName => album.name;

  @override
  DateTime? get date => timestamp?.date;

  @override
  String? get displayTrailing =>
      timestamp == null ? null : super.displayTrailing;

  factory LRecentTracksResponseTrack.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackFromJson(json);

  @override
  String toString() =>
      'LRecentTracksResponseTrack(name=$name, artist=$artistName, '
      'album=$albumName)';

  LRecentTracksResponseTrack copyWith({bool? isLoved}) =>
      LRecentTracksResponseTrack(
        name,
        url,
        imageId,
        artist,
        album,
        timestamp,
        isLoved ?? this.isLoved,
      );
}

@JsonSerializable()
class LRecentTracksResponseRecentTracks {
  @JsonKey(name: '@attr')
  final LAttr attr;

  @JsonKey(name: 'track', fromJson: parseTracks)
  final List<LRecentTracksResponseTrack> tracks;

  const LRecentTracksResponseRecentTracks(this.attr, this.tracks);

  factory LRecentTracksResponseRecentTracks.fromJson(
    Map<String, dynamic> json,
  ) => _$LRecentTracksResponseRecentTracksFromJson(json);

  // If there's only one track, the Last.fm API in its infinite wisdom doesn't
  // wrap it in an array.
  static List<LRecentTracksResponseTrack> parseTracks(json) =>
      json == null
          ? []
          : json is List<dynamic>
          ? json
              .map((json) => LRecentTracksResponseTrack.fromJson(json))
              .toList()
          : [LRecentTracksResponseTrack.fromJson(json)];
}

@JsonSerializable()
class LTrackMatch extends Track {
  @override
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
  ImageIdProvider get imageIdProvider =>
      () async => (await Lastfm.getTrack(this)).imageId;

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
class LTrack extends Track with HasPlayCount {
  @override
  final String name;

  @override
  final String url;

  /// Track duration in milliseconds, or 0 if not provided.
  @JsonKey(fromJson: parseInt)
  final int duration;

  @JsonKey(fromJson: parseInt)
  final int listeners;

  @JsonKey(name: 'playcount', fromJson: parseInt)
  final int globalPlayCount;

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
  ImageId? get imageId => album?.imageId;

  @override
  String? get artistName => artist?.name;

  @override
  String? get albumName => album?.name;

  @override
  String get displayTrailing => pluralize(userPlayCount);

  @Deprecated("Don't use directly; use [userPlayCount] instead.")
  @override
  int get playCount => userPlayCount;
  LTrack(
    this.name,
    this.url,
    this.duration,
    this.listeners,
    this.globalPlayCount,
    this.userPlayCount,
    this.userLoved,
    this.artist,
    this.album,
    this.topTags,
    this.wiki,
  );

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
  ImageIdProvider get imageIdProvider =>
      () async => (await Lastfm.getTrack(this)).imageId;

  @override
  String get displayTrailing => pluralize(playCount);

  LTopTracksResponseTrack(this.name, this.url, this.artist, this.playCount);

  factory LTopTracksResponseTrack.fromJson(Map<String, dynamic> json) =>
      _$LTopTracksResponseTrackFromJson(json);
}

@JsonSerializable()
class LTopTracksResponseTopTracks
    extends LPagedResponse<LTopTracksResponseTrack> {
  @JsonKey(name: 'track')
  @override
  final List<LTopTracksResponseTrack> items;

  const LTopTracksResponseTopTracks(super.attr, this.items);

  factory LTopTracksResponseTopTracks.fromJson(Map<String, dynamic> json) =>
      _$LTopTracksResponseTopTracksFromJson(json);
}
