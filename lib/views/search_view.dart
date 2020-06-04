import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simplescrobble/components/display_component.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/views/scrobble_view.dart';

class SearchView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _query = BehaviorSubject<String>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
              title: TextField(
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
    _query.close();
  }
}
