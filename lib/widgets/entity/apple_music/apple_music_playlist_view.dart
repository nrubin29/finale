import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/services/apple_music/playlist.dart';
import 'package:finale/services/apple_music/song.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/scrobble/scrobble_button.dart';
import 'package:flutter/material.dart';

class AppleMusicPlaylistView extends StatelessWidget {
  final AMPlaylist playlist;

  const AppleMusicPlaylistView({required this.playlist});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(
      context,
      playlist.displayTitle,
      backgroundColor: appleMusicPink,
      actions: [
        ScrobbleButton(entityProvider: () => AMFullPlaylist.get(playlist)),
      ],
    ),
    body: EntityDisplay<AMSong>(
      request: AMPlaylistSongsRequest(playlist.id),
      scrobbleableEntity: (track) async => track,
    ),
  );
}
