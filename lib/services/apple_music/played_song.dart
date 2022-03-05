import 'dart:typed_data';

import 'package:finale/services/lastfm/common.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

class AMPlayedSong extends BasicScrobbledTrack {
  final PlayedSong _playedSong;

  AMPlayedSong(this._playedSong);

  @override
  DateTime get date => _playedSong.lastPlayedDate;

  @override
  String? get albumName => _playedSong.album;

  @override
  String? get artistName => _playedSong.artist;

  @override
  String get name => _playedSong.title;

  @override
  Uint8List? get imageData => _playedSong.artwork;

  @override
  String? get url => null;
}
