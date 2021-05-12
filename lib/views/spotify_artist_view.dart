// @dart=2.9

import 'dart:math';

import 'package:finale/components/app_bar_component.dart';
import 'package:finale/components/display_component.dart';
import 'package:finale/components/error_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/loading_component.dart';
import 'package:finale/constants.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:finale/views/error_view.dart';
import 'package:finale/views/scrobble_view.dart';
import 'package:finale/views/spotify_album_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SpotifyArtistView extends StatefulWidget {
  final dynamic /* SArtist|SArtistSimple */ artist;

  SpotifyArtistView({@required this.artist})
      : assert(artist is SArtist || artist is SArtistSimple);

  @override
  State<StatefulWidget> createState() => _SpotifyArtistViewState();
}

class _SpotifyArtistViewState extends State<SpotifyArtistView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
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
          return ErrorView(error: snapshot.error);
        } else if (!snapshot.hasData) {
          return LoadingComponent();
        }

        final artist = snapshot.data;

        return Scaffold(
            appBar: createAppBar(
              artist.name,
              backgroundColor: spotifyGreen,
            ),
            body: ListView(
              children: [
                Center(
                    child: ImageComponent(
                        displayable: artist,
                        fit: BoxFit.cover,
                        width: min(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height / 2))),
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
                    child: DisplayComponent<SAlbumSimple>(
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
                            return ErrorComponent(error: snapshot.error);
                          } else if (!snapshot.hasData) {
                            return LoadingComponent();
                          }

                          return DisplayComponent<STrack>(
                            scrollable: false,
                            items: snapshot.data,
                            secondaryAction: (track) async {
                              await showBarModalBottomSheet(
                                  context: context,
                                  duration: Duration(milliseconds: 200),
                                  builder: (context) => ScrobbleView(
                                      track: track, isModal: true));
                            },
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
