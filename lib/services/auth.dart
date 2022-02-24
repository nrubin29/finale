import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

DateTime _expiresAt(int expiresIn) =>
    DateTime.now().add(Duration(seconds: expiresIn));

@JsonSerializable()
class TokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'expires_in', fromJson: _expiresAt)
  final DateTime expiresAt;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const TokenResponse(this.accessToken, this.expiresAt, this.refreshToken);

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
}
