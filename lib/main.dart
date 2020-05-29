import 'package:flutter/material.dart';

import 'lastfm.dart';
import 'types/luser.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'simplescrobble',
        home: FutureBuilder<LUser>(
          future: Lastfm().getUser('nrubin29'),
          builder: (context, snapshot) {
            final user = snapshot.data;

            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            return Scaffold(
              appBar: AppBar(
                title:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircleAvatar(
                      backgroundImage: NetworkImage(user.images.last.url)),
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
                  ))
                ],
              )),
            );
          },
        ));
  }
}
