import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/util/formatters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

bool convertStringToBoolean(String? text) => text == '1';

int? intParseSafe(value) => value == null
    ? null
    : value is int
        ? value
        : int.tryParse(value);

int parseInt(value) => intParseSafe(value) ?? 0;

DateTime fromSecondsSinceEpoch(dynamic timestamp) =>
    DateTime.fromMillisecondsSinceEpoch(
        (timestamp is int ? timestamp : int.parse(timestamp)) * 1000);

ImageId? extractImageId(
    List<dynamic>? /* List<Map<String, dynamic>>? */ images) {
  if (images == null ||
      images.isEmpty ||
      !images.first.containsKey('#text') ||
      images.first['#text'].isEmpty) {
    return null;
  }

  final String imageUrl = images.first['#text'];
  return ImageId.lastfm(imageUrl.substring(
      imageUrl.lastIndexOf('/') + 1, imageUrl.lastIndexOf('.')));
}

mixin HasPlayCount on Entity {
  int get playCount;
}

abstract class BasicScrobbledTrack extends Track {
  DateTime? get date;

  @override
  String? get displayTrailing => formatDateTimeDelta(date);
}

abstract class BasicScrobbledAlbum extends BasicAlbum {
  int get playCount;

  @override
  String get displayTrailing => pluralize(playCount);
}

abstract class BasicScrobbledArtist extends BasicArtist {
  int get playCount;

  @override
  String get displayTrailing => pluralize(playCount);
}

@JsonSerializable()
class LScrobbleResponseScrobblesAttr {
  @JsonKey(fromJson: parseInt)
  final int accepted;

  @JsonKey(fromJson: parseInt)
  final int ignored;

  const LScrobbleResponseScrobblesAttr(this.accepted, this.ignored);

  factory LScrobbleResponseScrobblesAttr.fromJson(Map<String, dynamic> json) =>
      _$LScrobbleResponseScrobblesAttrFromJson(json);
}

@JsonSerializable()
class LTag {
  final String name;

  const LTag(this.name);

  factory LTag.fromJson(Map<String, dynamic> json) => _$LTagFromJson(json);
}

@JsonSerializable()
class LTopTags {
  @JsonKey(name: 'tag', fromJson: parseTags)
  final List<LTag> tags;

  const LTopTags(this.tags);

  factory LTopTags.fromJson(Map<String, dynamic> json) =>
      _$LTopTagsFromJson(json);

  // If there are no tags, the Last.fm API in its infinite wisdom will return
  // an empty string instead of an empty array.
  static LTopTags fromJsonSafe(json) =>
      json == '' ? const LTopTags([]) : LTopTags.fromJson(json);

  // If there's only one tag, the Last.fm API in its infinite wisdom doesn't
  // wrap it in an array literal.
  static List<LTag> parseTags(json) => json == null
      ? const []
      : json is List<dynamic>
          ? json.map((json) => LTag.fromJson(json)).toList(growable: false)
          : [LTag.fromJson(json)];
}

@JsonSerializable()
class LAttr {
  @JsonKey(fromJson: parseInt)
  final int page;

  @JsonKey(fromJson: parseInt)
  final int total;

  final String user;

  @JsonKey(fromJson: parseInt)
  final int perPage;

  @JsonKey(fromJson: parseInt)
  final int totalPages;

  const LAttr(this.page, this.total, this.user, this.perPage, this.totalPages);

  factory LAttr.fromJson(Map<String, dynamic> json) => _$LAttrFromJson(json);
}

@JsonSerializable()
class LWiki {
  final String published;

  @JsonKey(fromJson: trim)
  final String summary;

  @JsonKey(fromJson: trim)
  final String content;

  bool get isNotEmpty => summary.isNotEmpty && content.isNotEmpty;

  const LWiki(this.published, this.summary, this.content);

  factory LWiki.fromJson(Map<String, dynamic> json) => _$LWikiFromJson(json);

  static String trim(String content) {
    var result = content.trim();

    if (result.contains('<a')) {
      result = result.substring(0, result.indexOf('<a')).trim();
    }

    return result;
  }
}

@JsonSerializable()
class LException implements Exception {
  @JsonKey(name: 'error', fromJson: parseInt)
  final int code;
  final String message;

  const LException(this.code, this.message);

  factory LException.fromJson(Map<String, dynamic> json) =>
      _$LExceptionFromJson(json);

  @override
  String toString() => 'Error $code: $message';
}

class RecentListeningInformationHiddenException implements Exception {
  final String username;

  const RecentListeningInformationHiddenException(this.username);

  @override
  String toString() =>
      '$username has the "Hide recent listening information" privacy setting '
      'enabled, so their scrobbles cannot be fetched.';
}
