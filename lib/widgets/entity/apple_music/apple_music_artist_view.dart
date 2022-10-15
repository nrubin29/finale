import 'package:finale/services/apple_music/album.dart';
import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/services/apple_music/artist.dart';
import 'package:finale/services/apple_music/song.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/future_builder_view.dart';
import 'package:finale/widgets/entity/apple_music/apple_music_album_view.dart';
import 'package:finale/widgets/entity/artist_tabs.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_two_up.dart';
import 'package:flutter/material.dart';

class AppleMusicArtistView extends StatelessWidget {
  final String artistId;

  const AppleMusicArtistView({required this.artistId});

  @override
  Widget build(BuildContext context) => FutureBuilderView<AMArtist>(
        futureFactory: () => AppleMusic.getArtist(artistId),
        baseEntity: artistId,
        builder: (artist) => Scaffold(
          appBar: createAppBar(
            artist.name,
            backgroundColor: appleMusicPink,
          ),
          body: EntityTwoUp(
            entity: artist,
            listItems: [
              ArtistTabs(
                color: appleMusicPink,
                albumsWidget: EntityDisplay<AMAlbum>(
                  scrollable: false,
                  request: AMSearchAlbumsRequest.forArtist(artist),
                  detailWidgetBuilder: (album) =>
                      AppleMusicAlbumView(album: album),
                ),
                tracksWidget: EntityDisplay<AMSong>(
                  scrollable: false,
                  request: AMSearchSongsRequest.forArtist(artist),
                  scrobbleableEntity: (track) async => track,
                ),
              ),
            ],
          ),
        ),
      );
}
