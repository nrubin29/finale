import 'package:collection/collection.dart';
import 'package:finale/services/apple_music/album.dart';
import 'package:finale/services/apple_music/artist.dart';
import 'package:finale/services/apple_music/played_song.dart';
import 'package:finale/services/apple_music/playlist.dart';
import 'package:finale/services/apple_music/song.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

export 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart'
    show AuthorizationStatus;

class AMSearchSongsRequest extends PagedRequest<AMSong> {
  final String? query;
  final AMArtist? artist;

  const AMSearchSongsRequest(this.query) : assert(query != null), artist = null;

  const AMSearchSongsRequest.forArtist(this.artist)
    : assert(artist != null),
      query = null;

  @override
  Future<List<AMSong>> doRequest(int limit, int page) async =>
      (await FlutterMPMediaPlayer.searchSongs(
        query: query,
        artistId: artist?.id,
        limit: limit,
        page: page,
      )).map(AMSong.new).toList(growable: false);

  @override
  String toString() => 'AMSearchSongsRequest(query=$query, artist=$artist)';
}

class AMSearchAlbumsRequest extends PagedRequest<AMAlbum> {
  final String? query;
  final AMArtist? artist;

  const AMSearchAlbumsRequest(this.query)
    : assert(query != null),
      artist = null;

  const AMSearchAlbumsRequest.forArtist(this.artist)
    : assert(artist != null),
      query = null;

  @override
  Future<List<AMAlbum>> doRequest(int limit, int page) async =>
      (await FlutterMPMediaPlayer.searchAlbums(
        query: query,
        artistId: artist?.id,
        limit: limit,
        page: page,
      )).map(AMAlbum.new).toList(growable: false);

  @override
  String toString() => 'AMSearchAlbumsRequest(query=$query, artist=$artist)';
}

class AMSearchArtistsRequest extends PagedRequest<AMArtist> {
  final String query;

  const AMSearchArtistsRequest(this.query);

  @override
  Future<List<AMArtist>> doRequest(int limit, int page) async =>
      (await FlutterMPMediaPlayer.searchArtists(
        query,
        limit,
        page,
      )).map(AMArtist.new).toList(growable: false);

  @override
  String toString() => 'AMSearchArtistsRequest(query=$query)';
}

class AMSearchPlaylistsRequest extends PagedRequest<AMPlaylist> {
  final String query;

  const AMSearchPlaylistsRequest(this.query);

  @override
  Future<List<AMPlaylist>> doRequest(int limit, int page) async =>
      (await FlutterMPMediaPlayer.searchPlaylists(
        query,
        limit,
        page,
      )).map(AMPlaylist.new).toList(growable: false);

  @override
  String toString() => 'AMSearchPlaylistsRequest(query=$query)';
}

class AMRecentTracksRequest extends PagedRequest<AMPlayedSong> {
  const AMRecentTracksRequest() : super(limitForAllDataRequest: 20);

  @override
  Future<List<AMPlayedSong>> doRequest(int limit, int page) async {
    var after = DateTime.now().subtract(const Duration(days: 14));
    final last = Preferences.lastAppleMusicScrobble.value;
    if (last != null && last.isAfter(after)) {
      after = last;
    }

    return (await FlutterMPMediaPlayer.getRecentTracks(
      after: after,
      limit: limit,
      page: page,
    )).map(AMPlayedSong.new).toList(growable: false);
  }

  @override
  String toString() => 'AMRecentTracksRequest()';
}

class AMPlaylistSongsRequest extends PagedRequest<AMSong> {
  final String playlistId;

  const AMPlaylistSongsRequest(this.playlistId);

  @override
  Future<List<AMSong>> doRequest(int limit, int page) async =>
      (await FlutterMPMediaPlayer.getPlaylistSongs(
        playlistId,
        limit,
        page,
      )).map(AMSong.new).toList(growable: false);

  @override
  String toString() => 'AMPlaylistSongsRequest(playlistId=$playlistId)';
}

class AppleMusic {
  const AppleMusic._();

  static Future<AuthorizationStatus> authorize() =>
      FlutterMPMediaPlayer.authorize();

  static Future<AuthorizationStatus> get authorizationStatus =>
      FlutterMPMediaPlayer.authorizationStatus;

  static Future<AMFullAlbum> getFullAlbum(AMAlbum album) async =>
      AMFullAlbum(await FlutterMPMediaPlayer.getAlbum(album.id));

  static Future<AMArtist> getArtist(String artistId) async =>
      AMArtist(await FlutterMPMediaPlayer.getArtist(artistId));

  static Future<bool> scrobble(List<AMPlayedSong> songs) async {
    final response = await Lastfm.scrobble(
      songs,
      songs.map((track) => track.date).toList(growable: false),
    );
    final success = response.ignored == 0;

    if (success && songs.isNotEmpty) {
      Preferences.lastAppleMusicScrobble.value = maxBy(
        songs,
        (song) => song.date,
      )!.date;
    }

    return success;
  }
}
