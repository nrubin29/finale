import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:finale/env.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:finale/services/spotify/auth.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:finale/services/spotify/playlist.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:pkce/pkce.dart';

Uri _buildUri(String method, Map<String, dynamic>? data) => Uri.https(
    'api.spotify.com',
    'v1/$method',
    data?.map((key, value) => MapEntry(key, value.toString())));

Future<Map<String, dynamic>> _doRequest(String method,
    [Map<String, dynamic>? data]) async {
  if (!Preferences().isSpotifyLoggedIn) {
    await Spotify.refreshAccessToken(Preferences().spotifyRefreshToken!);
  }

  final accessToken = Preferences().spotifyAccessToken;

  final uri = _buildUri(method, data);

  final response = await httpClient
      .get(uri, headers: {'Authorization': 'Bearer $accessToken'});

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else if (response.statusCode ~/ 100 == 4) {
    throw SException.fromJson(
        json.decode(utf8.decode(response.bodyBytes))['error']);
  } else {
    throw Exception('Could not do request $method');
  }
}

class SSearchTracksRequest extends PagedRequest<STrack> {
  final String query;

  const SSearchTracksRequest(this.query);

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

class SSearchArtistsRequest extends PagedRequest<SArtist> {
  final String query;

  const SSearchArtistsRequest(this.query);

  @override
  Future<List<SArtist>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('search', {
      'q': query,
      'type': 'artist',
      'limit': limit,
      'offset': (page - 1) * limit
    });
    return SPage<SArtist>.fromJson(rawResponse['artists']).items;
  }
}

class SSearchAlbumsRequest extends PagedRequest<SAlbumSimple> {
  final String query;

  const SSearchAlbumsRequest(this.query);

  @override
  Future<List<SAlbumSimple>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('search', {
      'q': query,
      'type': 'album',
      'limit': limit,
      'offset': (page - 1) * limit
    });
    return SPage<SAlbumSimple>.fromJson(rawResponse['albums']).items;
  }
}

class SSearchPlaylistsRequest extends PagedRequest<SPlaylistSimple> {
  final String query;

  const SSearchPlaylistsRequest(this.query);

  @override
  Future<List<SPlaylistSimple>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('search', {
      'q': query,
      'type': 'playlist',
      'limit': limit,
      'offset': (page - 1) * limit,
    });
    return SPage<SPlaylistSimple>.fromJson(rawResponse['playlists']).items;
  }
}

class SArtistAlbumsRequest extends PagedRequest<SAlbumSimple> {
  final SArtist artist;

  const SArtistAlbumsRequest(this.artist);

  @override
  Future<List<SAlbumSimple>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('artists/${artist.id}/albums',
        {'limit': limit, 'offset': (page - 1) * limit});
    return SPage<SAlbumSimple>.fromJson(rawResponse).items;
  }
}

class SPlaylistTracksRequest extends PagedRequest<STrack> {
  final SPlaylistSimple playlist;

  const SPlaylistTracksRequest(this.playlist);

  @override
  Future<List<STrack>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('playlists/${playlist.id}/tracks',
        {'limit': limit, 'offset': (page - 1) * limit});
    return SPage<SPlaylistItem>.fromJson(rawResponse)
        .items
        .map((e) => e.track)
        .whereNotNull()
        .toList();
  }
}

class Spotify {
  static Future<SAlbumFull> getFullAlbum(SAlbumSimple simpleAlbum) async {
    final rawResponse = await _doRequest('albums/${simpleAlbum.id}');
    return SAlbumFull.fromJson(rawResponse);
  }

  static Future<SArtist> getFullArtist(SArtistSimple simpleArtist) async {
    final rawResponse = await _doRequest('artists/${simpleArtist.id}');
    return SArtist.fromJson(rawResponse);
  }

  static Future<SPlaylistFull> getFullPlaylist(
      SPlaylistSimple simplePlaylist) async {
    final tracks = await SPlaylistTracksRequest(simplePlaylist).getAllData();
    return SPlaylistFull(simplePlaylist, tracks);
  }

  static Future<List<STrack>> getTopTracksForArtist(SArtist artist) async {
    final rawResponse =
        await _doRequest('artists/${artist.id}/top-tracks', {'market': 'US'});
    return (rawResponse['tracks'] as List<dynamic>)
        .map((track) => STrack.fromJson(track))
        .toList(growable: false);
  }

  static Future<bool> authenticate() async {
    final pkcePair = PkcePair.generate(stripTrailingPadding: true);
    final result = await FlutterWebAuth.authenticate(
        url: _createAuthorizationUri(pkcePair).toString(),
        callbackUrlScheme: 'finale');
    final code = Uri.parse(result).queryParameters['code'];

    if (code != null) {
      await _getAccessToken(code, pkcePair);
      return true;
    } else {
      return false;
    }
  }

  static Uri _createAuthorizationUri(PkcePair pkcePair) =>
      Uri.https('accounts.spotify.com', 'authorize', {
        'client_id': spotifyClientId,
        'response_type': 'code',
        'redirect_uri': authCallbackUrl,
        'code_challenge_method': 'S256',
        'code_challenge': pkcePair.codeChallenge,
      });

  static Future<void> _callTokenEndpoint(Map<String, dynamic> body) async {
    final rawResponse = await httpClient.post(
      Uri.https('accounts.spotify.com', 'api/token'),
      body: body,
    );
    final response =
        SpotifyTokenResponse.fromJson(json.decode(rawResponse.body));
    Preferences()
      ..spotifyAccessToken = response.accessToken
      ..spotifyRefreshToken = response.refreshToken
      ..spotifyExpiration =
          DateTime.now().add(Duration(seconds: response.expiresIn));
  }

  static Future<void> _getAccessToken(String code, PkcePair pkcePair) =>
      _callTokenEndpoint({
        'client_id': spotifyClientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': authCallbackUrl,
        'code_verifier': pkcePair.codeVerifier,
      });

  static Future<void> refreshAccessToken(String refreshToken) =>
      _callTokenEndpoint({
        'client_id': spotifyClientId,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      });
}
