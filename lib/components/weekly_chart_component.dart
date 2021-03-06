import 'package:charts_flutter/flutter.dart';
import 'package:finale/components/entity_display_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/loading_component.dart';
import 'package:finale/components/scoreboard_component.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/util/util.dart';
import 'package:finale/views/album_view.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/track_view.dart';
import 'package:flutter/material.dart';

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
  late List<Series<MapEntry<int, int>, String>> _series;

  @override
  void initState() {
    super.initState();
    _initData();
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

    final data = await Future.wait([
      Lastfm.getWeeklyTrackChart(widget.user, widget.chart),
      Lastfm.getWeeklyAlbumChart(widget.user, widget.chart),
      Lastfm.getWeeklyArtistChart(widget.user, widget.chart),
      GetRecentTracksRequest(
        widget.user.name,
        widget.chart.fromDate.secondsSinceEpoch.toString(),
        widget.chart.toDate.secondsSinceEpoch.toString(),
      ).getAllData(),
    ]);

    final tracks = (data[0] as LUserWeeklyTrackChart).tracks;
    final albums = (data[1] as LUserWeeklyAlbumChart).albums;
    final artists = (data[2] as LUserWeeklyArtistChart).artists;
    final recentTracks = data[3] as List<LRecentTracksResponseTrack>;
    final numScrobbles =
        tracks.fold<int>(0, (sum, track) => sum + (track.playCount ?? 0));
    final groupedTracks = Map<int, int>.fromIterable(
        Iterable.generate(7, (i) => i + 1),
        value: (_) => 0);

    for (final track in recentTracks) {
      if (track.date != null) {
        groupedTracks[track.date!.weekday] =
            groupedTracks[track.date!.weekday]! + 1;
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
        _series = [
          Series<MapEntry<int, int>, String>(
            id: 'Recent Tracks',
            colorFn: (_, __) => MaterialPalette.red.shadeDefault,
            domainFn: (day, _) => _weekdays[day.key - 1],
            measureFn: (day, _) => day.value,
            labelAccessorFn: (day, _) => '${day.value}',
            data: groupedTracks.entries.toList(growable: false),
          ),
        ];
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return !_loaded
        ? LoadingComponent()
        : ListView(
            children: [
              SizedBox(height: 10),
              ScoreboardComponent(statistics: {
                'Scrobbles': _numScrobbles,
                'Artists': _artists.length,
                'Albums': _albums.length,
                'Tracks': _tracks.length,
              }),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  height: 200,
                  child: Row(children: [
                    RotatedBox(quarterTurns: 3, child: Text('Scrobbles')),
                    SizedBox(width: 5),
                    Expanded(
                        child: BarChart(
                      _series,
                      barRendererDecorator: BarLabelDecorator<String>(),
                    )),
                  ]),
                ),
              ),
              SizedBox(height: 10),
              if (_tracks.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text('Top Tracks'),
                ),
              for (final track in _tracks.take(3))
                ListTile(
                  title: Text(track.name),
                  subtitle: Text(track.artistName),
                  trailing: Text('${track.playCount} scrobbles'),
                  leading: ImageComponent(entity: track),
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
                  title: Text('See more'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: Text('Top Tracks')),
                          body: EntityDisplayComponent<
                              LUserWeeklyTrackChartTrack>(
                            items: _tracks,
                            detailWidgetBuilder: (track) =>
                                TrackView(track: track),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              if (_tracks.isNotEmpty) Divider(),
              if (_albums.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text('Top Albums'),
                ),
              for (final album in _albums.take(3))
                ListTile(
                  title: Text(album.name),
                  subtitle: Text(album.artist.name),
                  trailing: Text('${album.playCount} scrobbles'),
                  leading: ImageComponent(entity: album),
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
                  title: Text('See more'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: Text('Top Albums')),
                          body: EntityDisplayComponent<
                              LUserWeeklyAlbumChartAlbum>(
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
              if (_albums.isNotEmpty) Divider(),
              if (_artists.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text('Top Artists'),
                ),
              for (final artist in _artists.take(3))
                ListTile(
                  title: Text(artist.name),
                  trailing: Text('${artist.playCount} scrobbles'),
                  leading: ImageComponent(entity: artist),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  title: Text('See more'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: Text('Top Artists')),
                          body: EntityDisplayComponent<
                              LUserWeeklyArtistChartArtist>(
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
          );
  }

  @override
  bool get wantKeepAlive => true;
}
