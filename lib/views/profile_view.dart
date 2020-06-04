import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/components/display_component.dart';
import 'package:simplescrobble/components/image_component.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/luser.dart';

class ProfileView extends StatelessWidget {
  final String username;

  ProfileView({Key key, @required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LUser>(
      future: Lastfm.getUser(username),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      buildImageUrl(user.imageId, ImageQuality.high))),
              SizedBox(width: 8),
              Text(user.name)
            ]),
          ),
          body: Column(
            children: [
              SizedBox(height: 10),
              Text('Scrobbling since ${user.registered.dateFormatted}'),
              SizedBox(height: 10),
              IntrinsicHeight(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text('Scrobbles'),
                      Text(formatNumber(user.playCount))
                    ],
                  ),
                  VerticalDivider(),
                  Column(
                    children: [
                      Text('Artists'),
                      FutureBuilder<int>(
                          future: Lastfm.getNumArtists(username),
                          builder: (context, snapshot) => Text(snapshot.hasData
                              ? formatNumber(snapshot.data)
                              : '---'))
                    ],
                  ),
                  VerticalDivider(),
                  Column(
                    children: [
                      Text('Albums'),
                      FutureBuilder<int>(
                          future: Lastfm.getNumAlbums(username),
                          builder: (context, snapshot) => Text(snapshot.hasData
                              ? formatNumber(snapshot.data)
                              : '---'))
                    ],
                  ),
                  VerticalDivider(),
                  Column(
                    children: [
                      Text('Tracks'),
                      FutureBuilder<int>(
                          future: Lastfm.getNumTracks(username),
                          builder: (context, snapshot) => Text(snapshot.hasData
                              ? formatNumber(snapshot.data)
                              : '---'))
                    ],
                  ),
                ],
              )),
              SizedBox(height: 10),
              Expanded(
                  child: DefaultTabController(
                      length: 5,
                      child: Column(children: [
                        TabBar(tabs: [
                          Tab(icon: Icon(Icons.queue_music)),
                          Tab(icon: Icon(Icons.people)),
                          Tab(icon: Icon(Icons.album)),
                          Tab(icon: Icon(Icons.audiotrack)),
                          Tab(icon: Icon(Icons.person)),
                        ]),
                        Expanded(
                            child: TabBarView(children: [
                          DisplayComponent(
                              request: GetRecentTracksRequest(username)),
                          DisplayComponent(
                              displayType: DisplayType.grid,
                              displayPeriodSelector: true,
                              request: GetTopArtistsRequest(username)),
                          DisplayComponent(
                              displayType: DisplayType.grid,
                              displayPeriodSelector: true,
                              request: GetTopAlbumsRequest(username)),
                          DisplayComponent(
                              displayPeriodSelector: true,
                              request: GetTopTracksRequest(username)),
                          DisplayComponent(
                              request: GetFriendsRequest(username)),
                        ]))
                      ])))
            ],
          ),
        );
      },
    );
  }
}
