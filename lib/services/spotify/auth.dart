import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

@JsonSerializable()
class SpotifyTokenResponse {
  @JsonKey(name: 'access_token')
  String accessToken;

  @JsonKey(name: 'expires_in')
  int expiresIn;

  @JsonKey(name: 'refresh_token')
  String refreshToken;

  SpotifyTokenResponse(this.accessToken, this.expiresIn, this.refreshToken);

  factory SpotifyTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$SpotifyTokenResponseFromJson(json);
}
