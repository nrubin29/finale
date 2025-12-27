import 'package:finale/services/generic.dart';
import 'package:finale/services/image_provider.dart';
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
  final ImageProvider? imageProvider;

  @JsonKey(name: 'tracks', fromJson: extractIsNotEmpty)
  final bool isNotEmpty;

  SPlaylistSimple(
    this.url,
    this.name,
    this.id,
    this.imageProvider,
    this.isNotEmpty,
  );

  factory SPlaylistSimple.fromJson(Map<String, dynamic> json) =>
      _$SPlaylistSimpleFromJson(json);

  @override
  String get displayTitle => name;

  @override
  String toString() => 'SPlaylistSimple(name=$name)';

  static bool extractIsNotEmpty(Map<String, dynamic> object) =>
      (object['total'] as int) > 0;
}

class SPlaylistFull extends FullPlaylist {
  final SPlaylistSimple _playlist;

  @override
  final List<STrack> tracks;

  SPlaylistFull(this._playlist, this.tracks);

  @override
  ImageProvider? get imageProvider => _playlist.imageProvider;

  @override
  String get displayTitle => _playlist.displayTitle;

  @override
  String get url => _playlist.url;
}

@JsonSerializable()
class SPlaylistItem extends Track {
  final STrack? track;

  SPlaylistItem(this.track);

  factory SPlaylistItem.fromJson(Map<String, dynamic> json) =>
      _$SPlaylistItemFromJson(json);

  @override
  String? get albumName => track?.albumName;

  @override
  String? get artistName => track?.artistName;

  @override
  String get name => track?.name ?? 'Error';

  @override
  String? get url => track?.url;
}
