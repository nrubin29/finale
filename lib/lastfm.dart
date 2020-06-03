import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplescrobble/env.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lalbum.dart';
import 'package:simplescrobble/types/lartist.dart';
import 'package:simplescrobble/types/lcommon.dart';
import 'package:simplescrobble/types/ltrack.dart';
import 'package:simplescrobble/types/luser.dart';

String _base = 'https://ws.audioscrobbler.com/2.0/';

String _encode(String str) {
  return Uri.encodeComponent(str).replaceAll(r'%20', '+');
}

String _buildURL(String method,
    {Map<String, dynamic> data = const {}, List<String> encode = const []}) {
  final allData = {
    ...data,
    ...{'api_key': apiKey, 'method': method}
  };
  var allDataKeys = allData.keys.toList();
  allDataKeys.sort();

  final hash =
      allDataKeys.map((key) => '$key${allData[key]}').join() + apiSecret;
  final signature = md5.convert(utf8.encode(hash));
  allData['api_sig'] = signature.toString();

  allDataKeys = allData.keys.toList();
  allDataKeys.sort();
  return _base +
      '?format=json&' +
      allDataKeys
          .map((key) =>
              key +
              '=' +
              (encode.indexOf(key.replaceAll(r'\[\d+]', '')) != -1
                      ? _encode(allData[key])
                      : allData[key])
                  .toString())
          .join('&');
}

abstract class PagedLastfmRequest<T> {
  Future<List<T>> doRequest(int limit, int page);
}

class GetRecentTracksRequest
    extends PagedLastfmRequest<LRecentTracksResponseTrack> {
  String username;

  GetRecentTracksRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    if (username == null) {
      username = (await SharedPreferences.getInstance()).getString('name');
    }

    final response = await http.get(_buildURL('user.getRecentTracks',
        data: {'user': username, 'page': page}, encode: ['user']));

    if (response.statusCode == 200) {
      return LRecentTracksResponseRecentTracks.fromJson(
              json.decode(response.body)['recenttracks'])
          .tracks;
    } else {
      throw Exception('Could not get recent tracks.');
    }
  }
}

class GetTopArtistsRequest
    extends PagedLastfmRequest<LTopArtistsResponseArtist> {
  String username;

  GetTopArtistsRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    if (username == null) {
      username = (await SharedPreferences.getInstance()).getString('name');
    }

    final response = await http.get(_buildURL('user.getTopArtists',
        data: {'user': username, 'page': page, 'period': '7day'},
        encode: ['user', 'period']));

    if (response.statusCode == 200) {
      return LTopArtistsResponseTopArtists.fromJson(
              json.decode(response.body)['topartists'])
          .artists;
    } else {
      throw Exception('Could not get top artists.');
    }
  }
}

class GetTopAlbumsRequest extends PagedLastfmRequest<LTopAlbumsResponseAlbum> {
  String username;

  GetTopAlbumsRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    if (username == null) {
      username = (await SharedPreferences.getInstance()).getString('name');
    }

    final response = await http.get(_buildURL('user.getTopAlbums',
        data: {'user': username, 'page': page, 'period': '7day'},
        encode: ['user', 'period']));

    if (response.statusCode == 200) {
      return LTopAlbumsResponseTopAlbums.fromJson(
              json.decode(response.body)['topalbums'])
          .albums;
    } else {
      throw Exception('Could not get top albums.');
    }
  }
}

class GetTopTracksRequest extends PagedLastfmRequest<LTopTracksResponseTrack> {
  String username;

  GetTopTracksRequest(this.username);

  @override
  doRequest(int limit, int page) async {
    if (username == null) {
      username = (await SharedPreferences.getInstance()).getString('name');
    }

    final response = await http.get(_buildURL('user.getTopTracks',
        data: {'user': username, 'page': page, 'period': '7day'},
        encode: ['user', 'period']));

    if (response.statusCode == 200) {
      return LTopTracksResponseTopTracks.fromJson(
              json.decode(response.body)['toptracks'])
          .tracks;
    } else {
      throw Exception('Could not get top tracks.');
    }
  }
}

