import 'dart:typed_data';

import 'package:finale/services/generic.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

class AMAlbum extends BasicAlbum {
  final Album _album;

  AMAlbum(this._album);

  @override
  String get name => _album.title;

  @override
  BasicArtist get artist => ConcreteBasicArtist(_album.artist);

  @override
  String? get url => null;

  @override
  Uint8List? get imageData => _album.artwork;
}
