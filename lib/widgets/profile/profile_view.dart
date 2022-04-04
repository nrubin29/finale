import 'dart:async';

import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/profile_tab.dart';
import 'package:finale/util/quick_actions_manager.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/future_builder_view.dart';
import 'package:finale/widgets/base/now_playing_animation.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/love_button.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/profile/period_selector.dart';
import 'package:finale/widgets/base/fractional_bar.dart';
import 'package:finale/widgets/profile/weekly_chart_selector_view.dart';
import 'package:finale/widgets/scrobble/friend_scrobble_view.dart';
import 'package:finale/widgets/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class ProfileView extends StatefulWidget {
  final String username;
  final bool isTab;

  const ProfileView({required this.username, this.isTab = false});

  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController? _tabController;
  late List<ProfileTab> _tabOrder;
  var _tab = 0;

  final _recentScrobblesKey = GlobalKey<EntityDisplayState>();
  late final StreamSubscription _profileTabsOrderSubscription;
  StreamSubscription? _quickActionsSubscription;

  /// When the recent scrobbles list should next be auto-updated by
  /// [didChangeAppLifecycleState].
  ///
  /// The recent scrobbles list auto-updates when the app re-enters the
  /// foreground, but we only want to update if it's been at least 5 minutes
  /// since we last updated.
  static var _nextAutoUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    _tabOrder = Preferences.profileTabsOrder.value;
    _profileTabsOrderSubscription =
        Preferences.profileTabsOrder.changes.listen((tabOrder) {
      setState(() {
        _createTabController(tabOrder.length);
        _tabOrder = tabOrder;
      });
    });

    _createTabController();

    if (widget.isTab) {
      _quickActionsSubscription =
          QuickActionsManager().quickActionStream.listen((action) async {
        await Future.delayed(const Duration(milliseconds: 250));
        if (action.type == QuickActionType.viewTab) {
          final tab = action.value as ProfileTab;
          final index = _tabOrder.indexOf(tab);

          if (index != -1) {
            setState(() {
              _tabController!.index = index;
            });
          }
        }
      });
    }
  }

  void _createTabController([int? length]) {
    _tabController?.dispose();
    _tabController =
        TabController(length: length ?? _tabOrder.length, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        _tab = _tabController!.index;
      });
    });
  }

  Widget _widgetForTab(ProfileTab tab, LUser user) {
    switch (tab) {
      case ProfileTab.recentScrobbles:
        return EntityDisplay<LRecentTracksResponseTrack>(
          key: _recentScrobblesKey,
          request: GetRecentTracksRequest(widget.username,
              includeCurrentScrobble: true, extended: true),
          badgeWidgetBuilder: (track) =>
              track.isLoved ? const OutlinedLoveIcon() : const SizedBox(),
          trailingWidgetBuilder: (track) => track.timestamp != null
              ? const SizedBox()
              : const NowPlayingAnimation(),
          detailWidgetBuilder: (track) => TrackView(
            track: track,
            username: widget.username,
          ),
        );
      case ProfileTab.topArtists:
        return PeriodSelector<LTopArtistsResponseArtist>(
          displayType: DisplayType.grid,
          request: GetTopArtistsRequest(widget.username),
          detailWidgetBuilder: (artist) => ArtistView(
            artist: artist,
            username: widget.username,
          ),
          subtitleWidgetBuilder: FractionalBar.forEntity,
        );
      case ProfileTab.topAlbums:
        return PeriodSelector<LTopAlbumsResponseAlbum>(
          displayType: DisplayType.grid,
          request: GetTopAlbumsRequest(widget.username),
          detailWidgetBuilder: (album) => AlbumView(
            album: album,
            username: widget.username,
          ),
          subtitleWidgetBuilder: FractionalBar.forEntity,
        );
      case ProfileTab.topTracks:
        return PeriodSelector<LTopTracksResponseTrack>(
          request: GetTopTracksRequest(widget.username),
          detailWidgetBuilder: (track) => TrackView(
            track: track,
            username: widget.username,
          ),
          subtitleWidgetBuilder: FractionalBar.forEntity,
        );
      case ProfileTab.friends:
        return EntityDisplay<LUser>(
          displayCircularImages: true,
          request: GetFriendsRequest(widget.username),
          detailWidgetBuilder: (user) => ProfileView(username: user.name),
        );
      case ProfileTab.charts:
        return WeeklyChartSelectorView(user: user);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilderView<LUser>(
        futureFactory: () => Lastfm.getUser(widget.username),
        baseEntity: widget.username,
        builder: (user) => Scaffold(
          appBar: createAppBar(
            user.name,
            leadingEntity: user,
            circularLeadingImage: true,
            actions: [
              IconButton(
                icon: Icon(Icons.adaptive.share),
                onPressed: () {
                  Share.share(user.url);
                },
              ),
              if (widget.isTab)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsView()),
                    );
                  },
                )
              else
                IconButton(
                  icon: const Icon(scrobbleIcon),
                  onPressed: () {
                    showBarModalBottomSheet(
                      context: context,
                      duration: const Duration(milliseconds: 200),
                      builder: (_) => FriendScrobbleView(username: user.name),
                    );
                  },
                ),
            ],
          ),
          body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (_, __) => [
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Text(
                  'Scrobbling since ${user.registered.dateFormatted}',
                  textAlign: TextAlign.center,
                ),
              ),
              SliverVisibility(
                visible: _tab != _tabOrder.indexOf(ProfileTab.charts),
                maintainState: true,
                sliver: SliverToBoxAdapter(
                  child: Column(children: [
                    const SizedBox(height: 10),
                    Scoreboard(statistics: {
                      'Scrobbles': user.playCount,
                      'Artists': Lastfm.getNumArtists(widget.username),
                      'Albums': Lastfm.getNumAlbums(widget.username),
                      'Tracks': Lastfm.getNumTracks(widget.username),
                    }),
                    const SizedBox(height: 10),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: [
                    for (final tab in _tabOrder) Tab(icon: Icon(tab.icon)),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                for (final tab in _tabOrder) _widgetForTab(tab, user),
              ],
            ),
          ),
        ),
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = DateTime.now();
    if (state == AppLifecycleState.resumed) {
      if (now.isAfter(_nextAutoUpdate)) {
        _recentScrobblesKey.currentState?.getInitialItems();
      }
    } else {
      _nextAutoUpdate = now.add(const Duration(minutes: 5));
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _profileTabsOrderSubscription.cancel();
    _quickActionsSubscription?.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
