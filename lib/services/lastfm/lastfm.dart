import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:finale/env.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

Uri _buildUri(String method, Map<String, dynamic> data) {
  final allData = {
    ...data.map((key, value) => MapEntry(key, value.toString())),
    'api_key': apiKey,
    'method': method,
  };

  final hash = (allData.keys.toList()..sort())
          .map((key) => '$key${allData[key]}')
          .join() +
      apiSecret;
  final signature = md5.convert(utf8.encode(hash));
  allData['api_sig'] = signature.toString();
  allData['format'] = 'json';

  return Uri(
      scheme: 'https',
      host: 'ws.audioscrobbler.com',
      path: '2.0',
      queryParameters: allData);
}

Future<Map<String, dynamic>> _doRequest(
    String method, Map<String, dynamic> data,
    {RequestVerb verb = RequestVerb.get}) async {
  final uri = _buildUri(method, data);

  final response = verb == RequestVerb.get
      ? await httpClient.get(uri)
      : await httpClient.post(uri);

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else if (response.statusCode == 400) {
    final error = LError.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    throw LException(error.code, error.message);
  } else {
    throw Exception('Could not do request $method');
  }
}

class GetRecentTracksRequest extends PagedRequest<LRecentTracksResponseTrack> {
  String username;

  GetRecentTracksRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('user.getRecentTracks',
        {'user': username, 'limit': limit, 'page': page});
    final tracks =
        LRecentTracksResponseRecentTracks.fromJson(rawResponse['recenttracks'])
            .tracks;

    // For some reason, this endpoint always returns the currently-playing
    // song regardless of which page you request.
    if (page != 1 && tracks.isNotEmpty && tracks.first.date == null) {
      tracks.removeAt(0);
    }

    return tracks;
  }
}

class GetTopArtistsRequest extends PagedRequest<LTopArtistsResponseArtist> {
  String username;

  GetTopArtistsRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    final period =
        (await SharedPreferences.getInstance()).getString('period') ?? '7day';

    final rawResponse = await _doRequest('user.getTopArtists',
        {'user': username, 'limit': limit, 'page': page, 'period': period});
    return LTopArtistsResponseTopArtists.fromJson(rawResponse['topartists'])
        .artists;
  }
}

class GetTopAlbumsRequest extends PagedRequest<LTopAlbumsResponseAlbum> {
  String username;

  GetTopAlbumsRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    final period =
        (await SharedPreferences.getInstance()).getString('period') ?? '7day';

    final rawResponse = await _doRequest('user.getTopAlbums',
        {'user': username, 'limit': limit, 'page': page, 'period': period});
    return LTopAlbumsResponseTopAlbums.fromJson(rawResponse['topalbums'])
        .albums;
  }
}

class GetTopTracksRequest extends PagedRequest<LTopTracksResponseTrack> {
  String username;

  GetTopTracksRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    final period =
        (await SharedPreferences.getInstance()).getString('period') ?? '7day';

    final rawResponse = await _doRequest('user.getTopTracks',
        {'user': username, 'limit': limit, 'page': page, 'period': period});
    return LTopTracksResponseTopTracks.fromJson(rawResponse['toptracks'])
        .tracks;
  }
}

class GetFriendsRequest extends PagedRequest<LUser> {
  String username;

  GetFriendsRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    final rawResponse = await _doRequest(
        'user.getFriends', {'user': username, 'limit': limit, 'page': page});
    return LUserFriendsResponse.fromJson(rawResponse['friends']).friends;
  }
}

class LSearchTracksRequest extends PagedRequest<LTrackMatch> {
  String query;

  LSearchTracksRequest(this.query);

  @override
  Future<List<LTrackMatch>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest(
        'track.search', {'track': query, 'limit': limit, 'page': page});
    return LTrackSearchResponse.fromJson(rawResponse['results']['trackmatches'])
        .tracks;
  }
}

class LSearchArtistsRequest extends PagedRequest<LArtistMatch> {
  String query;

  LSearchArtistsRequest(this.query);

  @override
  Future<List<LArtistMatch>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest(
        'artist.search', {'artist': query, 'limit': limit, 'page': page});
    return LArtistSearchResponse.fromJson(
            rawResponse['results']['artistmatches'])
        .artists;
  }
}

class LSearchAlbumsRequest extends PagedRequest<LAlbumMatch> {
  String query;

  LSearchAlbumsRequest(this.query);

  @override
  Future<List<LAlbumMatch>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest(
        'album.search', {'album': query, 'limit': limit, 'page': page});
    return LAlbumSearchResponse.fromJson(rawResponse['results']['albummatches'])
        .albums;
  }
}

class ArtistGetTopAlbumsRequest extends PagedRequest<LArtistTopAlbum> {
  String artist;

  ArtistGetTopAlbumsRequest(this.artist);

  @override
  Future<List<LArtistTopAlbum>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('artist.getTopAlbums',
        {'artist': artist, 'limit': limit, 'page': page});
    return LArtistGetTopAlbumsResponse.fromJson(rawResponse['topalbums'])
        .albums;
  }
}

class ArtistGetTopTracksRequest extends PagedRequest<LArtistTopTrack> {
  String artist;

  ArtistGetTopTracksRequest(this.artist);

  @override
  Future<List<LArtistTopTrack>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('artist.getTopTracks',
        {'artist': artist, 'limit': limit, 'page': page});
    return LArtistGetTopTracksResponse.fromJson(rawResponse['toptracks'])
        .tracks;
  }
}

class Lastfm {
  static Future<Response> get(String url) => httpClient.get(Uri.parse(url));

