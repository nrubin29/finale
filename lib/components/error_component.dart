import 'dart:io';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorComponent extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final Entity? entity;
  final bool showSendFeedbackButton;

  ErrorComponent(
      {required this.error,
      required this.stackTrace,
      this.entity,
      this.showSendFeedbackButton = true})
      // In debug mode, print the error.
      : assert(() {
          print('$error\n$stackTrace');
          return true;
        }());

  Future<String> get _uri async {
    var errorString = '$error';

    if (error is LException) {
      final lException = error as LException;
      errorString = 'LException | ${lException.code} | ${lException.message}';
    } else if (error is SException) {
      final sException = error as SException;
      errorString = 'SException | ${sException.status} | ${sException.message}';
    }

    final errorParts = [
      errorString,
      'Platform: ${Platform.operatingSystem}',
      'Version number: ${(await PackageInfo.fromPlatform()).fullVersion}',
      'Username: ${Preferences().name}',
      if (entity != null) 'Entity: $entity',
      'Stack trace:\n$stackTrace',
    ];

    return Uri(
      scheme: 'mailto',
      path: 'nrubin29@gmail.com',
      query: 'subject=Finale error&body=Please include any additional details '
          'that may be relevant. Thank you for helping to improve Finale!\n\n> '
          '\n\n-----\n\nError details:\n${errorParts.join('\n')}',
    ).toString();
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
          if (showSendFeedbackButton) ...[
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () async {
                launch(await _uri);
              },
              child: Text('Send feedback'),
            ),
          ],
        ],
      ));
}
