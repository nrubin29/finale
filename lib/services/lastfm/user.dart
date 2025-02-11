import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/extensions.dart';
import 'package:finale/util/formatters.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class LUserRegistered {
  @JsonKey(name: 'unixtime', fromJson: fromSecondsSinceEpoch)
  final DateTime date;

  const LUserRegistered(this.date);

  String get dateFormatted => dateFormatWithYear.format(date);

  factory LUserRegistered.fromJson(Map<String, dynamic> json) =>
      _$LUserRegisteredFromJson(json);
}

@JsonSerializable()
class LUser extends Entity {
  final String name;

  @JsonKey(name: 'realname')
  final String? realName;

  @override
  final String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  final ImageId? imageId;

  @JsonKey(name: 'playcount', fromJson: parseInt)
  final int playCount;

  final LUserRegistered registered;

  LUser(this.name, this.realName, this.url, this.imageId, this.playCount,
      this.registered);

  @override
  EntityType get type => EntityType.user;

  @override
  String get displayTitle => name;

  @override
  String? get displaySubtitle => realName;

  factory LUser.fromJson(Map<String, dynamic> json) => _$LUserFromJson(json);

  @override
  bool operator ==(Object other) => other is LUser && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

@JsonSerializable()
class LUserFriendsResponse {
  @JsonKey(name: 'user')
  final List<LUser> friends;

  const LUserFriendsResponse(this.friends);

  factory LUserFriendsResponse.fromJson(Map<String, dynamic> json) =>
      _$LUserFriendsResponseFromJson(json);
}

@JsonSerializable()
class LAuthenticationResponseSession {
  final String name;
  final String key;

  const LAuthenticationResponseSession(this.name, this.key);

  factory LAuthenticationResponseSession.fromJson(Map<String, dynamic> json) =>
      _$LAuthenticationResponseSessionFromJson(json);
}

@JsonSerializable()
class LUserWeeklyChart {
  final String from;
  final String to;

  const LUserWeeklyChart(this.from, this.to);

  factory LUserWeeklyChart.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyChartFromJson(json);

  // We have to add a day to get the proper from date.
  DateTime get fromDate =>
      fromSecondsSinceEpoch(from).add(const Duration(days: 1)).beginningOfDay;

  DateTime get toDate => fromSecondsSinceEpoch(to).endOfDay;

  String get title =>
      '${dateFormat.format(fromDate)} - ${dateFormatWithYear.format(toDate)}';

  @override
  bool operator ==(Object other) =>
      other is LUserWeeklyChart && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

@JsonSerializable()
class LUserWeeklyChartList {
  @JsonKey(name: 'chart')
  final List<LUserWeeklyChart> charts;

  const LUserWeeklyChartList(this.charts);

  factory LUserWeeklyChartList.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyChartListFromJson(json);
}

@JsonSerializable()
class LUserWeeklyTrackChartTrackArtist {
  @JsonKey(name: '#text')
  final String name;

  const LUserWeeklyTrackChartTrackArtist(this.name);

  factory LUserWeeklyTrackChartTrackArtist.fromJson(
          Map<String, dynamic> json) =>
      _$LUserWeeklyTrackChartTrackArtistFromJson(json);
}

@JsonSerializable()
class LUserWeeklyTrackChartTrack extends Track {
  final LUserWeeklyTrackChartTrackArtist artist;

  @override
  final String url;

  @override
  final String name;

  @JsonKey(name: 'playcount', fromJson: intParseSafe)
  final int? playCount;

  LUserWeeklyTrackChartTrack(this.artist, this.url, this.name, this.playCount);

  factory LUserWeeklyTrackChartTrack.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyTrackChartTrackFromJson(json);

  @override
  String? get albumName => null;

  @override
  String get artistName => artist.name;

  @override
  String get displayTrailing => pluralize(playCount ?? 0);

  @override
  ImageIdProvider get imageIdProvider =>
      () async => (await Lastfm.getTrack(this)).imageId;
}

@JsonSerializable()
class LUserWeeklyTrackChart {
  @JsonKey(name: 'track')
  final List<LUserWeeklyTrackChartTrack> tracks;

  const LUserWeeklyTrackChart(this.tracks);

  factory LUserWeeklyTrackChart.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyTrackChartFromJson(json);
}

@JsonSerializable()
class LUserWeeklyAlbumChartAlbumArtist extends BasicArtist {
  @JsonKey(name: '#text')
  @override
  final String name;

  LUserWeeklyAlbumChartAlbumArtist(this.name);

  factory LUserWeeklyAlbumChartAlbumArtist.fromJson(
          Map<String, dynamic> json) =>
      _$LUserWeeklyAlbumChartAlbumArtistFromJson(json);

  @override
  String? get url => null;
}

@JsonSerializable()
class LUserWeeklyAlbumChartAlbum extends BasicAlbum {
  @override
  final LUserWeeklyAlbumChartAlbumArtist artist;

  @override
  final String url;

  @override
  final String name;

  @JsonKey(name: 'playcount', fromJson: intParseSafe)
  final int? playCount;

  LUserWeeklyAlbumChartAlbum(this.artist, this.url, this.name, this.playCount);

