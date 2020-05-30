import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';

class TrackListComponent extends StatefulWidget {
  final String username;

  TrackListComponent({Key key, this.username}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TrackListComponentState(username);
}

class _TrackListComponentState extends State<TrackListComponent> {
  final String _username;

  var tracks = List<BasicScrobbledTrack>();
  int page = 1;

  final _scrollController = ScrollController();

  _TrackListComponentState(this._username);

  @override
  void initState() {
    super.initState();
    _getInitialTracks();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreTracks();
      }
    });
  }

  Future<void> _getInitialTracks() async {
    final initialTracks = await Lastfm().getRecentTracks(_username, 1);
    setState(() {
      tracks = initialTracks;
      page = 2;
    });
  }

  Future<void> _getMoreTracks() async {
    final moreTracks = await Lastfm().getRecentTracks(_username, page);
    setState(() {
      tracks.addAll(moreTracks);
      page += 1;
    });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final track = tracks[index];
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(track.name),
      subtitle: Text(track.artist),
      leading: Image.network(track.images.first.url),
      trailing: Text(track.timeDifferenceString(),
          style: TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return CircularProgressIndicator();
    }

    return Flexible(
        child: RefreshIndicator(
            onRefresh: _getInitialTracks,
            child: ListView.builder(
                controller: _scrollController,
                itemCount: tracks.length,
                itemBuilder: _itemBuilder)));
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
