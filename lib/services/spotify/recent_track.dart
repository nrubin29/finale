import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recent_track.g.dart';

@JsonSerializable()
class SRecentTracksResponse {
  final List<SRecentTrack> items;

  const SRecentTracksResponse(this.items);

  factory SRecentTracksResponse.fromJson(Map<String, dynamic> json) =>
      _$SRecentTracksResponseFromJson(json);
}

@JsonSerializable()
class SRecentTrack {
  final STrack track;

  @JsonKey(name: 'played_at', fromJson: parseDateTime)
  final DateTime playedAt;

  const SRecentTrack(this.track, this.playedAt);

  factory SRecentTrack.fromJson(Map<String, dynamic> json) =>
      _$SRecentTrackFromJson(json);
}