  static Future<LAuthenticationResponseSession> authenticate(
      String token) async {
    final rawResponse = await _doRequest('auth.getSession', {'token': token},
        verb: RequestVerb.post);
    return LAuthenticationResponseSession.fromJson(rawResponse['session']);
  }

  static Future<LUser> getUser(String username) async {
    final rawResponse = await _doRequest('user.getInfo', {'user': username});
    return LUser.fromJson(rawResponse['user']);
  }

  static Future<LTrack> getTrack(Track track) async {
    final username = (await SharedPreferences.getInstance()).getString('name');

    final rawResponse = await _doRequest('track.getInfo', {
      'track': track.name,
      'artist': track.artistName,
      'username': username
    });
    return LTrack.fromJson(rawResponse['track']);
  }

  static Future<LAlbum> getAlbum(BasicAlbum album) async {
    final username = (await SharedPreferences.getInstance()).getString('name');

    final rawResponse = await _doRequest('album.getInfo', {
      'album': album.name,
      'artist': album.artist.name,
      'username': username
    });
    return LAlbum.fromJson(rawResponse['album']);
  }

  static Future<LArtist> getArtist(BasicArtist artist) async {
    final username = (await SharedPreferences.getInstance()).getString('name');

    final rawResponse = await _doRequest(
        'artist.getInfo', {'artist': artist.name, 'username': username});
    return LArtist.fromJson(rawResponse['artist']);
  }

  static Future<LUserWeeklyChartList> getWeeklyChartList(LUser user) async {
    final rawResponse =
        await _doRequest('user.getWeeklyChartList', {'user': user.name});
    return LUserWeeklyChartList.fromJson(rawResponse['weeklychartlist']);
  }

  static Future<LUserWeeklyTrackChart> getWeeklyTrackChart(
      LUser user, LUserWeeklyChart chart) async {
    final rawResponse = await _doRequest('user.getWeeklyTrackChart', {
      'user': user.name,
      'from': chart.from,
      'to': chart.to,
    });
    return LUserWeeklyTrackChart.fromJson(rawResponse['weeklytrackchart']);
  }

  static Future<LUserWeeklyAlbumChart> getWeeklyAlbumChart(
      LUser user, LUserWeeklyChart chart) async {
    final rawResponse = await _doRequest('user.getWeeklyAlbumChart', {
      'user': user.name,
      'from': chart.from,
      'to': chart.to,
    });
    return LUserWeeklyAlbumChart.fromJson(rawResponse['weeklyalbumchart']);
  }

  static Future<LUserWeeklyArtistChart> getWeeklyArtistChart(
      LUser user, LUserWeeklyChart chart) async {
    final rawResponse = await _doRequest('user.getWeeklyArtistChart', {
      'user': user.name,
      'from': chart.from,
      'to': chart.to,
    });
    return LUserWeeklyArtistChart.fromJson(rawResponse['weeklyartistchart']);
  }

  static Future<int> getNumArtists(String username) async {
    final rawResponse = await _doRequest('user.getTopArtists',
        {'user': username, 'period': 'overall', 'limit': '1', 'page': '1'});
    return LTopArtistsResponseTopArtists.fromJson(rawResponse['topartists'])
        .attr
        .total;
  }

  static Future<int> getNumAlbums(String username) async {
    final rawResponse = await _doRequest('user.getTopAlbums',
        {'user': username, 'period': 'overall', 'limit': '1', 'page': '1'});
    return LTopAlbumsResponseTopAlbums.fromJson(rawResponse['topalbums'])
        .attr
        .total;
  }

  static Future<int> getNumTracks(String username) async {
    final rawResponse = await _doRequest('user.getTopTracks',
        {'user': username, 'period': 'overall', 'limit': '1', 'page': '1'});
    return LTopTracksResponseTopTracks.fromJson(rawResponse['toptracks'])
        .attr
        .total;
  }

  static Future<List<LTopArtistsResponseArtist>> getGlobalTopArtists(
      int limit) async {
    final rawResponse =
        await _doRequest('chart.getTopArtists', {'limit': limit, 'page': 1});
    return LChartTopArtists.fromJson(rawResponse['artists']).artists;
  }

  static Future<LScrobbleResponseScrobblesAttr> scrobble(
      List<Track> tracks, List<DateTime> timestamps) async {
    final Map<String, dynamic> data = {};
    data['sk'] = (await SharedPreferences.getInstance()).getString('key');

    tracks.asMap().forEach((i, track) {
      if (track.albumName?.isNotEmpty ?? false) {
        data['album[$i]'] = track.albumName;
      }

      data['artist[$i]'] = track.artistName;
      data['track[$i]'] = track.name;
      data['timestamp[$i]'] = timestamps[i].millisecondsSinceEpoch ~/ 1000;
    });

    final rawResponse =
        await _doRequest('track.scrobble', data, verb: RequestVerb.post);
    return LScrobbleResponseScrobblesAttr.fromJson(
        rawResponse['scrobbles']['@attr']);
  }

  /// Loves or unloves a track. If [love] is true, the track will be loved;
  /// otherwise, it will be unloved.
  static Future<bool> love(Track track, bool love) async {
    if (track.artistName == null) {
      return false;
    }

    await _doRequest(
        love ? 'track.love' : 'track.unlove',
        {
          'track': track.name,
          'artist': track.artistName,
          'sk': (await SharedPreferences.getInstance()).getString('key')
        },
        verb: RequestVerb.post);
    return true;
  }
}

class LException implements Exception {
  int code;
  String message;

  LException(this.code, this.message);

  @override
  String toString() {
    return 'Error $code: $message';
  }
}
