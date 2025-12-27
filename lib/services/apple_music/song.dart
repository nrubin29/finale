import 'package:finale/services/generic.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

class AMSong extends ScrobbleableTrack {
  final Song _song;

  AMSong(this._song);

  @override
  String? get albumName => _song.album;

  @override
  String? get artistName => _song.artist;

  @override
  String? get albumArtist => _song.albumArtist;

  @override
  String get name => _song.title;

  @override
  int get duration => _song.playbackDuration.toInt();

  @override
  late final imageProvider = .data(_song.artwork);

  @override
  String? get url => null;
}
