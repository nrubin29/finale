import 'package:finale/types/generic.dart';
import 'package:flutter/material.dart';

class CountsComponent extends StatelessWidget {
  final int scrobbles;
  final Future<int> artists;
  final Future<int> albums;
  final Future<int> tracks;

  CountsComponent({
    @required this.scrobbles,
    @required this.artists,
    @required this.albums,
    @required this.tracks,
  });

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('Scrobbles'),
                Text(formatNumber(scrobbles)),
              ],
            ),
            VerticalDivider(),
            Column(
              children: [
                Text('Artists'),
                FutureBuilder<int>(
                  future: artists,
                  builder: (context, snapshot) => Text(
                      snapshot.hasData ? formatNumber(snapshot.data) : '---'),
                )
              ],
            ),
            VerticalDivider(),
            Column(
              children: [
                Text('Albums'),
                FutureBuilder<int>(
                  future: albums,
                  builder: (context, snapshot) => Text(
                      snapshot.hasData ? formatNumber(snapshot.data) : '---'),
                ),
              ],
            ),
            VerticalDivider(),
            Column(
              children: [
                Text('Tracks'),
                FutureBuilder<int>(
                  future: tracks,
                  builder: (context, snapshot) => Text(
                      snapshot.hasData ? formatNumber(snapshot.data) : '---'),
                )
              ],
            ),
          ],
        ),
      );
}
