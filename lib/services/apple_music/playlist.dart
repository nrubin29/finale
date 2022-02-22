import 'package:finale/services/generic.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

class AMPlaylist extends BasicPlaylist {
  final Playlist playlist;

  AMPlaylist(this.playlist);

  @override
  String get displayTitle => playlist.title;

  @override
  String? get url => null;
}
