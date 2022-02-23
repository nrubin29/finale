import 'dart:typed_data';

import 'package:finale/services/generic.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

class AMArtist extends BasicArtist {
  final Artist _artist;

  AMArtist(this._artist);

  @override
  String get name => _artist.name;

  @override
  String? get url => null;

  @override
  Uint8List? get imageData => _artist.artwork;
}