import 'package:finale/services/generic.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

String extractImageUrl(List<dynamic> /* List<Map<String, dynamic>> */ images) =>
    images == null || images.isEmpty ? null : images.first['url'];

@JsonSerializable(genericArgumentFactories: true)
class SPage<T extends Displayable> {
  List<T> items;

  SPage(this.items);

  factory SPage.fromJson(Map<String, dynamic> json) =>
      _$SPageFromJson(json, _fromJson);

  static T _fromJson<T extends Displayable>(Object json) {
    if (json is Map<String, dynamic>) {
      if (json['type'] == 'artist') {
        return SArtistSimple.fromJson(json) as T;
      } else if (json['type'] == 'album') {
        return SAlbumSimple.fromJson(json) as T;
      } else if (json['type'] == 'track') {
        return STrack.fromJson(json) as T;
      }
    }

    throw ArgumentError.value(
        json, 'json', 'Cannot convert the provided data.');
  }
}

@JsonSerializable()
class SError {
  String message;
  int status;

  SError(this.message, this.status);

  factory SError.fromJson(Map<String, dynamic> json) => _$SErrorFromJson(json);
}
