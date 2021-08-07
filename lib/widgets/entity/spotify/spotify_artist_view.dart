import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/error_component.dart';
import 'package:finale/widgets/base/error_view.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/base/loading_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/entity/spotify/spotify_album_view.dart';
import 'package:flutter/material.dart';

class SpotifyArtistView extends StatefulWidget {
  final dynamic /* SArtist|SArtistSimple */ artist;

  SpotifyArtistView({required this.artist})
      : assert(artist is SArtist || artist is SArtistSimple);

  @override
  State<StatefulWidget> createState() => _SpotifyArtistViewState();
}

class _SpotifyArtistViewState extends State<SpotifyArtistView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SArtist>(
      future: widget.artist is SArtist
          ? Future.value(widget.artist)
          : Spotify.getFullArtist(widget.artist),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            error: snapshot.error!,
            stackTrace: snapshot.stackTrace!,
            entity: widget.artist,
          );
        } else if (!snapshot.hasData) {
          return LoadingView();
        }

        final artist = snapshot.data!;

        return Scaffold(
            appBar: createAppBar(
              artist.name,
              backgroundColor: spotifyGreen,
            ),
            body: TwoUp(
              image: EntityImage(entity: artist),
              listItems: [
                TabBar(
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.red,
                    controller: _tabController,
                    tabs: [
                      Tab(icon: Icon(Icons.album)),
                      Tab(icon: Icon(Icons.audiotrack)),
                    ],
                    onTap: (index) {
                      setState(() {
                        selectedIndex = index;
                        _tabController.animateTo(index);
                      });
                    }),
                IndexedStack(index: selectedIndex, children: [
                  Visibility(
                    visible: selectedIndex == 0,
                    maintainState: true,
                    child: EntityDisplay<SAlbumSimple>(
                        scrollable: false,
                        request: SArtistAlbumsRequest(artist),
                        detailWidgetBuilder: (album) =>
                            SpotifyAlbumView(album: album)),
                  ),
                  Visibility(
                    visible: selectedIndex == 1,
                    maintainState: true,
                    child: FutureBuilder<List<STrack>>(
                        future: Spotify.getTopTracksForArtist(artist),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return ErrorComponent(
                              error: snapshot.error!,
                              stackTrace: snapshot.stackTrace!,
                              entity: artist,
                            );
                          } else if (!snapshot.hasData) {
                            return LoadingComponent();
                          }

                          return EntityDisplay<STrack>(
                            scrollable: false,
                            items: snapshot.data,
                            scrobbleableEntity: (track) => track,
                          );
                        }),
                  ),
                ])
              ],
            ));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
