import 'package:finale/constants.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:html/parser.dart';
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

  @JsonKey(name: 'playcount', fromJson: int.parse)
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

  DateTime get fromDate => fromSecondsSinceEpoch(from);

  DateTime get toDate => fromSecondsSinceEpoch(to);

  String get title =>
      '${dateFormat.format(fromDate)} - ${dateFormatWithYear.format(toDate)}';
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
  String get displayTrailing => Intl.plural(playCount ?? 0,
      one: '$playCount scrobble', other: '$playCount scrobbles');

  @override
  Future<ImageId?> get imageId async {
    final lastfmResponse = await Lastfm.get(url);

    try {
      final doc = parse(lastfmResponse.body);
      final rawUrl =
          doc.querySelector('.cover-art')?.children.first.attributes['src'];

      if (rawUrl == null) {
        return null;
      }

      final imageId = rawUrl.substring(
          rawUrl.lastIndexOf('/') + 1, rawUrl.lastIndexOf('.'));
      return ImageId.lastfm(imageId);
    } catch (e) {
      return null;
    }
  }
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
  Future<ImageId?> get imageId async {
    final lastfmResponse = await Lastfm.get(url);

    try {
      final doc = parse(lastfmResponse.body);
      final rawUrl =
          doc.querySelector('.link-block-cover-link')?.attributes['href'];

      if (rawUrl == null) {
        return null;
      }

      final imageId = rawUrl.substring(rawUrl.lastIndexOf('/') + 1);
      return ImageId.lastfm(imageId);
    } catch (e) {
      return null;
    }
  }
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
  Future<ImageId?> get imageId async => (await Lastfm.getArtist(this)).imageId;

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
