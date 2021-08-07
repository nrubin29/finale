import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/widgets/base/error_view.dart';
import 'package:finale/widgets/base/loading_view.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/profile/period_selector.dart';
import 'package:finale/widgets/profile/play_count_bar.dart';
import 'package:finale/widgets/profile/weekly_chart_selector_view.dart';
import 'package:finale/widgets/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ProfileView extends StatefulWidget {
  final String username;
  final bool isTab;

  ProfileView({required this.username, this.isTab = false});

  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
          return ErrorView(
              error: snapshot.error!, stackTrace: snapshot.stackTrace!);
        } else if (!snapshot.hasData) {
          return LoadingView();
        }

        final user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EntityImage(entity: user, isCircular: true, width: 40),
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
          body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Text(
                  'Scrobbling since ${user.registered.dateFormatted}',
                  textAlign: TextAlign.center,
                ),
              ),
              SliverVisibility(
                visible: _tab != 5,
                maintainState: true,
                sliver: SliverToBoxAdapter(
                  child: Column(children: [
                    SizedBox(height: 10),
                    Scoreboard(statistics: {
                      'Scrobbles': user.playCount,
                      'Artists': Lastfm.getNumArtists(widget.username),
                      'Albums': Lastfm.getNumAlbums(widget.username),
                      'Tracks': Lastfm.getNumTracks(widget.username),
                    }),
                    SizedBox(height: 10),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: TabBar(
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
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                EntityDisplay<LRecentTracksResponseTrack>(
                  request: GetRecentTracksRequest(widget.username),
                  detailWidgetBuilder: (track) => TrackView(track: track),
                ),
                PeriodSelector<LTopArtistsResponseArtist>(
                  displayType: DisplayType.grid,
                  request: GetTopArtistsRequest(widget.username),
                  detailWidgetBuilder: (artist) => ArtistView(artist: artist),
                  subtitleWidgetBuilder: (item, items) =>
                      PlayCountBar(item, items),
                ),
                PeriodSelector<LTopAlbumsResponseAlbum>(
                  displayType: DisplayType.grid,
                  request: GetTopAlbumsRequest(widget.username),
                  detailWidgetBuilder: (album) => AlbumView(album: album),
                  subtitleWidgetBuilder: (item, items) =>
                      PlayCountBar(item, items),
                ),
                PeriodSelector<LTopTracksResponseTrack>(
                  request: GetTopTracksRequest(widget.username),
                  detailWidgetBuilder: (track) => TrackView(track: track),
                  subtitleWidgetBuilder: (item, items) =>
                      PlayCountBar(item, items),
                ),
                EntityDisplay<LUser>(
                  displayCircularImages: true,
                  request: GetFriendsRequest(widget.username),
                  detailWidgetBuilder: (user) =>
                      ProfileView(username: user.name),
                ),
                WeeklyChartSelectorView(user: user),
              ],
            ),
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
