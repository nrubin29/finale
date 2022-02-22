import 'package:finale/services/generic.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

class AMSong extends Track {
  final Song _song;

  AMSong(this._song);

  @override
  String? get albumName => _song.album;

  @override
  String? get artistName => _song.artist;

  @override
  String get name => _song.title;

  @override
  String? get url => null;
}
