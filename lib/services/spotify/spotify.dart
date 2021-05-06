import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:finale/env.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/spotify/auth.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:shared_preferences/shared_preferences.dart';

Uri _buildUri(String method, Map<String, dynamic> data) => Uri.https(
    'api.spotify.com',
    'v1/$method',
    data.map((key, value) => MapEntry(key, value.toString())));

Future<Map<String, dynamic>> _doRequest(
    String method, Map<String, dynamic> data) async {
  final accessToken =
      (await SharedPreferences.getInstance()).getString('spotifyAccessToken');

  // TODO: If the access token is expired, use the refresh token.

  final uri = _buildUri(method, data);

  final response = await httpClient
      .get(uri, headers: {'Authorization': 'Bearer $accessToken'});

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else if (response.statusCode == 400) {
    final error = SError.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    throw SException(error.message, error.status);
  } else {
    throw Exception('Could not do request $method');
  }
}

class SSearchTracksRequest extends PagedRequest<STrack> {
  String query;

  SSearchTracksRequest(this.query);

  @override
  Future<List<STrack>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('search', {
      'q': query,
      'type': 'track',
      'limit': limit,
      'offset': (page - 1) * limit
    });
    return SPage<STrack>.fromJson(rawResponse['tracks']).items;
  }
}

class PkcePair {
  static const _alphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';

  final String _codeVerifier;
  final String _codeChallenge;

  const PkcePair._(this._codeVerifier, this._codeChallenge);

  factory PkcePair.generate() {
    final random = Random.secure();
    final verifier = List.generate(
        128, (index) => _alphabet[random.nextInt(_alphabet.length)]).join();
    var challenge =
        base64UrlEncode(sha256.convert(ascii.encode(verifier)).bytes);

    while (challenge.endsWith('=')) {
      challenge = challenge.substring(0, challenge.length - 1);
    }

    return PkcePair._(verifier, challenge);
  }

  String get codeVerifier => _codeVerifier;
  String get codeChallenge => _codeChallenge;
}

class Spotify {
  static const _redirectUri = 'finale://spotify';

  static Uri createAuthorizationUri(PkcePair pkcePair) =>
      Uri.https('accounts.spotify.com', 'authorize', {
        'client_id': spotifyClientId,
        'response_type': 'code',
        'redirect_uri': _redirectUri,
        'code_challenge_method': 'S256',
        'code_challenge': pkcePair.codeChallenge,
      });

  static Future<SpotifyTokenResponse> getAccessToken(
      String code, PkcePair pkcePair) async {
    final response = await httpClient.post(
      Uri.https('accounts.spotify.com', 'api/token'),
      body: {
        'client_id': spotifyClientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _redirectUri,
        'code_verifier': pkcePair.codeVerifier,
      },
    );
    return SpotifyTokenResponse.fromJson(json.decode(response.body));
  }
}

class SException implements Exception {
  final String message;
  final int status;

  const SException(this.message, this.status);
}
