import 'package:finale/services/apple_music/album.dart';
import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/services/apple_music/song.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/error_view.dart';
import 'package:finale/widgets/base/loading_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/apple_music/apple_music_artist_view.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/scrobble/scrobble_button.dart';
import 'package:flutter/material.dart';

class AppleMusicAlbumView extends StatelessWidget {
  final AMAlbum album;

  const AppleMusicAlbumView({required this.album});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AMFullAlbum>(
      future: AppleMusic.getFullAlbum(album),
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            error: snapshot.error!,
            stackTrace: snapshot.stackTrace!,
            entity: this.album,
          );
        } else if (!snapshot.hasData) {
          return LoadingView();
        }

        final album = snapshot.data!;

        return Scaffold(
          appBar: createAppBar(
            album.name,
            subtitle: album.artist.name,
            backgroundColor: appleMusicPink,
            actions: [
              if (album.canScrobble) ScrobbleButton(entity: album),
            ],
          ),
          body: TwoUp(
            image: EntityImage(entity: album),
            listItems: [
              ListTile(
                leading: EntityImage(entity: album.artist),
                title: Text(album.artist.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            AppleMusicArtistView(artistId: album.artistId)),
                  );
                },
              ),
              if (album.tracks.isNotEmpty) ...[
                const Divider(),
                EntityDisplay<AMSong>(
                  items: album.tracks,
                  scrollable: false,
                  displayNumbers: true,
                  displayImages: false,
                  scrobbleableEntity: (track) async => track,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
