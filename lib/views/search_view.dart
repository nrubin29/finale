import 'package:finale/components/display_component.dart';
import 'package:finale/lastfm.dart';
import 'package:finale/views/scrobble_album_view.dart';
import 'package:finale/views/scrobble_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';

class SearchView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _textController = TextEditingController();
  final _query = BehaviorSubject<String>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
              title: TextField(
                controller: _textController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white)),
                onChanged: (text) {
                  setState(() {
                    _query.value = text;
                  });
                },
              ),
              actions: [
                Visibility(
                    visible:
                        _textController != null && _textController.text != '',
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _textController.value = TextEditingValue.empty;
                          _query.value = '';
                        });
                      },
                    ))
              ],
              bottom: TabBar(tabs: [
                Tab(icon: Icon(Icons.audiotrack)),
                Tab(icon: Icon(Icons.people)),
                Tab(icon: Icon(Icons.album))
              ])),
          body: TabBarView(
            children: _query.hasValue && _query.value != ''
                ? [
                    DisplayComponent(
                        secondaryAction: (item) async {
                          final fullTrack = await Lastfm.getTrack(item);

                          final result = await showBarModalBottomSheet<bool>(
                              context: context,
                              duration: Duration(milliseconds: 200),
                              builder: (context, controller) => ScrobbleView(
                                    track: fullTrack,
                                    isModal: true,
                                  ));

                          if (result != null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(result
                                    ? 'Scrobbled successfully!'
                                    : 'An error occurred while scrobbling')));
                          }
                        },
                        requestStream: _query
                            .debounceTime(Duration(
                                milliseconds:
                                    Duration.millisecondsPerSecond ~/ 2))
                            .map((query) => SearchTracksRequest(query))),
                    DisplayComponent(
                        displayType: DisplayType.grid,
                        requestStream: _query
                            .debounceTime(Duration(
                                milliseconds:
                                    Duration.millisecondsPerSecond ~/ 2))
                            .map((query) => SearchArtistsRequest(query))),
                    DisplayComponent(
                        secondaryAction: (item) async {
                          final fullAlbum = await Lastfm.getAlbum(item);

                          if (fullAlbum.tracks.isEmpty) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'This album doesn\'t have any tracks')));
                            return;
                          } else if (!fullAlbum.tracks.every((track) =>
                              track.duration != null && track.duration > 0)) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Can\'t scrobble album because Last.fm is missing track duration data')));
                            return;
                          }

                          final result = await showBarModalBottomSheet<bool>(
                              context: context,
                              duration: Duration(milliseconds: 200),
                              builder: (context, controller) =>
                                  ScrobbleAlbumView(album: fullAlbum));

                          if (result != null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(result
                                    ? 'Scrobbled successfully!'
                                    : 'An error occurred while scrobbling')));
                          }
                        },
                        displayType: DisplayType.grid,
                        requestStream: _query
                            .debounceTime(Duration(
                                milliseconds:
                                    Duration.millisecondsPerSecond ~/ 2))
                            .map((query) => SearchAlbumsRequest(query))),
                  ]
                : [Container(), Container(), Container()],
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _query.close();
  }
}
