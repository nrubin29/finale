import 'package:json_annotation/json_annotation.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lcommon.dart';

part 'lartist.g.dart';

@JsonSerializable()
class LTopArtistsResponseArtist extends BasicScrobbledArtist {
  String name;

  @JsonKey(name: 'playcount')
  String playCount;

  @JsonKey(name: 'image')
  List<LImage> images;

  LTopArtistsResponseArtist(this.name, this.playCount, this.images);

  factory LTopArtistsResponseArtist.fromJson(Map<String, dynamic> json) =>
      _$LTopArtistsResponseArtistFromJson(json);

  Map<String, dynamic> toJson() => _$LTopArtistsResponseArtistToJson(this);
}

@JsonSerializable()
class LTopArtistsResponseTopArtists {
  @JsonKey(name: 'artist')
  List<LTopArtistsResponseArtist> artists;

  LTopArtistsResponseTopArtists(this.artists);

  factory LTopArtistsResponseTopArtists.fromJson(Map<String, dynamic> json) =>
      _$LTopArtistsResponseTopArtistsFromJson(json);

  Map<String, dynamic> toJson() => _$LTopArtistsResponseTopArtistsToJson(this);
}

@JsonSerializable()
class LArtistMatch extends BasicArtist {
  String name;

  @JsonKey(name: 'image')
  List<LImage> images;

  LArtistMatch(this.name, this.images);

  factory LArtistMatch.fromJson(Map<String, dynamic> json) =>
      _$LArtistMatchFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistMatchToJson(this);
}

@JsonSerializable()
class LArtistSearchResponse {
  @JsonKey(name: 'artist')
  List<LArtistMatch> artists;

  LArtistSearchResponse(this.artists);

  factory LArtistSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LArtistSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LArtistSearchResponseToJson(this);
}
