import 'package:json_annotation/json_annotation.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lcommon.dart';

part 'lalbum.g.dart';

@JsonSerializable()
class LTopAlbumsResponseAlbumArtist extends BasicArtist {
  String name;

  LTopAlbumsResponseAlbumArtist(this.name);

  factory LTopAlbumsResponseAlbumArtist.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumArtistFromJson(json);

  Map<String, dynamic> toJson() => _$LTopAlbumsResponseAlbumArtistToJson(this);
}

@JsonSerializable()
class LTopAlbumsResponseAlbum extends BasicScrobbledAlbum {
  String name;

  @JsonKey(name: 'playcount')
  String playCount;

  LTopAlbumsResponseAlbumArtist artist;

  @JsonKey(name: 'image')
  List<LImage> images;

  LTopAlbumsResponseAlbum(this.name, this.playCount, this.artist, this.images);

  factory LTopAlbumsResponseAlbum.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumFromJson(json);

  Map<String, dynamic> toJson() => _$LTopAlbumsResponseAlbumToJson(this);
}

@JsonSerializable()
class LTopAlbumsResponseTopAlbums {
  @JsonKey(name: 'album')
  List<LTopAlbumsResponseAlbum> albums;

  LTopAlbumsResponseTopAlbums(this.albums);

  factory LTopAlbumsResponseTopAlbums.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseTopAlbumsFromJson(json);

  Map<String, dynamic> toJson() => _$LTopAlbumsResponseTopAlbumsToJson(this);
}
