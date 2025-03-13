import 'dart:typed_data';

import 'package:finale/services/apple_music/song.dart';
import 'package:finale/services/generic.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart' as mp;

class AMAlbum extends BasicAlbum {
  final mp.Album _album;

  AMAlbum(this._album);

  String get id => _album.id;

  @override
  String get name => _album.title;

  @override
  BasicArtist get artist => ConcreteBasicArtist(_album.artist);

  @override
  String? get url => null;

  @override
  Uint8List? get imageData => _album.artwork;
}

class AMFullAlbum extends FullAlbum {
  final mp.FullAlbum _album;

  @override
  List<AMSong> tracks;

  AMFullAlbum(this._album)
    : tracks = _album.tracks.map(AMSong.new).toList(growable: false);

  String get artistId => _album.artistId;

  @override
  String get name => _album.title;

  @override
  BasicArtist get artist => ConcreteBasicArtist(_album.artist);

  @override
  String? get url => null;

  @override
  Uint8List? get imageData => _album.artwork;
}
