import 'package:finale/components/counts_component.dart';
import 'package:finale/components/display_component.dart';
import 'package:finale/components/error_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/loading_component.dart';
import 'package:finale/lastfm.dart';
import 'package:finale/types/lalbum.dart';
import 'package:finale/types/lartist.dart';
import 'package:finale/types/ltrack.dart';
import 'package:finale/types/luser.dart';
import 'package:finale/views/album_view.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/settings_view.dart';
import 'package:finale/views/track_view.dart';
import 'package:finale/views/weekly_chart_selector_view.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class ProfileView extends StatefulWidget {
  final String username;
  final bool isTab;

  ProfileView({Key key, @required this.username, this.isTab = false})
      : super(key: key);

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
          return ErrorComponent(error: snapshot.error);
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
                            detailWidgetProvider: (track) =>
                                TrackView(track: track),
                          ),
                          DisplayComponent<LTopArtistsResponseArtist>(
                            displayType: DisplayType.grid,
                            displayPeriodSelector: true,
                            request: GetTopArtistsRequest(widget.username),
                            detailWidgetProvider: (artist) =>
                                ArtistView(artist: artist),
                          ),
                          DisplayComponent<LTopAlbumsResponseAlbum>(
                            displayType: DisplayType.grid,
                            displayPeriodSelector: true,
                            request: GetTopAlbumsRequest(widget.username),
                            detailWidgetProvider: (album) =>
                                AlbumView(album: album),
                          ),
                          DisplayComponent<LTopTracksResponseTrack>(
                            displayPeriodSelector: true,
                            request: GetTopTracksRequest(widget.username),
                            detailWidgetProvider: (track) =>
                                TrackView(track: track),
                          ),
                          DisplayComponent<LUser>(
                            displayCircularImages: true,
                            request: GetFriendsRequest(widget.username),
                            detailWidgetProvider: (user) =>
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
