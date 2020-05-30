import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/components/track_list.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/luser.dart';

class ProfileView extends StatelessWidget {
  String username;

  ProfileView({Key key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LUser>(
      future: Lastfm().getUser(username),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(backgroundImage: NetworkImage(user.images.last.url)),
              SizedBox(width: 8),
              Text(user.name)
            ]),
          ),
          body: Center(
              child: Column(
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
                      Text(user.playCountFormatted)
                    ],
                  ),
                  VerticalDivider(),
                  Column(
                    children: [Text('Artists'), Text('???')],
                  ),
                  VerticalDivider(),
                  Column(
                    children: [Text('Albums'), Text('???')],
                  ),
                  VerticalDivider(),
                  Column(
                    children: [Text('Tracks'), Text('???')],
                  ),
                ],
              )),
              TrackListComponent(username: username),
            ],
          )),
        );
      },
    );
  }
}
