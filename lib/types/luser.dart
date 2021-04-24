import 'package:finale/lastfm.dart';
import 'package:finale/types/generic.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'luser.g.dart';

@JsonSerializable()
class LUserRegistered {
  @JsonKey(name: 'unixtime', fromJson: fromSecondsSinceEpoch)
  DateTime date;

  LUserRegistered(this.date);

  String get dateFormatted => DateFormat('dd MMM yyyy').format(date);

  factory LUserRegistered.fromJson(Map<String, dynamic> json) =>
      _$LUserRegisteredFromJson(json);
}

@JsonSerializable()
class LUser extends Displayable {
  String name;

  @JsonKey(name: 'realname')
  String realName;

  String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  String imageId;

  String country;

  @JsonKey(fromJson: intParseSafe)
  int age;

  String gender;

  @JsonKey(fromJson: convertStringToBoolean)
  bool subscriber;

  @JsonKey(name: 'playcount', fromJson: int.parse)
  int playCount;

  @JsonKey(fromJson: int.parse)
  int playlists;

  @JsonKey(fromJson: int.parse)
  int bootstrap;

  LUserRegistered registered;

  LUser(
      this.name,
      this.realName,
      this.url,
      this.imageId,
      this.country,
      this.age,
      this.gender,
      this.subscriber,
      this.playCount,
      this.playlists,
      this.bootstrap,
      this.registered);

  @override
  DisplayableType get type => DisplayableType.user;

  @override
  String get displayTitle => name;

  @override
  String get displaySubtitle => realName;

  factory LUser.fromJson(Map<String, dynamic> json) => _$LUserFromJson(json);
}

@JsonSerializable()
class LUserFriendsResponse {
  @JsonKey(name: 'user')
  List<LUser> friends;

  LUserFriendsResponse(this.friends);

  factory LUserFriendsResponse.fromJson(Map<String, dynamic> json) =>
      _$LUserFriendsResponseFromJson(json);
}

@JsonSerializable()
class LAuthenticationResponseSession {
  String name;
  String key;

  LAuthenticationResponseSession(this.name, this.key);

  factory LAuthenticationResponseSession.fromJson(Map<String, dynamic> json) =>
      _$LAuthenticationResponseSessionFromJson(json);
}

@JsonSerializable()
class LUserWeeklyChart extends Displayable {
  String from;
  String to;

  LUserWeeklyChart(this.from, this.to);

  factory LUserWeeklyChart.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyChartFromJson(json);

  DateTime get fromDate => fromSecondsSinceEpoch(from);

  DateTime get toDate => fromSecondsSinceEpoch(to);

  @override
  DisplayableType get type => null;

  String get url => null;

  String get displayTitle =>
      '${DateFormat('d MMM').format(fromDate)} - ${DateFormat('d MMM yyyy').format(toDate)}';
}

@JsonSerializable()
class LUserWeeklyChartList {
  @JsonKey(name: 'chart')
  List<LUserWeeklyChart> charts;

  LUserWeeklyChartList(this.charts);

  factory LUserWeeklyChartList.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyChartListFromJson(json);
}

@JsonSerializable()
class LUserWeeklyTrackChartTrackArtist {
  @JsonKey(name: '#text')
  String name;

  LUserWeeklyTrackChartTrackArtist(this.name);

  factory LUserWeeklyTrackChartTrackArtist.fromJson(
          Map<String, dynamic> json) =>
      _$LUserWeeklyTrackChartTrackArtistFromJson(json);
}

@JsonSerializable()
class LUserWeeklyTrackChartTrack extends BasicTrack {
  @JsonKey(name: 'artist')
  LUserWeeklyTrackChartTrackArtist artistObject;

  String url;

  String name;

  @JsonKey(name: 'playcount', fromJson: intParseSafe)
  int playCount;

  LUserWeeklyTrackChartTrack(
      this.artistObject, this.url, this.name, this.playCount);

  factory LUserWeeklyTrackChartTrack.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyTrackChartTrackFromJson(json);

  @override
  String get album => null;

  @override
  String get artist => artistObject.name;

  @override
  String get displayTrailing => Intl.plural(playCount ?? 0,
      one: '$playCount scrobble', other: '$playCount scrobbles');

  @override
  Future<String> get imageIdFuture async {
    final lastfmResponse = await Lastfm.get(url);

    try {
      final doc = parse(lastfmResponse.body);
      final rawUrl =
          doc.querySelector('.cover-art').children.first.attributes['src'];
      final imageId = rawUrl.substring(
          rawUrl.lastIndexOf('/') + 1, rawUrl.lastIndexOf('.'));
      return imageId;
    } catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class LUserWeeklyTrackChart {
  @JsonKey(name: 'track')
  List<LUserWeeklyTrackChartTrack> tracks;

  LUserWeeklyTrackChart(this.tracks);

  factory LUserWeeklyTrackChart.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyTrackChartFromJson(json);
}

@JsonSerializable()
class LUserWeeklyAlbumChartAlbumArtist extends BasicArtist {
  @JsonKey(name: '#text')
  String name;

  LUserWeeklyAlbumChartAlbumArtist(this.name);

  factory LUserWeeklyAlbumChartAlbumArtist.fromJson(
          Map<String, dynamic> json) =>
      _$LUserWeeklyAlbumChartAlbumArtistFromJson(json);

  String get url => null;
}

@JsonSerializable()
class LUserWeeklyAlbumChartAlbum extends BasicAlbum {
  LUserWeeklyAlbumChartAlbumArtist artist;

  String url;

  String name;

  @JsonKey(name: 'playcount', fromJson: intParseSafe)
  int playCount;

  LUserWeeklyAlbumChartAlbum(this.artist, this.url, this.name, this.playCount);

  factory LUserWeeklyAlbumChartAlbum.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyAlbumChartAlbumFromJson(json);

  @override
  String get displayTrailing => Intl.plural(playCount ?? 0,
      one: '$playCount scrobble', other: '$playCount scrobbles');

  @override
  Future<String> get imageIdFuture async {
    final lastfmResponse = await Lastfm.get(url);

    try {
      final doc = parse(lastfmResponse.body);
      final rawUrl =
          doc.querySelector('.link-block-cover-link').attributes['href'];
      final imageId = rawUrl.substring(rawUrl.lastIndexOf('/') + 1);
      return imageId;
    } catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class LUserWeeklyAlbumChart {
  @JsonKey(name: 'album')
  List<LUserWeeklyAlbumChartAlbum> albums;

  LUserWeeklyAlbumChart(this.albums);

  factory LUserWeeklyAlbumChart.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyAlbumChartFromJson(json);
}

@JsonSerializable()
class LUserWeeklyArtistChartArtist extends BasicArtist {
  String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  String imageId;

  String name;

  @JsonKey(name: 'playcount', fromJson: intParseSafe)
  int playCount;

  LUserWeeklyArtistChartArtist(
      this.url, this.imageId, this.name, this.playCount);

  factory LUserWeeklyArtistChartArtist.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyArtistChartArtistFromJson(json);

  @override
  String get displayTrailing => Intl.plural(playCount ?? 0,
      one: '$playCount scrobble', other: '$playCount scrobbles');
}

@JsonSerializable()
class LUserWeeklyArtistChart {
  @JsonKey(name: 'artist')
  List<LUserWeeklyArtistChartArtist> artists;

  LUserWeeklyArtistChart(this.artists);

  factory LUserWeeklyArtistChart.fromJson(Map<String, dynamic> json) =>
      _$LUserWeeklyArtistChartFromJson(json);
}
