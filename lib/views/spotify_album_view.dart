// @dart=2.9

import 'dart:math';

import 'package:finale/components/app_bar_component.dart';
import 'package:finale/components/display_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/loading_component.dart';
import 'package:finale/constants.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/views/error_view.dart';
import 'package:finale/views/scrobble_album_view.dart';
import 'package:finale/views/scrobble_view.dart';
import 'package:finale/views/spotify_artist_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SpotifyAlbumView extends StatelessWidget {
  final SAlbumSimple album;

  SpotifyAlbumView({@required this.album});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SAlbumFull>(
      future: Spotify.getFullAlbum(album),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(error: snapshot.error);
        } else if (!snapshot.hasData) {
          return LoadingComponent();
        }

        final album = snapshot.data;

        return Scaffold(
            appBar: createAppBar(
              album.name,
              subtitle: album.artist.name,
              backgroundColor: spotifyGreen,
              actions: [
                if (album.canScrobble)
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        final result = await showBarModalBottomSheet<bool>(
                            context: context,
                            duration: Duration(milliseconds: 200),
                            builder: (context) =>
                                ScrobbleAlbumView(album: album));

                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(result
                                  ? 'Scrobbled successfully!'
                                  : 'An error occurred while scrobbling')));
                        }
                      },
                    ),
                  )
              ],
            ),
            body: ListView(
              children: [
                Center(
                    child: ImageComponent(
                        displayable: album,
                        fit: BoxFit.cover,
                        width: min(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height / 2))),
                SizedBox(height: 10),
                if (album.artist != null)
                  ListTile(
                      leading: ImageComponent(displayable: album.artist),
                      title: Text(album.artist.name),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SpotifyArtistView(artist: album.artist)));
                      }),
                if (album.tracks.isNotEmpty) Divider(),
                if (album.tracks.isNotEmpty)
                  DisplayComponent<SAlbumTrack>(
                    items: album.tracks,
                    scrollable: false,
                    displayNumbers: true,
                    displayImages: false,
                    secondaryAction: (track) async {
                      await showBarModalBottomSheet(
                          context: context,
                          duration: Duration(milliseconds: 200),
                          builder: (context) =>
                              ScrobbleView(track: track, isModal: true));
                    },
                  ),
              ],
            ));
      },
    );
  }
}
