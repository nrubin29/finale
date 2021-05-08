import 'package:finale/components/counts_component.dart';
import 'package:finale/components/display_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/loading_component.dart';
import 'package:finale/components/period_selector_component.dart';
import 'package:finale/components/play_count_bar_component.dart';
import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/views/album_view.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/error_view.dart';
import 'package:finale/views/settings_view.dart';
import 'package:finale/views/track_view.dart';
import 'package:finale/views/weekly_chart_selector_view.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class ProfileView extends StatefulWidget {
  final String username;
  final bool isTab;

  ProfileView({@required this.username, this.isTab = false});

  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  var _tab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _tab = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LUser>(
      future: Lastfm.getUser(widget.username),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(error: snapshot.error);
        } else if (!snapshot.hasData) {
          return LoadingComponent();
        }

        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageComponent(
                      displayable: user, isCircular: true, width: 40),
                  SizedBox(width: 8),
                  Text(user.name),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share(user.url);
                },
              ),
              if (widget.isTab)
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsView()),
                    );
                  },
                )
            ],
          ),
          body: Column(
            children: [
              SizedBox(height: 10),
              Text('Scrobbling since ${user.registered.dateFormatted}'),
              Visibility(
                  visible: _tab != 5,
                  maintainState: true,
                  child: Column(children: [
                    SizedBox(height: 10),
                    CountsComponent(
                      scrobbles: user.playCount,
                      artists: Lastfm.getNumArtists(widget.username),
                      albums: Lastfm.getNumAlbums(widget.username),
                      tracks: Lastfm.getNumTracks(widget.username),
                    ),
                    SizedBox(height: 10),
                  ])),
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.red,
                      tabs: [
                        Tab(icon: Icon(Icons.queue_music)),
                        Tab(icon: Icon(Icons.people)),
                        Tab(icon: Icon(Icons.album)),
                        Tab(icon: Icon(Icons.audiotrack)),
                        Tab(icon: Icon(Icons.person)),
                        Tab(icon: Icon(Icons.access_time)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          DisplayComponent<LRecentTracksResponseTrack>(
                            request: GetRecentTracksRequest(widget.username),
                            detailWidgetBuilder: (track) =>
                                TrackView(track: track),
                          ),
                          PeriodSelectorComponent<LTopArtistsResponseArtist>(
                            displayType: DisplayType.grid,
                            request: GetTopArtistsRequest(widget.username),
                            detailWidgetBuilder: (artist) =>
                                ArtistView(artist: artist),
                            subtitleWidgetBuilder: (item, items) =>
                                PlayCountBarComponent(item, items),
                          ),
                          PeriodSelectorComponent<LTopAlbumsResponseAlbum>(
                            displayType: DisplayType.grid,
                            request: GetTopAlbumsRequest(widget.username),
                            detailWidgetBuilder: (album) =>
                                AlbumView(album: album),
                            subtitleWidgetBuilder: (item, items) =>
                                PlayCountBarComponent(item, items),
                          ),
                          PeriodSelectorComponent<LTopTracksResponseTrack>(
                            request: GetTopTracksRequest(widget.username),
                            detailWidgetBuilder: (track) =>
                                TrackView(track: track),
                            subtitleWidgetBuilder: (item, items) =>
                                PlayCountBarComponent(item, items),
                          ),
                          DisplayComponent<LUser>(
                            displayCircularImages: true,
                            request: GetFriendsRequest(widget.username),
                            detailWidgetBuilder: (user) =>
                                ProfileView(username: user.name),
                          ),
                          WeeklyChartSelectorView(user: user),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
