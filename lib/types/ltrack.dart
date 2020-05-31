import 'package:json_annotation/json_annotation.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lcommon.dart';

part 'ltrack.g.dart';

@JsonSerializable()
class LRecentTracksResponseTrackArtist {
  @JsonKey(name: '#text')
  String name;

  LRecentTracksResponseTrackArtist(this.name);

  factory LRecentTracksResponseTrackArtist.fromJson(
          Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackArtistFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LRecentTracksResponseTrackArtistToJson(this);
}

@JsonSerializable()
class LRecentTracksResponseTrackAlbum {
  @JsonKey(name: '#text')
  String title;

  LRecentTracksResponseTrackAlbum(this.title);

  factory LRecentTracksResponseTrackAlbum.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackAlbumFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LRecentTracksResponseTrackAlbumToJson(this);
}

@JsonSerializable()
class LRecentTracksResponseTrackDate {
  @JsonKey(name: 'uts')
  String timestamp;

  LRecentTracksResponseTrackDate(this.timestamp);

  DateTime get date =>
      DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);

  factory LRecentTracksResponseTrackDate.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackDateFromJson(json);

  Map<String, dynamic> toJson() => _$LRecentTracksResponseTrackDateToJson(this);
}

@JsonSerializable()
class LRecentTracksResponseTrack extends BasicScrobbledTrack {
  String name;

  @JsonKey(name: 'image')
  List<LImage> images;

  @JsonKey(name: 'artist')
  LRecentTracksResponseTrackArtist artistObject;

  @JsonKey(name: 'album')
  LRecentTracksResponseTrackAlbum albumObject;

  @JsonKey(name: 'date')
  LRecentTracksResponseTrackDate timestamp;

  LRecentTracksResponseTrack(this.name, this.images, this.artistObject,
      this.albumObject, this.timestamp);

  String get artist => artistObject.name;

  String get album => albumObject.title;

  DateTime get date => timestamp?.date ?? null;

  factory LRecentTracksResponseTrack.fromJson(Map<String, dynamic> json) =>
      _$LRecentTracksResponseTrackFromJson(json);

  Map<String, dynamic> toJson() => _$LRecentTracksResponseTrackToJson(this);
}

@JsonSerializable()
class LRecentTracksResponseRecentTracks {
  @JsonKey(name: 'track')
  List<LRecentTracksResponseTrack> tracks;

  LRecentTracksResponseRecentTracks(this.tracks);

  factory LRecentTracksResponseRecentTracks.fromJson(
          Map<String, dynamic> json) =>
      _$LRecentTracksResponseRecentTracksFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LRecentTracksResponseRecentTracksToJson(this);
}

@JsonSerializable()
class LTrackMatch extends BasicTrack {
  String name;
  String artist;

  @JsonKey(name: 'image')
  List<LImage> images;

  String get album => 'Album';

  LTrackMatch(this.name, this.artist, this.images);

  factory LTrackMatch.fromJson(Map<String, dynamic> json) =>
      _$LTrackMatchFromJson(json);

  Map<String, dynamic> toJson() => _$LTrackMatchToJson(this);
}

@JsonSerializable()
class LTrackSearchResponse {
  @JsonKey(name: 'track')
  List<LTrackMatch> tracks;

  LTrackSearchResponse(this.tracks);

  factory LTrackSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LTrackSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LTrackSearchResponseToJson(this);
}
