import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/error_view.dart';
import 'package:finale/widgets/base/loading_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/entity/spotify/spotify_artist_view.dart';
import 'package:finale/widgets/scrobble/scrobble_button.dart';
import 'package:flutter/material.dart';

class SpotifyAlbumView extends StatelessWidget {
  final SAlbumSimple album;

  const SpotifyAlbumView({required this.album});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SAlbumFull>(
      future: Spotify.getFullAlbum(album),
      builder: (context, snapshot) {
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
              backgroundColor: spotifyGreen,
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
                              builder: (context) =>
                                  SpotifyArtistView(artist: album.artist)));
                    }),
                if (album.tracks.isNotEmpty) ...[
                  const Divider(),
                  EntityDisplay<SAlbumTrack>(
                    items: album.tracks,
                    scrollable: false,
                    displayNumbers: true,
                    displayImages: false,
                    scrobbleableEntity: (track) => Future.value(track),
                  ),
                ],
              ],
            ));
      },
    );
  }
}
