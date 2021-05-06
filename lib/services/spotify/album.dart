import 'package:finale/services/generic.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class SAlbumSimple extends BasicAlbum {
  List<SArtistSimple> artists;

  @JsonKey(name: 'href')
  String url;

  String name;

  BasicArtist get artist => artists.first;

  SAlbumSimple(this.artists, this.url, this.name);

  factory SAlbumSimple.fromJson(Map<String, dynamic> json) =>
      _$SAlbumSimpleFromJson(json);
}
