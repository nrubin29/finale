import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorComponent extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  ErrorComponent({required this.error, required this.stackTrace})
      // In debug mode, print the error.
      : assert(() {
          print('$error\n$stackTrace');
          return true;
        }());

  String get _uri {
    var errorString = '$error';

    if (error is LException) {
      final lException = error as LException;
      errorString = 'LException | ${lException.code} | ${lException.message}';
    } else if (error is SException) {
      final sException = error as SException;
      errorString = 'SException | ${sException.status} | ${sException.message}';
    }

    errorString += '\n\nStack trace:\n$stackTrace';

    return Uri(
            scheme: 'mailto',
            path: 'nrubin29@gmail.com',
            query: 'subject=Finale error&body=Please describe what you were '
                'doing when the error occurred. If you were looking at a '
                'particular track/artist/album/etc., please include as much '
                'information as possible.\n\n\n\n-----\n\nError details:\n'
                '$errorString')
        .toString();
  }

  @override
  Widget build(BuildContext context) => Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 48),
          SizedBox(height: 10),
          Text('An error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 10),
          Text('$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption),
          SizedBox(height: 10),
          OutlinedButton(
            onPressed: () async {
              launch(_uri);
            },
            child: Text('Send feedback'),
          )
        ],
      ));
}
