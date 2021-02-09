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
        body: Builder(
          builder: (context) => !_loaded
              ? LoadingComponent()
              : Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      '$_numScrobbles scrobbles',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_tracks.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            child: Text('Top Track'),
                          ),
                        if (_tracks.isNotEmpty)
                          ListTile(
                            title: Text(_tracks.first.name),
                            subtitle: Text(_tracks.first.artist),
                            trailing:
                                Text('${_tracks.first.playCount} scrobbles'),
                            leading: ImageComponent(displayable: _tracks.first),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TrackView(track: _tracks.first),
                                ),
                              );
                            },
                          ),
                        if (_tracks.isNotEmpty)
                          ListTile(
                            title: Text('See more'),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(title: Text('Top Tracks')),
                                    body: DisplayComponent<
                                        LUserWeeklyTrackChartTrack>(
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
                            child: Text('Top Album'),
                          ),
                        if (_albums.isNotEmpty)
                          ListTile(
                            title: Text(_albums.first.name),
                            subtitle: Text(_albums.first.artist.name),
                            trailing:
                                Text('${_albums.first.playCount} scrobbles'),
                            leading: ImageComponent(displayable: _albums.first),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AlbumView(album: _albums.first),
                                ),
                              );
                            },
                          ),
                        if (_albums.isNotEmpty)
                          ListTile(
                            title: Text('See more'),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(title: Text('Top Albums')),
                                    body: DisplayComponent<
                                        LUserWeeklyAlbumChartAlbum>(
                                      items: _albums,
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
                            child: Text('Top Artist'),
                          ),
                        if (_artists.isNotEmpty)
                          ListTile(
                            title: Text(_artists.first.name),
                            trailing:
                                Text('${_artists.first.playCount} scrobbles'),
                            leading:
                                ImageComponent(displayable: _artists.first),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ArtistView(artist: _artists.first),
                                ),
                              );
                            },
                          ),
                        if (_artists.isNotEmpty)
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
                  ],
                ),
        ),
      );
}
