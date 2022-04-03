import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:finale/util/extensions.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorComponent extends StatelessWidget {
  final String title;
  final Object error;
  final StackTrace stackTrace;
  final Object? entity;
  final IconData icon;
  final bool showSendFeedbackButton;

  const ErrorComponent._(this.title, this.error, this.stackTrace, this.entity,
      this.icon, this.showSendFeedbackButton);

  factory ErrorComponent(
      {required Exception error,
      required StackTrace stackTrace,
      Object? entity}) {
    if (error is SocketException) {
      // Network error.
      return ErrorComponent._(
        'Network error',
        'Please ensure you have a stable network connection, then try again. '
            'If the error persists, please send feedback.',
        stackTrace,
        entity,
        Icons.wifi_off,
        true,
      );
    } else if (error is LException && (error.code == 8 || error.code == 29)) {
      // Last.fm back-end error or rate limit exceeded.
      return ErrorComponent._(
        'Last.fm error',
        'Last.fm is having trouble processing your request right now. Please '
            'try again. If the error persists, please send feedback.',
        stackTrace,
        entity,
        Icons.error,
        true,
      );
    }

    var showSendFeedbackButton = true;

    if (error is LException && error.code == 6) {
      // "Not found" error.
      showSendFeedbackButton = false;
    }

    return ErrorComponent._('An error occurred', error, stackTrace, entity,
        Icons.error, showSendFeedbackButton);
  }

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
      path: 'feedback@finale.app',
      query: 'subject=Finale error&body=Please include any additional details '
          'that may be relevant. Thank you for helping to improve Finale!\n\n> '
          '\n\n-----\n\nError details:\n${errorParts.join('\n')}',
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: theme.primaryColor,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headline6,
          ),
          const SizedBox(height: 10),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: theme.textTheme.caption,
          ),
          if (showSendFeedbackButton) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () async {
                launch(await _uri);
              },
              child: const Text('Send feedback'),
            ),
          ],
        ],
      ),
    );
  }
}
