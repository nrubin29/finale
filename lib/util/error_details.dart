import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/spotify/common.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';

import 'extensions.dart';
import 'preferences.dart';

class ErrorDetails {
  final String title;
  final Object error;
  final StackTrace stackTrace;
  final Object? detailObject;
  final IconData icon;
  final bool canSendFeedback;
  final bool canLogOut;

  const ErrorDetails._(this.title, this.error, this.stackTrace,
      this.detailObject, this.icon, this.canSendFeedback, this.canLogOut);

  factory ErrorDetails(
      {required Exception error,
      required StackTrace stackTrace,
      Object? detailObject}) {
    var title = 'An error occurred';
    Object errorObject = error;
    var icon = Icons.error;
    var canSendFeedback = true;
    var canLogOut = false;

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
      canSendFeedback = false;
    } else if (error is LException) {
      if (error.code == 6) {
        // "Invalid parameters" error. This may also be the case when a track is
        // not found.
        if (error.message == 'User not found') {
          title = 'User not found';
          errorObject = detailObject != null
              ? 'User $detailObject does not exist.'
              : 'User does not exist.';
          icon = Icons.person_off;
        }
        canSendFeedback = false;
      } else if (error.code == 8) {
        // Last.fm back-end error.
        title = 'Last.fm error';
        errorObject =
            'Last.fm is having trouble processing your request right now. '
            'Please try again. If the error persists, try again later.';
        canSendFeedback = false;
      } else if (error.code == 9 &&
          error.message == 'Invalid session key - Please re-authenticate') {
        title = 'Session expired';
        errorObject =
            'Please log out, then log in again. If the error persists, try '
            'again later.';
        canLogOut = true;
      } else if (error.code == 29) {
        // Last.fm back-end error or rate limit exceeded.
        title = 'Rate limit exceeded';
        errorObject =
            'Too many people are using Finale right now. Please try again. If '
            'the error persists, try again later.';
        canSendFeedback = false;
      }
    } else if (error is RecentListeningInformationHiddenException) {
      title = 'Listening history hidden';
      icon = Icons.lock;
      canSendFeedback = false;
    }

    return ErrorDetails._(title, errorObject, stackTrace, detailObject, icon,
        canSendFeedback, canLogOut);
  }

  Future<Uri> get emailUri async {
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
}
