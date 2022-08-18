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
  final Object? detailObject;
  final IconData icon;
  final bool showSendFeedbackButton;
  final VoidCallback? onRetry;

  const ErrorComponent._(this.title, this.error, this.stackTrace,
      this.detailObject, this.icon, this.showSendFeedbackButton, this.onRetry);

  factory ErrorComponent(
      {required Exception error,
      required StackTrace stackTrace,
      Object? detailObject,
      VoidCallback? onRetry}) {
    var title = 'An error occurred';
    Object errorObject = error;
    var icon = Icons.error;
    var showSendFeedbackButton = true;

    if (error is SocketException ||
        (error is HttpException &&
            error.message ==
                'Connection closed before full header was received')) {
      // Network error.
      title = 'Network error';
      errorObject =
          'Please ensure you have a stable network connection, then try again. '
          'If the error persists, try again later.';
      icon = Icons.wifi_off;
      showSendFeedbackButton = false;
    } else if (error is LException) {
      if (error.code == 6) {
        // "Invalid parameters" error. This may also be the case when a track is
        // not found.
        showSendFeedbackButton = false;
      } else if (error.code == 8) {
        // Last.fm back-end error.
        title = 'Last.fm error';
        errorObject =
            'Last.fm is having trouble processing your request right now. '
            'Please try again. If the error persists, try again later.';
        showSendFeedbackButton = false;
      } else if (error.code == 29) {
        // Last.fm back-end error or rate limit exceeded.
        title = 'Rate limit exceeded';
        errorObject =
            'Too many people are using Finale right now. Please try again. If '
            'the error persists, try again later.';
        showSendFeedbackButton = false;
      }
    }

    return ErrorComponent._(title, errorObject, stackTrace, detailObject, icon,
        showSendFeedbackButton, onRetry);
  }

  Future<Uri> get _uri async {
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
      'Username: ${Preferences.name.value}',
      if (detailObject != null) 'Detail object: $detailObject',
      'Stack trace:\n$stackTrace',
    ];

    return Uri(
      scheme: 'mailto',
      path: 'feedback@finale.app',
      query: 'subject=Finale error&body=Please include any additional details '
          'that may be relevant. Thank you for helping to improve Finale!\n\n> '
          '\n\n-----\n\nError details:\n${errorParts.join('\n')}',
    );
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
          ),
          if (onRetry != null || showSendFeedbackButton) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null)
                  OutlinedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                if (onRetry != null && showSendFeedbackButton)
                  const SizedBox(width: 10),
                if (showSendFeedbackButton)
                  OutlinedButton(
                    onPressed: () async {
                      launchUrl(await _uri);
                    },
                    child: const Text('Send feedback'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
