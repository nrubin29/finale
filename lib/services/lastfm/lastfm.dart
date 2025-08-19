import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:finale/env.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/services/lastfm/period_paged_request.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/util/extensions.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/web_auth.dart';

Uri _buildUri(String method, Map<String, dynamic> data, {bool libre = false}) {
  final allData = {
    ...data.map((key, value) => MapEntry(key, value.toString())),
    'api_key': apiKey,
    'method': method,
  };

  final hash =
      (allData.keys.toList()..sort())
          .map((key) => '$key${allData[key]}')
          .join() +
      apiSecret;
  final signature = md5.convert(utf8.encode(hash));
  allData['api_sig'] = signature.toString();
  allData['format'] = 'json';

  return Uri(
    scheme: 'https',
    host: libre ? 'libre.fm' : 'ws.audioscrobbler.com',
    path: '2.0/',
    queryParameters: allData,
  );
}

Future<Map<String, dynamic>> _doRequest(
  String method,
  Map<String, dynamic> data, {
  bool post = false,
  bool libre = false,
}) async {
  final uri = _buildUri(method, data, libre: libre);
  final response = post
      ? await httpClient.post(uri, body: libre ? uri.queryParameters : null)
      : await httpClient.get(uri);

  dynamic jsonObject;

  try {
    jsonObject = json.decode(utf8.decode(response.bodyBytes));
  } on FormatException {
    throw Exception(
      'Could not do request $method($data). Got response ${response.body}',
    );
  }

  if (jsonObject is! Map<String, dynamic>) {
    throw Exception('Invalid response type for $method($data): $jsonObject');
  } else if (jsonObject.containsKey('error')) {
    throw LException.fromJson(jsonObject);
  }

  return jsonObject;
}

class GetRecentTracksRequest extends PagedRequest<LRecentTracksResponseTrack> {
  final String username;
  final DateTime? from;
  final DateTime? to;
  final bool includeCurrentScrobble;
  final bool extended;

  const GetRecentTracksRequest(
    this.username, {
    this.from,
    this.to,
    this.includeCurrentScrobble = false,
    this.extended = false,
  });

  GetRecentTracksRequest.forPeriod(
    this.username,
    Period period, {
    this.extended = false,
  }) : from = period.relativeStart,
       to = period.end,
       includeCurrentScrobble = false;

  Future<LRecentTracksResponseRecentTracks> _doRecentTracksRequest(
    int limit,
    int page,
  ) async {
    Map<String, dynamic> rawResponse;

    try {
      rawResponse = await _doRequest('user.getRecentTracks', {
        'user': username,
        'limit': limit,
        'page': page,
        if (from != null) 'from': from!.secondsSinceEpoch.toString(),
        if (to != null) 'to': to!.secondsSinceEpoch.toString(),
        'extended': extended ? '1' : '0',
        'sk': Preferences.key.value,
      });
    } on LException catch (e) {
      if (e.code == 17) {
        // "Login: User required to be logged in"
        throw RecentListeningInformationHiddenException(username);
      }
      rethrow;
    }

    return LRecentTracksResponseRecentTracks.fromJson(
      rawResponse['recenttracks'],
    );
  }

  @override
  doRequest(int limit, int page) async {
    final requestStartTime = DateTime.now();
    final tracks = (await _doRecentTracksRequest(limit, page)).tracks;

    // For some reason, this endpoint always returns the currently-playing
    // song regardless of which page you request.
    // We only want to include this result if we're on the first page,
    // [includeCurrentScrobble] is true, and the time period includes now.
    if (tracks.isEmpty || tracks.first.date != null) return tracks;
    // At this point, we know that the first result is currently playing.
    if (page != 1 || !includeCurrentScrobble) return tracks.sublist(1);
    if ((from == null || !from!.isAfter(requestStartTime)) &&
        (to == null || !to!.isBefore(requestStartTime))) {
      return tracks;
    }
    return tracks.sublist(1);
  }

  Future<int> getNumItems() async =>
      (await _doRecentTracksRequest(1, 1)).attr.total;

  @override
  String toString() =>
      'GetRecentTracksRequest(user=$username, '
      'from=${from?.secondsSinceEpoch}, to=${to?.secondsSinceEpoch}, '
      'extended=$extended)';
}

