import 'package:finale/components/display_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/loading_component.dart';
import 'package:finale/lastfm.dart';
import 'package:finale/types/luser.dart';
import 'package:finale/views/album_view.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/track_view.dart';
import 'package:flutter/material.dart';

class WeeklyChartView extends StatefulWidget {
  final LUser user;
  final LUserWeeklyChart chart;

  WeeklyChartView({Key key, @required this.user, @required this.chart})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeeklyChartViewState();
}

class _WeeklyChartViewState extends State<WeeklyChartView> {
  var _loaded = false;

  int _numScrobbles;
  List<LUserWeeklyTrackChartTrack> _tracks;
  List<LUserWeeklyAlbumChartAlbum> _albums;
  List<LUserWeeklyArtistChartArtist> _artists;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final tracks =
        (await Lastfm.getWeeklyTrackChart(widget.user, widget.chart)).tracks;
    final albums =
        (await Lastfm.getWeeklyAlbumChart(widget.user, widget.chart)).albums;
    final artists =
        (await Lastfm.getWeeklyArtistChart(widget.user, widget.chart)).artists;
    final numScrobbles = tracks.fold(0, (sum, track) => sum + track.playCount);

    setState(() {
      _tracks = tracks;
      _albums = albums;
      _artists = artists;
      _numScrobbles = numScrobbles;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.chart.displayTitle)),
        body: !_loaded
            ? LoadingComponent()
            : ListView(
                children: [
                  SizedBox(height: 10),
                  Text(
                    '$_numScrobbles scrobbles',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
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
                      subtitle: Text(track.artist),
                      trailing: Text('${track.playCount} scrobbles'),
                      leading: ImageComponent(displayable: track),
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
                              body:
                                  DisplayComponent<LUserWeeklyTrackChartTrack>(
                                items: _tracks,
                                detailWidgetProvider: (track) =>
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
                      leading: ImageComponent(displayable: album),
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
                              body:
                                  DisplayComponent<LUserWeeklyAlbumChartAlbum>(
                                items: _albums,
                                displayType: DisplayType.grid,
                                detailWidgetProvider: (album) =>
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
                      leading: ImageComponent(displayable: artist),
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
                              body: DisplayComponent<
                                  LUserWeeklyArtistChartArtist>(
                                items: _artists,
                                displayType: DisplayType.grid,
                                detailWidgetProvider: (artist) =>
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