class SearchTracksRequest extends PagedLastfmRequest<LTrackMatch> {
  String query;

  SearchTracksRequest(this.query);

  @override
  Future<List<LTrackMatch>> doRequest(int limit, int page) async {
    final response = await http.get(_buildURL('track.search',
        data: {'track': query, 'limit': limit, 'page': page},
        encode: ['track']));

    if (response.statusCode == 200) {
      return LTrackSearchResponse.fromJson(
              json.decode(response.body)['results']['trackmatches'])
          .tracks;
    } else {
      throw Exception('Could not search for tracks.');
    }
  }
}

class SearchArtistsRequest extends PagedLastfmRequest<LArtistMatch> {
  String query;

  SearchArtistsRequest(this.query);

  @override
  Future<List<LArtistMatch>> doRequest(int limit, int page) async {
    final response = await http.get(_buildURL('artist.search',
        data: {'artist': query, 'limit': limit, 'page': page},
        encode: ['artist']));

    if (response.statusCode == 200) {
      return LArtistSearchResponse.fromJson(
              json.decode(response.body)['results']['artistmatches'])
          .artists;
    } else {
      throw Exception('Could not search for artists.');
    }
  }
}

class SearchAlbumsRequest extends PagedLastfmRequest<LAlbumMatch> {
  String query;

  SearchAlbumsRequest(this.query);

  @override
  Future<List<LAlbumMatch>> doRequest(int limit, int page) async {
    final response = await http.get(_buildURL('album.search',
        data: {'album': query, 'limit': limit, 'page': page},
        encode: ['album']));

    if (response.statusCode == 200) {
      return LAlbumSearchResponse.fromJson(
              json.decode(response.body)['results']['albummatches'])
          .albums;
    } else {
      throw Exception('Could not search for albums.');
    }
  }
}

class ArtistGetTopAlbumsRequest extends PagedLastfmRequest<LArtistTopAlbum> {
  String artist;

  ArtistGetTopAlbumsRequest(this.artist);

  @override
  Future<List<LArtistTopAlbum>> doRequest(int limit, int page) async {
    final response = await http.get(_buildURL('artist.getTopAlbums',
        data: {'artist': artist, 'limit': limit, 'page': page},
        encode: ['artist']));

    if (response.statusCode == 200) {
      return LArtistGetTopAlbumsResponse.fromJson(
              json.decode(response.body)['topalbums'])
          .albums;
    } else {
      throw Exception('Could not get artist\'s top albums.');
    }
  }
}

class ArtistGetTopTracksRequest extends PagedLastfmRequest<LArtistTopTrack> {
  String artist;

  ArtistGetTopTracksRequest(this.artist);

  @override
  Future<List<LArtistTopTrack>> doRequest(int limit, int page) async {
    final response = await http.get(_buildURL('artist.getTopTracks',
        data: {'artist': artist, 'limit': limit, 'page': page},
        encode: ['artist']));

    if (response.statusCode == 200) {
      return LArtistGetTopTracksResponse.fromJson(
              json.decode(response.body)['toptracks'])
          .tracks;
    } else {
      throw Exception('Could not get artist\'s top tracks.');
    }
  }
}

class Lastfm {
  static Future<LAuthenticationResponseSession> authenticate(
      String token) async {
    final response =
        await http.post(_buildURL('auth.getSession', data: {'token': token}));

    if (response.statusCode == 200) {
      return LAuthenticationResponseSession.fromJson(
          json.decode(response.body)['session']);
    } else {
      throw Exception('Could not authenticate.');
    }
  }

  static Future<LUser> getUser(String username) async {
    final response =
        await http.get(_buildURL('user.getInfo', data: {'user': username}));

    if (response.statusCode == 200) {
      return LUser.fromJson(json.decode(response.body)['user']);
    } else {
      throw Exception('Could not get user.');
    }
  }

