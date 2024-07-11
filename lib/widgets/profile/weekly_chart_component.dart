import 'dart:async';

import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/header_list_tile.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Color;

class WeeklyChartComponent extends StatefulWidget {
  final LUser user;
  final LUserWeeklyChart chart;

  const WeeklyChartComponent({required this.user, required this.chart});

  @override
  State<StatefulWidget> createState() => _WeeklyChartComponentState();
}

class _WeeklyChartComponentState extends State<WeeklyChartComponent>
    with AutomaticKeepAliveClientMixin<WeeklyChartComponent> {
  static const _weekdays = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun'];

  var _loaded = false;

  late int _numScrobbles;
  late List<LUserWeeklyTrackChartTrack> _tracks;
  late List<LUserWeeklyAlbumChartAlbum> _albums;
  late List<LUserWeeklyArtistChartArtist> _artists;
  late Map<int, int> _groupedTracks;
  late List<BarChartGroupData> _barGroups;

  late StreamSubscription _themeStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initData();

    _themeStreamSubscription =
        Preferences.themeColor.changes.listen(_updateSeries);
  }

  @override
  void didUpdateWidget(WeeklyChartComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.user != oldWidget.user || widget.chart != oldWidget.chart) {
      _initData();
    }
  }

  void _initData() async {
    setState(() {
      _loaded = false;
    });

    final (tracks, albums, artists, recentTracks) = await (
      Lastfm.getWeeklyTrackChart(widget.user, widget.chart)
          .then((value) => value.tracks),
      Lastfm.getWeeklyAlbumChart(widget.user, widget.chart)
          .then((value) => value.albums),
      Lastfm.getWeeklyArtistChart(widget.user, widget.chart)
          .then((value) => value.artists),
      GetRecentTracksRequest(widget.user.name,
              from: widget.chart.fromDate, to: widget.chart.toDate)
          .getAllData(),
    ).wait;

    final numScrobbles =
        tracks.fold(0, (sum, track) => sum + (track.playCount ?? 0));

    // The order matters, so I manually create the map instead of using a
    // utility function.
    final groupedTracks = {for (var i = 0; i < 7; i++) i: 0};
    for (final track in recentTracks) {
      if (track.date != null) {
        groupedTracks[track.date!.weekday - 1] =
            groupedTracks[track.date!.weekday - 1]! + 1;
      }
    }

    // The user can change charts before the Future resolves, so we should only
    // update the state if this component is still in the tree.
    if (mounted) {
      setState(() {
        _tracks = tracks;
        _albums = albums;
        _artists = artists;
        _numScrobbles = numScrobbles;
        _groupedTracks = groupedTracks;
        _updateSeries();
        _loaded = true;
      });
    }
  }

  void _updateSeries([ThemeColor? themeColor]) {
    final color = (themeColor ?? Preferences.themeColor.value).color;
    _barGroups = [
      for (var group in _groupedTracks.entries)
        BarChartGroupData(
          x: group.key,
          barRods: [
            BarChartRodData(
              toY: group.value.toDouble(),
              color: color,
              width: 25,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(5)),
            ),
          ],
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return !_loaded
        ? const LoadingComponent()
        : SafeArea(
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Scoreboard(items: [
                  ScoreboardItemModel(label: 'Scrobbles', value: _numScrobbles),
                  ScoreboardItemModel(label: 'Artists', value: _artists.length),
                  ScoreboardItemModel(label: 'Albums', value: _albums.length),
                  ScoreboardItemModel(label: 'Tracks', value: _tracks.length),
                ]),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        barGroups: _barGroups,
                        alignment: BarChartAlignment.center,
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            axisNameWidget: Text('Scrobbles'),
                            axisNameSize: 32,
                          ),
                          topTitles: const AxisTitles(),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 48,
                              getTitlesWidget: (value, meta) =>
                                  value % meta.appliedInterval == 0
                                      ? SideTitleWidget(
                                          axisSide: AxisSide.right,
                                          child: Text(meta.formattedValue),
                                        )
                                      : const SizedBox(),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              getTitlesWidget: (value, _) => SideTitleWidget(
                                axisSide: AxisSide.bottom,
                                child: Text(_weekdays[value.toInt()]),
                              ),
                            ),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
                                pluralize(rod.toY),
                                Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                        gridData: const FlGridData(
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_tracks.isNotEmpty) const HeaderListTile('Top Tracks'),
                for (final track in _tracks.take(3))
                  ListTile(
                    title: Text(track.name),
                    subtitle: Text(track.artistName),
                    trailing: Text('${track.playCount} scrobbles'),
                    leading: EntityImage(entity: track),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackView(track: track),
                        ),
                      );
                    },
                  ),
                if (_tracks.length > 3)
                  ListTile(
                    title: const Text('See more'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: createAppBar('Top Tracks'),
                            body: EntityDisplay<LUserWeeklyTrackChartTrack>(
                              items: _tracks,
                              detailWidgetBuilder: (track) =>
                                  TrackView(track: track),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (_albums.isNotEmpty) const HeaderListTile('Top Albums'),
                for (final album in _albums.take(3))
                  ListTile(
                    title: Text(album.name),
                    subtitle: Text(album.artist.name),
                    trailing: Text('${album.playCount} scrobbles'),
                    leading: EntityImage(entity: album),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlbumView(album: album),
                        ),
                      );
                    },
                  ),
                if (_albums.length > 3)
                  ListTile(
                    title: const Text('See more'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: createAppBar('Top Albums'),
                            body: EntityDisplay<LUserWeeklyAlbumChartAlbum>(
                              items: _albums,
                              displayType: DisplayType.grid,
                              detailWidgetBuilder: (album) =>
                                  AlbumView(album: album),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (_artists.isNotEmpty) const HeaderListTile('Top Artists'),
                for (final artist in _artists.take(3))
                  ListTile(
                    title: Text(artist.name),
                    trailing: Text('${artist.playCount} scrobbles'),
                    leading: EntityImage(entity: artist),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArtistView(artist: artist),
                        ),
                      );
                    },
                  ),
                if (_artists.length > 3)
                  ListTile(
                    title: const Text('See more'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: createAppBar('Top Artists'),
                            body: EntityDisplay<LUserWeeklyArtistChartArtist>(
                              items: _artists,
                              displayType: DisplayType.grid,
                              detailWidgetBuilder: (artist) =>
                                  ArtistView(artist: artist),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
  }

  @override
  void dispose() {
    _themeStreamSubscription.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
