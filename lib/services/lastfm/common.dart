import 'package:finale/constants.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

bool convertStringToBoolean(String? text) => text == '1';

int? intParseSafe(String? text) => text != null ? int.tryParse(text) : null;

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

mixin HasPlayCount on Displayable {
  int get playCount;
}

abstract class BasicScrobbledTrack extends Track {
  DateTime? get date;

  @override
  String get displayTrailing {
    if (date == null) {
      return 'scrobbling now';
    }

    final delta = DateTime.now().difference(date!);

    if (delta.inDays == 0) {
      if (delta.inHours == 0) {
        return '${delta.inMinutes} min${delta.inMinutes == 1 ? '' : 's'} ago';
      }

      return '${delta.inHours} hour${delta.inHours == 1 ? '' : 's'} ago';
    }

    return dateTimeFormat.format(date!);
  }
}

abstract class BasicScrobbledAlbum extends BasicAlbum {
  int get playCount;

  @override
  String get displayTrailing => '${formatNumber(playCount)} scrobbles';
}

abstract class BasicScrobbledArtist extends BasicArtist {
  int get playCount;

  @override
  String get displayTrailing => '${formatNumber(playCount)} scrobbles';
}

@JsonSerializable()
class LScrobbleResponseScrobblesAttr {
  final int accepted;
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
  @JsonKey(name: 'tag')
  final List<LTag> tags;

  const LTopTags(this.tags);

  factory LTopTags.fromJson(Map<String, dynamic> json) =>
      _$LTopTagsFromJson(json);
}

@JsonSerializable()
class LAttr {
  @JsonKey(fromJson: int.parse)
  final int page;

  @JsonKey(fromJson: int.parse)
  final int total;

  final String user;

  @JsonKey(fromJson: int.parse)
  final int perPage;

  @JsonKey(fromJson: int.parse)
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

    if (result.indexOf('<a') != -1) {
      result = result.substring(0, result.indexOf('<a')).trim();
    }

    return result;
  }
}

@JsonSerializable()
class LError {
  @JsonKey(name: 'error')
  final int code;

  final String message;

  const LError(this.code, this.message);

  factory LError.fromJson(Map<String, dynamic> json) => _$LErrorFromJson(json);
}
