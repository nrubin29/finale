import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

@JsonSerializable()
class SpotifyTokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const SpotifyTokenResponse(
      this.accessToken, this.expiresIn, this.refreshToken);

  factory SpotifyTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$SpotifyTokenResponseFromJson(json);
}
