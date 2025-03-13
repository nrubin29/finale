import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/services/apple_music/song.dart';
import 'package:finale/services/generic.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

class AMPlaylist extends BasicPlaylist {
  final Playlist _playlist;

  AMPlaylist(this._playlist);

  String get id => _playlist.id;

  @override
  String get displayTitle => _playlist.title;

  @override
  String? get url => null;
}

class AMFullPlaylist extends FullPlaylist {
  final AMPlaylist _playlist;

  @override
  final List<AMSong> tracks;

  AMFullPlaylist._(this._playlist, this.tracks);

  static Future<AMFullPlaylist> get(AMPlaylist playlist) async =>
      AMFullPlaylist._(
        playlist,
        await AMPlaylistSongsRequest(playlist.id).getAllData(),
      );

  @override
  String get displayTitle => _playlist.displayTitle;

  @override
  String? get url => null;
}