  factory LUserWeeklyAlbumChartAlbum.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyAlbumChartAlbumFromJson(json);

  @override
  String get displayTrailing => Intl.plural(playCount ?? 0,
      one: '$playCount scrobble', other: '$playCount scrobbles');

  @override
  ImageIdProvider get imageIdProvider =>
      () async => (await Lastfm.getAlbum(this)).imageId;
}

@JsonSerializable()
class LUserWeeklyAlbumChart {
  @JsonKey(name: 'album')
  final List<LUserWeeklyAlbumChartAlbum> albums;

  const LUserWeeklyAlbumChart(this.albums);

  factory LUserWeeklyAlbumChart.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyAlbumChartFromJson(json);
}

@JsonSerializable()
class LUserWeeklyArtistChartArtist extends BasicArtist {
  @override
  final String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  ImageIdProvider get imageIdProvider =>
      () async => await (await Lastfm.getArtist(this)).imageIdProvider();

  @override
  final String name;

  @JsonKey(name: 'playcount', fromJson: intParseSafe)
  final int? playCount;

  LUserWeeklyArtistChartArtist(this.url, this.name, this.playCount);

  factory LUserWeeklyArtistChartArtist.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyArtistChartArtistFromJson(json);

  @override
  String get displayTrailing => Intl.plural(playCount ?? 0,
      one: '$playCount scrobble', other: '$playCount scrobbles');
}

@JsonSerializable()
class LUserWeeklyArtistChart {
  @JsonKey(name: 'artist')
  final List<LUserWeeklyArtistChartArtist> artists;

  const LUserWeeklyArtistChart(this.artists);

  factory LUserWeeklyArtistChart.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyArtistChartFromJson(json);
}

@JsonSerializable()
class LUserTrackScrobblesResponse {
  @JsonKey(name: 'track')
  final List<LUserTrackScrobble> tracks;

  const LUserTrackScrobblesResponse(this.tracks);

  factory LUserTrackScrobblesResponse.fromJson(Map<String, dynamic> json) =>
      _$LUserTrackScrobblesResponseFromJson(json);
}

@JsonSerializable()
class LUserTrackScrobble extends BasicScrobbledTrack {
  @override
  String name;

  @JsonKey(fromJson: extractDateTimeFromObject)
  @override
  DateTime date;

  @override
  String url;

  LUserWeeklyTrackChartTrackArtist artist;
  LUserTrackScrobbleAlbum album;

  LUserTrackScrobble(this.name, this.date, this.url, this.artist, this.album);

  factory LUserTrackScrobble.fromJson(Map<String, dynamic> json) =>
      _$LUserTrackScrobbleFromJson(json);

  @override
  String? get albumName => album.name;

  @override
  String? get artistName => artist.name;

  @override
  String get displayTrailing => formatDateTimeDelta(date, withYear: true);

  static DateTime extractDateTimeFromObject(Map<String, dynamic> object) =>
      fromSecondsSinceEpoch(object['uts']);
}

@JsonSerializable()
class LUserTrackScrobbleAlbum {
  @JsonKey(name: '#text')
  final String name;

  const LUserTrackScrobbleAlbum(this.name);

  factory LUserTrackScrobbleAlbum.fromJson(Map<String, dynamic> json) =>
      _$LUserTrackScrobbleAlbumFromJson(json);
}

@JsonSerializable()
class LUserLovedTracksResponse {
  @JsonKey(name: 'track')
  final List<LUserLovedTrack> tracks;

  const LUserLovedTracksResponse(this.tracks);

  factory LUserLovedTracksResponse.fromJson(Map<String, dynamic> json) =>
      _$LUserLovedTracksResponseFromJson(json);
}

@JsonSerializable()
class LUserLovedTrackArtist {
  final String name;

  const LUserLovedTrackArtist(this.name);

  factory LUserLovedTrackArtist.fromJson(Map<String, dynamic> json) =>
      _$LUserLovedTrackArtistFromJson(json);
}

@JsonSerializable()
class LUserLovedTrackDate {
  @JsonKey(name: 'uts', fromJson: fromSecondsSinceEpoch)
  final DateTime date;

  const LUserLovedTrackDate(this.date);

  factory LUserLovedTrackDate.fromJson(Map<String, dynamic> json) =>
      _$LUserLovedTrackDateFromJson(json);
}

@JsonSerializable()
class LUserLovedTrack extends Track {
  @override
  final String name;

  @override
  final String url;

  final LUserLovedTrackArtist artist;

  @JsonKey(name: 'date')
  final LUserLovedTrackDate timestamp;

  LUserLovedTrack(this.name, this.url, this.artist, this.timestamp);

  factory LUserLovedTrack.fromJson(Map<String, dynamic> json) =>
      _$LUserLovedTrackFromJson(json);

  @override
  String? get albumName => null;

  @override
  String get artistName => artist.name;

  @override
  String? get displayTrailing => dateFormatWithYear.format(timestamp.date);

  @override
  ImageIdProvider get imageIdProvider =>
      () async => (await Lastfm.getTrack(this)).imageId;
}
