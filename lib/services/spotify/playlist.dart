import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'playlist.g.dart';

@JsonSerializable()
class SPlaylistSimple extends BasicPlaylist {
  @JsonKey(name: 'href')
  @override
  final String url;

  final String name;

  final String id;

  @JsonKey(name: 'images', fromJson: extractImageId)
  @override
  final ImageId? imageId;

  SPlaylistSimple(this.url, this.name, this.id, this.imageId);

  factory SPlaylistSimple.fromJson(Map<String, dynamic> json) =>
      _$SPlaylistSimpleFromJson(json);

  @override
  String get displayTitle => name;

  @override
  String toString() => 'SPlaylistSimple(name=$name)';
}

@JsonSerializable()
class SPlaylistFull extends FullPlaylist {
  @JsonKey(name: 'href')
  @override
  final String url;

  final String name;

  final String id;

  @JsonKey(name: 'images', fromJson: extractImageId)
  @override
  final ImageId? imageId;

  @JsonKey(fromJson: extractItems)
  @override
  final List<STrack> tracks;

  SPlaylistFull(this.url, this.name, this.id, this.imageId, this.tracks);

  factory SPlaylistFull.fromJson(Map<String, dynamic> json) =>
      _$SPlaylistFullFromJson(json);

  @override
  String get displayTitle => name;

  @override
  String toString() => 'SPlaylistFull(name=$name)';

  static List<STrack> extractItems(Map<String, dynamic> object) =>
      (object['items'] as List<dynamic>)
          .map((item) => STrack.fromJson(item['track']))
          .toList(growable: false);
}
