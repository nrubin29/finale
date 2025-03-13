import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:finale/services/spotify/playlist.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

ImageId? extractImageId(
  List<dynamic>? /* List<Map<String, dynamic>>? */ images,
) {
  if (images == null || images.isEmpty) {
    return null;
  }

  var lowQualityImageId = images.first['url'] as String;
  lowQualityImageId = lowQualityImageId.substring(
    lowQualityImageId.lastIndexOf('/') + 1,
  );

  var highQualityImageId = images.first['url'] as String;
  highQualityImageId = highQualityImageId.substring(
    highQualityImageId.lastIndexOf('/') + 1,
  );

  return ImageId.spotify(lowQualityImageId, highQualityImageId);
}

@JsonSerializable(genericArgumentFactories: true)
class SPage<T extends Entity> {
  final List<T> items;

  const SPage(this.items);

  factory SPage.fromJson(Map<String, dynamic> json) =>
      _$SPageFromJson(json, _fromJson);

  static T _fromJson<T extends Entity>(Object? json) {
    if (json is Map<String, dynamic>) {
      if (json.containsKey('track')) {
        return SPlaylistItem.fromJson(json) as T;
      } else if (json['type'] == 'artist') {
        return SArtist.fromJson(json) as T;
      } else if (json['type'] == 'album') {
        return SAlbumSimple.fromJson(json) as T;
      } else if (json['type'] == 'track') {
        return STrack.fromJson(json) as T;
      } else if (json['type'] == 'playlist') {
        return SPlaylistSimple.fromJson(json) as T;
      }
    }

    throw ArgumentError.value(
      json,
      'json',
      'Cannot convert the provided data.',
    );
  }
}

@JsonSerializable()
class SException implements Exception {
  final String message;
  final int status;

  const SException(this.message, this.status);

  factory SException.fromJson(Map<String, dynamic> json) =>
      _$SExceptionFromJson(json);

  @override
  String toString() => 'Error $status: $message';
}
