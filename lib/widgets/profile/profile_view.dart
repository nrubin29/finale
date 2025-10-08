import 'dart:async';
import 'dart:math';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/obsessions.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/external_actions/external_actions.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/profile_tab.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/fractional_bar.dart';
import 'package:finale/widgets/base/future_builder_view.dart';
import 'package:finale/widgets/base/now_playing_animation.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/love_button.dart';
import 'package:finale/widgets/entity/lastfm/number_one_badge.dart';
import 'package:finale/widgets/entity/lastfm/obsession_menu_button.dart';
import 'package:finale/widgets/entity/lastfm/profile_stack.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:finale/widgets/entity/lastfm/track_menu_button.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/main/login_view.dart';
import 'package:finale/widgets/profile/period_selector.dart';
import 'package:finale/widgets/profile/profile_scrobble_distribution_component.dart';
import 'package:finale/widgets/profile/weekly_chart_selector_view.dart';
import 'package:finale/widgets/scrobble/friend_scrobble_view.dart';
import 'package:finale/widgets/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final _recentScrobblesKey = GlobalKey<EntityDisplayState>();
  late final StreamSubscription _profileTabsOrderSubscription;
  StreamSubscription? _externalActionsSubscription;

  late ProfileStackData _profileStack;

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
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ProfileStack.find(context).push(widget.username);
    });

    _tabOrder = Preferences.profileTabsOrder.value;
    _profileTabsOrderSubscription = Preferences.profileTabsOrder.changes.listen(
      (tabOrder) {
        setState(() {
          _createTabController(tabOrder.length);
          _tabOrder = tabOrder;
        });
      },
    );

    _createTabController();

    if (widget.isTab) {
      _externalActionsSubscription = externalActionsStream.listen((
        action,
      ) async {
        await Future.delayed(const Duration(milliseconds: 250));
        if (action.type == ExternalActionType.viewTab) {
          final tab = action.value as ProfileTab;
          final index = _tabOrder.indexOf(tab);

          if (index != -1) {
            setState(() {
              _tabController!.index = index;
            });
          }
        } else if (action.type == ExternalActionType.openSpotifyChecker) {
          launchUrl(Lastfm.applicationSettingsUri);
        }
      });
    }
  }

  void _createTabController([int? length]) {
    _tabController?.dispose();
    _tabController = TabController(
      length: length ?? _tabOrder.length,
      vsync: this,
    );
  }

  Widget _widgetForTab(ProfileTab tab, LUser user) {
    return switch (tab) {
      ProfileTab.recentScrobbles => EntityDisplay<LRecentTracksResponseTrack>(
        key: _recentScrobblesKey,
        request: GetRecentTracksRequest(
          widget.username,
          includeCurrentScrobble: true,
          extended: true,
        ),
        menuWidgetBuilder: widget.isTab
            ? (item, onChange) => TrackMenuButton(
                track: item,
                enabled: !item.isEdited && !item.isDeleted,
                onTrackChange: onChange,
              )
            : null,
        badgeWidgetBuilder: (track) =>
            track.isLoved ? const OutlinedLoveIcon() : null,
        trailingWidgetBuilder: (track) => track.timestamp != null
            ? const SizedBox()
            : const NowPlayingAnimation(),
        detailWidgetBuilder: (track) => TrackView(track: track),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Scrobbling since ${user.registered.dateFormatted}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        scoreboardItems: [
          ScoreboardItemModel.future(
            label: 'Scrobbles',
            futureProvider: () =>
                Lastfm.getUser(widget.username).then((user) => user.playCount),
          ),
          ScoreboardItemModel.future(
            label: 'Artists',
            futureProvider: () => GetTopArtistsRequest(
              widget.username,
              ApiPeriod.overall,
            ).getNumItems(),
          ),
          ScoreboardItemModel.future(
            label: 'Albums',
            futureProvider: () => GetTopAlbumsRequest(
              widget.username,
              ApiPeriod.overall,
            ).getNumItems(),
          ),
          ScoreboardItemModel.future(
            label: 'Tracks',
            futureProvider: () => GetTopTracksRequest(
              widget.username,
              ApiPeriod.overall,
            ).getNumItems(),
          ),
        ],
      ),
      ProfileTab.topArtists => PeriodSelector<LTopArtistsResponseArtist>(
        entityType: EntityType.artist,
        displayType: DisplayType.grid,
        requestConstructor: GetTopArtistsRequest.new,
        username: widget.username,
        detailWidgetBuilder: (artist) => ArtistView(artist: artist),
        subtitleWidgetBuilder: FractionalBar.forEntity,
      ),
      ProfileTab.topAlbums => PeriodSelector<LTopAlbumsResponseAlbum>(
        entityType: EntityType.album,
        displayType: DisplayType.grid,
        requestConstructor: GetTopAlbumsRequest.new,
        username: widget.username,
        detailWidgetBuilder: (album) => AlbumView(album: album),
        subtitleWidgetBuilder: FractionalBar.forEntity,
      ),
      ProfileTab.topTracks => PeriodSelector<LTopTracksResponseTrack>(
        entityType: EntityType.track,
        requestConstructor: GetTopTracksRequest.new,
        username: widget.username,
        detailWidgetBuilder: (track) => TrackView(track: track),
        subtitleWidgetBuilder: FractionalBar.forEntity,
      ),
      ProfileTab.lovedTracks => EntityDisplay<LUserLovedTrack>(
        request: UserGetLovedTracksRequest(widget.username),
        detailWidgetBuilder: (track) => TrackView(track: track),
      ),
      ProfileTab.obsessions => EntityDisplay<LObsession>(
        request: LUserObsessions(username: widget.username),
        detailWidgetBuilder: (track) => TrackView(track: track),
        badgeWidgetBuilder: (obsession) =>
            obsession.wasFirst ? const NumberOneBadge() : null,
        menuWidgetBuilder: isMobile
            ? (item, onChange) => ObsessionMenuButton(
                obsession: item,
                onObsessionChange: onChange,
              )
            : null,
      ),
      ProfileTab.friends => EntityDisplay<LUser>(
        displayCircularImages: true,
        request: GetFriendsRequest(widget.username),
        detailWidgetBuilder: (user) => ProfileView(username: user.name),
      ),
      ProfileTab.charts => WeeklyChartSelectorView(user: user),
      ProfileTab.scrobbleDistribution => ProfileScrobbleDistributionComponent(
        username: widget.username,
      ),
    };
  }

  PreferredSizeWidget _tabBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxIconSize = screenWidth / _tabOrder.length - 32.0;
    final iconSize = maxIconSize.clamp(20.0, 24.0);
    final totalIconsSize = iconSize * _tabOrder.length;
    final remainingSpace = screenWidth - totalIconsSize;
    final padding = EdgeInsets.symmetric(
      horizontal: min(remainingSpace / (_tabOrder.length * 2), 16.0),
    );

    return TabBar(
      controller: _tabController,
      tabAlignment: TabAlignment.center,
      labelPadding: padding,
      tabs: [
        for (final tab in _tabOrder)
          Tab(
            icon: tab.iconRotationDegrees != null
                ? Transform.rotate(
                    angle: tab.iconRotationDegrees! * pi / 180,
                    child: Icon(tab.icon, size: iconSize),
                  )
                : Icon(tab.icon, size: iconSize),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilderView<LUser>(
    futureFactory: () => Lastfm.getUser(widget.username),
    baseEntity: widget.username,
    onError: (e) {
      if (widget.isTab &&
          e is LException &&
          e.code == 6 &&
          e.message == 'User not found') {
        // Username changed; force user to log in again.
        LoginView.logOutAndShow(context);
      }
    },
    onValue: (user) {
      if (!widget.isTab) return;
      _profileStack.me = user;
    },
    builder: (user) => Scaffold(
      appBar: createAppBar(
        context,
        user.name,
        leadingEntity: user,
        circularLeadingImage: true,
        actions: [
          IconButton(
            icon: Icon(Icons.adaptive.share),
            onPressed: () {
              SharePlus.instance.share(ShareParams(text: user.url));
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
        bottom: _tabBar(context),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [for (final tab in _tabOrder) _widgetForTab(tab, user)],
      ),
    ),
  );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = DateTime.now();
    if (state == AppLifecycleState.resumed) {
      if (now.isAfter(_nextAutoUpdate)) {
        _recentScrobblesKey.currentState?.reload();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _nextAutoUpdate = now.add(const Duration(minutes: 5));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileStack = ProfileStack.find(context);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _profileTabsOrderSubscription.cancel();
    _externalActionsSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _profileStack.pop();
    });
    super.dispose();
  }
}
