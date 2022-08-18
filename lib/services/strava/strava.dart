import 'dart:convert';

import 'package:finale/env.dart';
import 'package:finale/services/auth.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/strava/activity.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

Uri _buildUri(String method, Map<String, dynamic>? data) => Uri.https(
    'www.strava.com',
    'api/v3/$method',
    data?.map((key, value) => MapEntry(key, value.toString())));

Future<dynamic> _doRequest(String method, [Map<String, dynamic>? data]) async {
  assert(Preferences.hasStravaAuthData);
  if (!DateTime.now().isBefore(Preferences.stravaAuthData!.expiresAt)) {
    await Strava().refreshAccessToken(Preferences.stravaAuthData!);
  }

  final accessToken = Preferences.stravaAuthData?.accessToken;

  final uri = _buildUri(method, data);

  final response = await httpClient
      .get(uri, headers: {'Authorization': 'Bearer $accessToken'});

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else if (response.statusCode ~/ 100 == 4) {
    throw StravaException.fromJson(
        json.decode(utf8.decode(response.bodyBytes)));
  } else {
    throw Exception('Could not do request $method');
  }
}

class StravaListActivitiesRequest extends PagedRequest<AthleteActivity> {
  const StravaListActivitiesRequest();

  @override
  Future<List<AthleteActivity>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('athlete/activities', {
      'page': page,
      'per_page': limit,
    });
    return (rawResponse as List<dynamic>)
        .map((e) => AthleteActivity.fromJson(e))
        .toList(growable: false);
  }

  @override
  String toString() => 'StravaListActivitiesRequest()';
}

class Strava {
  static Strava? _instance;

  factory Strava() => _instance ??= const Strava._();

  const Strava._();

  Uri createAuthorizationUri() =>
      Uri(scheme: 'https', host: 'www.strava.com', pathSegments: [
        'oauth',
        'mobile',
        'authorize',
      ], queryParameters: {
        'client_id': stravaClientId,
        'redirect_uri': authCallbackUrl,
        'response_type': 'code',
        'approval_prompt': 'auto',
        'scope': 'activity:read',
      });

  Future<bool> authenticate() async {
    final result = await FlutterWebAuth.authenticate(
        url: createAuthorizationUri().toString(), callbackUrlScheme: 'finale');
    final code = Uri.parse(result).queryParameters['code'];

    if (code != null) {
      await _getAccessToken(code);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _callTokenEndpoint(Map<String, dynamic> body) async {
    final rawResponse = await httpClient.post(
        Uri(
          scheme: 'https',
          host: 'www.strava.com',
          pathSegments: ['api', 'v3', 'oauth', 'token'],
        ),
        body: body);
    final response = TokenResponse.fromJson(json.decode(rawResponse.body));
    Preferences.stravaAuthData = response;
  }

  Future<void> _getAccessToken(String code) => _callTokenEndpoint({
        'client_id': stravaClientId,
        'client_secret': stravaClientSecret,
        'code': code,
        'grant_type': 'authorization_code',
      });

  Future<void> refreshAccessToken(TokenResponse stravaAuthData) =>
      _callTokenEndpoint({
        'client_id': stravaClientId,
        'client_secret': stravaClientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': stravaAuthData.refreshToken,
      });
}