  static Future<LTrack> getTrack(BasicTrack track) async {
    final username = (await SharedPreferences.getInstance()).getString('name');

    final response = await http.get(_buildURL('track.getInfo', data: {
      'track': track.name,
      'artist': track.artist,
      'username': username
    }, encode: [
      'track',
      'artist',
      'username'
    ]));

    if (response.statusCode == 200) {
      return LTrack.fromJson(json.decode(response.body)['track']);
    } else {
      throw Exception('Could not get track.');
    }
  }

  static Future<LAlbum> getAlbum(BasicAlbum album) async {
    final username = (await SharedPreferences.getInstance()).getString('name');

    final response = await http.get(_buildURL('album.getInfo', data: {
      'album': album.name,
      'artist': album.artist.name,
      'username': username
    }, encode: [
      'album',
      'artist',
      'username'
    ]));

    if (response.statusCode == 200) {
      return LAlbum.fromJson(json.decode(response.body)['album']);
    } else {
      throw Exception('Could not get album.');
    }
  }

  static Future<LArtist> getArtist(BasicArtist artist) async {
    final username = (await SharedPreferences.getInstance()).getString('name');

    final response = await http.get(_buildURL('artist.getInfo',
        data: {'artist': artist.name, 'username': username},
        encode: ['artist', 'username']));

    if (response.statusCode == 200) {
      return LArtist.fromJson(json.decode(response.body)['artist']);
    } else {
      throw Exception('Could not get artist.');
    }
  }

  static Future<int> getNumArtists(String username) async {
    final response = await http.get(_buildURL('user.getTopArtists', data: {
      'user': username,
      'period': 'overall',
      'limit': '1',
      'page': '1'
    }, encode: [
      'user',
      'period'
    ]));

    if (response.statusCode == 200) {
      return LTopArtistsResponseTopArtists.fromJson(
              json.decode(response.body)['topartists'])
          .attr
          .total;
    } else {
      throw Exception('Could not get num artists.');
    }
  }

  static Future<int> getNumAlbums(String username) async {
    final response = await http.get(_buildURL('user.getTopAlbums', data: {
      'user': username,
      'period': 'overall',
      'limit': '1',
      'page': '1'
    }, encode: [
      'user',
      'period'
    ]));

    if (response.statusCode == 200) {
      return LTopAlbumsResponseTopAlbums.fromJson(
              json.decode(response.body)['topalbums'])
          .attr
          .total;
    } else {
      throw Exception('Could not get num albums.');
    }
  }

  static Future<int> getNumTracks(String username) async {
    final response = await http.get(_buildURL('user.getTopTracks', data: {
      'user': username,
      'period': 'overall',
      'limit': '1',
      'page': '1'
    }, encode: [
      'user',
      'period'
    ]));

    if (response.statusCode == 200) {
      return LTopTracksResponseTopTracks.fromJson(
              json.decode(response.body)['toptracks'])
          .attr
          .total;
    } else {
      throw Exception('Could not get num albums.');
    }
  }

  static Future<List<LTopArtistsResponseArtist>> getGlobalTopArtists(
      int limit) async {
    final response = await http.get(
        _buildURL('chart.getTopArtists', data: {'limit': limit, 'page': 1}));

    if (response.statusCode == 200) {
      return LChartTopArtists.fromJson(json.decode(response.body)['artists'])
          .artists;
    } else {
      throw Exception('Could not get global top artists.');
    }
  }

  static Future<LScrobbleResponseScrobblesAttr> scrobble(
      String track, String artist, String album, DateTime timestamp) async {
    final sk = (await SharedPreferences.getInstance()).getString('key');

    final response = await http.post(_buildURL('track.scrobble', data: {
      'album': album,
      'artist': artist,
      'sk': sk,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
      'track': track
    }, encode: [
      'album',
      'artist',
      'track'
    ]));

    if (response.statusCode == 200) {
      return LScrobbleResponseScrobblesAttr.fromJson(
          json.decode(response.body)['scrobbles']['@attr']);
    } else {
      throw Exception('Could not scrobble.');
    }
  }
}
