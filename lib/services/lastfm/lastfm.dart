import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:finale/env.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/util/preferences.dart';

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
    {bool post = false}) async {
  final uri = _buildUri(method, data);
  final response =
      post ? await httpClient.post(uri) : await httpClient.get(uri);

  dynamic jsonObject;

  try {
    jsonObject = json.decode(utf8.decode(response.bodyBytes));
  } on FormatException {
    throw Exception(
        'Could not do request $method($data). Got response ${response.body}');
  }

  if (!(jsonObject is Map<String, dynamic>)) {
    throw Exception('Invalid response type for $method($data): $jsonObject');
  } else if (jsonObject.containsKey('error')) {
    throw LException.fromJson(jsonObject);
  }

  return jsonObject;
}

class GetRecentTracksRequest extends PagedRequest<LRecentTracksResponseTrack> {
  final String username;
  final String? from;
  final String? to;

  const GetRecentTracksRequest(this.username, [this.from, this.to]);

  @override
  doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('user.getRecentTracks', {
      'user': username,
      'limit': limit,
      'page': page,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    });
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
  final String username;
  final Period? period;

  const GetTopArtistsRequest(this.username, [this.period]);

  @override
  doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('user.getTopArtists', {
      'user': username,
      'limit': limit,
      'page': page,
      'period': (period ?? Preferences().period).value,
    });
    return LTopArtistsResponseTopArtists.fromJson(rawResponse['topartists'])
        .artists;
  }
}

class GetTopAlbumsRequest extends PagedRequest<LTopAlbumsResponseAlbum> {
  final String username;
  final Period? period;

  const GetTopAlbumsRequest(this.username, [this.period]);

  @override
  doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('user.getTopAlbums', {
      'user': username,
      'limit': limit,
      'page': page,
      'period': (period ?? Preferences().period).value,
    });
    return LTopAlbumsResponseTopAlbums.fromJson(rawResponse['topalbums'])
        .albums;
  }
}

class GetTopTracksRequest extends PagedRequest<LTopTracksResponseTrack> {
  final String username;

  const GetTopTracksRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('user.getTopTracks', {
      'user': username,
      'limit': limit,
      'page': page,
      'period': Preferences().period.value
    });
    return LTopTracksResponseTopTracks.fromJson(rawResponse['toptracks'])
        .tracks;
  }
}

class GetFriendsRequest extends PagedRequest<LUser> {
  final String username;

  const GetFriendsRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    final rawResponse = await _doRequest(
        'user.getFriends', {'user': username, 'limit': limit, 'page': page});
    return LUserFriendsResponse.fromJson(rawResponse['friends']).friends;
  }
}

class LSearchTracksRequest extends PagedRequest<LTrackMatch> {
  final String query;

  const LSearchTracksRequest(this.query);

  @override
  Future<List<LTrackMatch>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest(
        'track.search', {'track': query, 'limit': limit, 'page': page});
    return LTrackSearchResponse.fromJson(rawResponse['results']['trackmatches'])
        .tracks;
  }
}

class LSearchArtistsRequest extends PagedRequest<LArtistMatch> {
  final String query;

  const LSearchArtistsRequest(this.query);

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
  final String query;

  const LSearchAlbumsRequest(this.query);

  @override
  Future<List<LAlbumMatch>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest(
        'album.search', {'album': query, 'limit': limit, 'page': page});
    return LAlbumSearchResponse.fromJson(rawResponse['results']['albummatches'])
        .albums;
  }
}

class ArtistGetTopAlbumsRequest extends PagedRequest<LArtistTopAlbum> {
  final String artist;

  const ArtistGetTopAlbumsRequest(this.artist);

  @override
  Future<List<LArtistTopAlbum>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('artist.getTopAlbums',
        {'artist': artist, 'limit': limit, 'page': page});
    return LArtistGetTopAlbumsResponse.fromJson(rawResponse['topalbums'])
        .albums;
  }
}

class ArtistGetTopTracksRequest extends PagedRequest<LArtistTopTrack> {
  final String artist;

  const ArtistGetTopTracksRequest(this.artist);

  @override
  Future<List<LArtistTopTrack>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('artist.getTopTracks',
        {'artist': artist, 'limit': limit, 'page': page});
    return LArtistGetTopTracksResponse.fromJson(rawResponse['toptracks'])
        .tracks;
  }
}

class Lastfm {
  static Future<LAuthenticationResponseSession> authenticate(
      String token) async {
    final rawResponse =
        await _doRequest('auth.getSession', {'token': token}, post: true);
    return LAuthenticationResponseSession.fromJson(rawResponse['session']);
  }

  static Future<LUser> getUser(String username) async {
    final rawResponse = await _doRequest('user.getInfo', {'user': username});
    return LUser.fromJson(rawResponse['user']);
  }

  static Future<LTrack> getTrack(Track track) async {
    final rawResponse = await _doRequest('track.getInfo', {
      'track': track.name,
      'artist': track.artistName,
      'username': Preferences().name,
    });
    return LTrack.fromJson(rawResponse['track']);
  }

  static Future<LAlbum> getAlbum(BasicAlbum album) async {
    final rawResponse = await _doRequest('album.getInfo', {
      'album': album.name,
      'artist': album.artist.name,
      'username': Preferences().name,
    });
    return LAlbum.fromJson(rawResponse['album']);
  }

  static Future<LArtist> getArtist(BasicArtist artist) async {
    final rawResponse = await _doRequest('artist.getInfo', {
      'artist': artist.name,
      'username': Preferences().name,
    });
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
    final data = <String, dynamic>{};
    data['sk'] = Preferences().key;

    tracks.asMap().forEach((i, track) {
      if (track.albumName?.isNotEmpty ?? false) {
        data['album[$i]'] = track.albumName;
      }

      data['artist[$i]'] = track.artistName;
      data['track[$i]'] = track.name;
      data['timestamp[$i]'] = timestamps[i].millisecondsSinceEpoch ~/ 1000;
    });

    final rawResponse = await _doRequest('track.scrobble', data, post: true);
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
          'sk': Preferences().key,
        },
        post: true);
    return true;
  }
}