class GetTopArtistsRequest
    extends PeriodPagedRequest<LTopArtistsResponseArtist> {
  GetTopArtistsRequest(super.username, super.period);

  @override
  doPeriodRequest(Period period, int limit, int page) async {
    final rawResponse = await _doRequest('user.getTopArtists', {
      'user': username,
      'limit': limit,
      'page': page,
      'period': period.value,
    });
    return LTopArtistsResponseTopArtists.fromJson(rawResponse['topartists']);
  }

  @override
  String groupBy(LRecentTracksResponseTrack track) => track.artistName;

  @override
  Future<LTopArtistsResponseArtist> map(
    MapEntry<String, List<LRecentTracksResponseTrack>> entry,
  ) => Future.value(
    LTopArtistsResponseArtist(
      entry.key,
      entry.value.first.artist.url!,
      entry.value.length,
    ),
  );
}

class GetTopAlbumsRequest extends PeriodPagedRequest<LTopAlbumsResponseAlbum> {
  GetTopAlbumsRequest(super.username, super.period);

  @override
  doPeriodRequest(Period period, int limit, int page) async {
    final rawResponse = await _doRequest('user.getTopAlbums', {
      'user': username,
      'limit': limit,
      'page': page,
      'period': period.value,
    });
    return LTopAlbumsResponseTopAlbums.fromJson(rawResponse['topalbums']);
  }

  @override
  String groupBy(LRecentTracksResponseTrack track) => track.albumName;

  @override
  Future<LTopAlbumsResponseAlbum> map(
    MapEntry<String, List<LRecentTracksResponseTrack>> entry,
  ) async {
    final basicAlbum = ConcreteBasicAlbum(
      entry.key,
      ConcreteBasicArtist(entry.value.first.artist.name),
    );
    final fullAlbum = await Lastfm.getAlbum(basicAlbum);

    return LTopAlbumsResponseAlbum(
      fullAlbum.name,
      fullAlbum.url,
      entry.value.length,
      LTopAlbumsResponseAlbumArtist(
        fullAlbum.artist.name,
        fullAlbum.artist.url,
      ),
      fullAlbum.imageId,
    );
  }
}

class GetTopTracksRequest extends PeriodPagedRequest<LTopTracksResponseTrack> {
  GetTopTracksRequest(super.username, super.period);

  @override
  doPeriodRequest(Period period, int limit, int page) async {
    final rawResponse = await _doRequest('user.getTopTracks', {
      'user': username,
      'limit': limit,
      'page': page,
      'period': period.value,
    });
    return LTopTracksResponseTopTracks.fromJson(rawResponse['toptracks']);
  }

  @override
  String groupBy(LRecentTracksResponseTrack track) => track.name;

  @override
  Future<LTopTracksResponseTrack> map(
    MapEntry<String, List<LRecentTracksResponseTrack>> entry,
  ) => Future.value(
    LTopTracksResponseTrack(
      entry.key,
      entry.value.first.url,
      LTrackArtist(
        entry.value.first.artist.nameString!,
        entry.value.first.artist.url!,
      ),
      entry.value.length,
    ),
  );
}

class GetFriendsRequest extends PagedRequest<LUser> {
  final String username;

  const GetFriendsRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('user.getFriends', {
      'user': username,
      'limit': limit,
      'page': page,
    });
    return LUserFriendsResponse.fromJson(rawResponse['friends']).friends;
  }

  @override
  String toString() => 'GetFriendsRequest(user=$username)';
}

class LSearchTracksRequest extends PagedRequest<LTrackMatch> {
  final String query;

  const LSearchTracksRequest(this.query);

  @override
  Future<List<LTrackMatch>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('track.search', {
      'track': query,
      'limit': limit,
      'page': page,
    });
    return LTrackSearchResponse.fromJson(
      rawResponse['results']['trackmatches'],
    ).tracks;
  }

  @override
  String toString() => 'LSearchTracksRequest(track=$query)';
}

class LSearchArtistsRequest extends PagedRequest<LArtistMatch> {
  final String query;

  const LSearchArtistsRequest(this.query);

  @override
  Future<List<LArtistMatch>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('artist.search', {
      'artist': query,
      'limit': limit,
      'page': page,
    });
    return LArtistSearchResponse.fromJson(
      rawResponse['results']['artistmatches'],
    ).artists;
  }

  @override
  String toString() => 'LSearchArtistsRequest(artist=$query)';
}

class LSearchAlbumsRequest extends PagedRequest<LAlbumMatch> {
  final String query;

  const LSearchAlbumsRequest(this.query);

  @override
  Future<List<LAlbumMatch>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('album.search', {
      'album': query,
      'limit': limit,
      'page': page,
    });
    return LAlbumSearchResponse.fromJson(
      rawResponse['results']['albummatches'],
    ).albums;
  }

  @override
  String toString() => 'LSearchAlbumsRequest(album=$query)';
}

