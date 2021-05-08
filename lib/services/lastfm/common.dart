import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

bool convertStringToBoolean(String text) => text == '1';

int intParseSafe(String text) => text != null ? int.tryParse(text) : null;

DateTime fromSecondsSinceEpoch(dynamic timestamp) =>
    DateTime.fromMillisecondsSinceEpoch(
        (timestamp is int ? timestamp : int.parse(timestamp)) * 1000);

ImageId extractImageId(List<dynamic> /* List<Map<String, dynamic>> */ images) {
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
  DateTime get date;

  @override
  String get displayTrailing {
    if (date == null) {
      return 'scrobbling now';
    }

    final delta = DateTime.now().difference(date);

    if (delta.inDays == 0) {
      if (delta.inHours == 0) {
        return '${delta.inMinutes} min${delta.inMinutes == 1 ? '' : 's'} ago';
      }

      return '${delta.inHours} hour${delta.inHours == 1 ? '' : 's'} ago';
    }

    return DateFormat('dd MMM HH:mm aa').format(date);
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
  int accepted;
  int ignored;

  LScrobbleResponseScrobblesAttr(this.accepted, this.ignored);

  factory LScrobbleResponseScrobblesAttr.fromJson(Map<String, dynamic> json) =>
      _$LScrobbleResponseScrobblesAttrFromJson(json);
}

@JsonSerializable()
class LTag {
  String name;

  LTag(this.name);

  factory LTag.fromJson(Map<String, dynamic> json) => _$LTagFromJson(json);
}

@JsonSerializable()
class LTopTags {
  @JsonKey(name: 'tag')
  List<LTag> tags;

  LTopTags(this.tags);

  factory LTopTags.fromJson(Map<String, dynamic> json) =>
      _$LTopTagsFromJson(json);
}

@JsonSerializable()
class LAttr {
  @JsonKey(fromJson: int.parse)
  int page;

  @JsonKey(fromJson: int.parse)
  int total;

  String user;

  @JsonKey(fromJson: int.parse)
  int perPage;

  @JsonKey(fromJson: int.parse)
  int totalPages;

  LAttr(this.page, this.total, this.user, this.perPage, this.totalPages);

  factory LAttr.fromJson(Map<String, dynamic> json) => _$LAttrFromJson(json);
}

@JsonSerializable()
class LWiki {
  String published;
  String summary;
  String content;

  LWiki(this.published, this.summary, this.content);

  factory LWiki.fromJson(Map<String, dynamic> json) => _$LWikiFromJson(json);
}

@JsonSerializable()
class LError {
  @JsonKey(name: 'error')
  int code;

  String message;

  LError(this.code, this.message);

  factory LError.fromJson(Map<String, dynamic> json) => _$LErrorFromJson(json);
}
