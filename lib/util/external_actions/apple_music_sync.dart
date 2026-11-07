/// Runs the "Scrobble Apple Music" iOS shortcut.
///
/// The App Intent (ios/Runner/ScrobbleAppleMusicIntent.swift) starts a headless
/// engine at [appleMusicSyncMain] in main.dart, which calls [run]. The result
/// is sent back over [_channel] so the intent can report it to Shortcuts.
library;

import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/util/preference.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _channel = MethodChannel('com.nrubintech.finale/apple_music_sync');

Future<void> run() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Preference.setup();

    final error = await _checkPreconditions();
    if (error != null) {
      await _sendResult(error: error);
      return;
    }

    final count = await AppleMusic.scrobbleRecentTracks();
    if (count == null) {
      await _sendResult(error: 'Last.fm rejected some of the scrobbles.');
    } else {
      await _sendResult(count: count);
    }
  } catch (e) {
    await _sendResult(error: 'Scrobbling failed: $e');
  }
}

Future<String?> _checkPreconditions() async {
  if (Preferences.name.value == null) {
    return 'Log in to Finale first.';
  } else if (!Preferences.appleMusicEnabled.value) {
    return 'Apple Music is disabled in Finale settings.';
  } else if (await AppleMusic.authorizationStatus != .authorized) {
    return "Finale doesn't have access to your Apple Music library. Open "
        'Finale and scrobble from Apple Music once to grant access.';
  }

  return null;
}

Future<void> _sendResult({int? count, String? error}) =>
    _channel.invokeMethod('result', {'count': count, 'error': error});