class ArtistGetTopAlbumsRequest extends PagedRequest<LArtistTopAlbum> {
  final String artist;

  const ArtistGetTopAlbumsRequest(this.artist);

  @override
  Future<List<LArtistTopAlbum>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('artist.getTopAlbums', {
      'artist': artist,
      'limit': limit,
      'page': page,
    });
    return LArtistGetTopAlbumsResponse.fromJson(
      rawResponse['topalbums'],
    ).albums;
  }

  @override
  String toString() => 'ArtistGetTopAlbumsRequest(artist=$artist)';
}

class ArtistGetTopTracksRequest extends PagedRequest<LArtistTopTrack> {
  final String artist;

  const ArtistGetTopTracksRequest(this.artist);

  @override
  Future<List<LArtistTopTrack>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('artist.getTopTracks', {
      'artist': artist,
      'limit': limit,
      'page': page,
    });
    return LArtistGetTopTracksResponse.fromJson(
      rawResponse['toptracks'],
    ).tracks;
  }

  @override
  String toString() => 'ArtistGetTopTracksRequest(artist=$artist)';
}

class UserGetTrackScrobblesRequest extends PagedRequest<LUserTrackScrobble> {
  final LTrack track;
  final String? username;

  const UserGetTrackScrobblesRequest(this.track, [this.username]);

  @override
  Future<List<LUserTrackScrobble>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('user.getTrackScrobbles', {
      'track': track.name,
      'artist': track.artistName,
      'user': username ?? Preferences.name.value,
      'limit': limit,
      'page': page,
      'sk': Preferences.key.value,
    });
    return LUserTrackScrobblesResponse.fromJson(
      rawResponse['trackscrobbles'],
    ).tracks;
  }

  @override
  String toString() =>
      'UserGetTrackScrobblesRequest(track=${track.name}, '
      'artist=${track.artistName}, user=${username ?? Preferences.name.value})';
}

class UserGetLovedTracksRequest extends PagedRequest<LUserLovedTrack> {
  final String? username;

  const UserGetLovedTracksRequest([this.username]);

  @override
  Future<List<LUserLovedTrack>> doRequest(int limit, int page) async {
    final rawResponse = await _doRequest('user.getLovedTracks', {
      'user': username ?? Preferences.name.value,
      'limit': limit,
      'page': page,
    });
    return LUserLovedTracksResponse.fromJson(rawResponse['lovedtracks']).tracks;
  }

  @override
  String toString() =>
      'UserGetLovedTracksRequest(user=${username ?? Preferences.name.value})';
}

class Lastfm {
  static final applicationSettingsUri = Uri.https(
    'last.fm',
    'settings/applications',
  );

  static final authorizationUri = Uri.https('last.fm', 'api/auth', {
    'api_key': apiKey,
    'cb': authCallbackUrl,
  });

  static Future<LAuthenticationResponseSession> authenticate(
    String token, {
    bool libre = false,
  }) async {
    final rawResponse = await _doRequest(
      'auth.getSession',
      {'token': token},
      post: true,
      libre: libre,
    );
    return LAuthenticationResponseSession.fromJson(rawResponse['session']);
  }

  static Future<LUser> getUser(String username) async {
    final rawResponse = await _doRequest('user.getInfo', {'user': username});
    return LUser.fromJson(rawResponse['user']);
  }

  static Future<LTrack> getTrack(Track track, {String? username}) async {
    final rawResponse = await _doRequest('track.getInfo', {
      'track': track.name,
      'artist': track.artistName,
      'username': username ?? Preferences.name.value,
    });
    return LTrack.fromJson(rawResponse['track']);
  }

  static Future<LAlbum> getAlbum(BasicAlbum album, {String? username}) async {
    final rawResponse = await _doRequest('album.getInfo', {
      'album': album.name,
      'artist': album.artist.name,
      'username': username ?? Preferences.name.value,
    });
    return LAlbum.fromJson(rawResponse['album']);
  }

  static Future<LArtist> getArtist(
    BasicArtist artist, {
    String? username,
  }) async {
    final rawResponse = await _doRequest('artist.getInfo', {
      'artist': artist.name,
      'username': username ?? Preferences.name.value,
    });
    return LArtist.fromJson(rawResponse['artist']);
  }

  static Future<List<LSimilarArtist>> getSimilarArtists(
    BasicArtist artist, {
    int limit = 20,
  }) async {
    final rawResponse = await _doRequest('artist.getSimilar', {
      'artist': artist.name,
      'limit': limit,
    });
    return LSimilarArtistsResponse.fromJson(
      rawResponse['similarartists'],
    ).artists;
  }

  static Future<LUserWeeklyChartList> getWeeklyChartList(LUser user) async {
    final rawResponse = await _doRequest('user.getWeeklyChartList', {
      'user': user.name,
    });
    return LUserWeeklyChartList.fromJson(rawResponse['weeklychartlist']);
  }

  static Future<LUserWeeklyTrackChart> getWeeklyTrackChart(
    LUser user,
    LUserWeeklyChart chart,
  ) async {
    final rawResponse = await _doRequest('user.getWeeklyTrackChart', {
      'user': user.name,
      'from': chart.from,
      'to': chart.to,
    });
    return LUserWeeklyTrackChart.fromJson(rawResponse['weeklytrackchart']);
  }

  static Future<LUserWeeklyAlbumChart> getWeeklyAlbumChart(
    LUser user,
    LUserWeeklyChart chart,
  ) async {
    final rawResponse = await _doRequest('user.getWeeklyAlbumChart', {
      'user': user.name,
      'from': chart.from,
      'to': chart.to,
    });
    return LUserWeeklyAlbumChart.fromJson(rawResponse['weeklyalbumchart']);
  }

  static Future<LUserWeeklyArtistChart> getWeeklyArtistChart(
    LUser user,
    LUserWeeklyChart chart,
  ) async {
    final rawResponse = await _doRequest('user.getWeeklyArtistChart', {
      'user': user.name,
      'from': chart.from,
      'to': chart.to,
    });
    return LUserWeeklyArtistChart.fromJson(rawResponse['weeklyartistchart']);
  }

  static Future<List<LTopArtistsResponseArtist>> getGlobalTopArtists(
    int limit,
  ) async {
    final rawResponse = await _doRequest('chart.getTopArtists', {
      'limit': limit,
      'page': 1,
    });
    return LChartTopArtists.fromJson(rawResponse['artists']).artists;
  }

  static Future<LScrobbleResponseScrobblesAttr> scrobble(
    List<Track> tracks,
    List<DateTime> timestamps,
  ) async {
    assert(timestamps.length - tracks.length <= 1);

    var accepted = 0;
    var ignored = 0;

    final zip = IterableZip([
      tracks.splitBeforeIndexed((i, _) => i % 50 == 0),
      timestamps.splitBeforeIndexed((i, _) => i % 50 == 0),
    ]);

    for (var entry in zip) {
      final response = await _scrobble(
        entry[0] as List<Track>,
        entry[1] as List<DateTime>,
      );
      accepted += response.accepted;
      ignored += response.ignored;
    }

    return LScrobbleResponseScrobblesAttr(accepted, ignored);
  }

  static Future<LScrobbleResponseScrobblesAttr> _scrobble(
    List<Track> tracks,
    List<DateTime> timestamps,
  ) async {
    assert(tracks.length <= 50);
    assert(timestamps.length <= 50);
    final data = <String, dynamic>{};

    tracks.asMap().forEach((i, track) {
      if (track.albumName?.isNotEmpty ?? false) {
        data['album[$i]'] = track.albumName;
      }

      if (track.albumArtist?.isNotEmpty ?? false) {
        data['albumArtist[$i]'] = track.albumArtist;
      }

      data['artist[$i]'] = track.artistName;
      data['track[$i]'] = track.name;
      data['timestamp[$i]'] = timestamps[i].millisecondsSinceEpoch ~/ 1000;
    });

    if (Preferences.libreEnabled.value) {
      await _doRequest(
        'track.scrobble',
        {...data, 'sk': Preferences.libreKey.value},
        post: true,
        libre: true,
      );
    }

    final rawResponse = await _doRequest('track.scrobble', {
      ...data,
      'sk': Preferences.key.value,
    }, post: true);
    return LScrobbleResponseScrobblesAttr.fromJson(
      rawResponse['scrobbles']['@attr'],
    );
  }

  /// Loves or unloves a track. If [love] is true, the track will be loved;
  /// otherwise, it will be unloved.
  static Future<bool> love(Track track, bool love) async {
    if (track.artistName == null) {
      return false;
    }

    await _doRequest(love ? 'track.love' : 'track.unlove', {
      'track': track.name,
      'artist': track.artistName,
      'sk': Preferences.key.value,
    }, post: true);
    return true;
  }
}
