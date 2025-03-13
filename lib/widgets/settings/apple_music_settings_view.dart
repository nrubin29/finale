import 'dart:async';

import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/settings/settings_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppleMusicSettingsView extends StatefulWidget {
  const AppleMusicSettingsView();

  @override
  State<StatefulWidget> createState() => _AppleMusicSettingsViewState();
}

class _AppleMusicSettingsViewState extends State<AppleMusicSettingsView> {
  AuthorizationStatus? _authorizationStatus;
  late bool _isAppleMusicEnabled;
  late final StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    _isAppleMusicEnabled = Preferences.appleMusicEnabled.value;
    _streamSubscription = Preferences.appleMusicEnabled.changes.listen((value) {
      setState(() {
        _isAppleMusicEnabled = value;
      });
    });
    _init();
  }

  Future<void> _init() async {
    AuthorizationStatus? authorizationStatus;

    try {
      authorizationStatus = await AppleMusic.authorizationStatus;
    } on PlatformException {
      // Ignore.
    }

    if (authorizationStatus != null) {
      setState(() {
        _authorizationStatus = authorizationStatus;
      });
    }
  }

  Future<void> _authorize() async {
    AuthorizationStatus? authorizationStatus;

    try {
      authorizationStatus = await AppleMusic.authorize();
    } on PlatformException {
      // Ignore.
    }

    if (authorizationStatus != null) {
      setState(() {
        _authorizationStatus = authorizationStatus;
      });
    }
  }

  String get _authorizationStatusName {
    final name = _authorizationStatus?.name;

    if (name == null) {
      return 'Authorization status loading';
    }

    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, 'Apple Music Settings'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsListTile(
            title: 'Enabled',
            icon: SocialMediaIcons.apple,
            preference: Preferences.appleMusicEnabled,
          ),
          if (_isAppleMusicEnabled) ...[
            ListTile(
              title: Text(_authorizationStatusName),
              leading: const Icon(Icons.vpn_key),
              trailing:
                  _authorizationStatus == AuthorizationStatus.notDetermined
                      ? TextButton(
                        onPressed: _authorize,
                        child: const Text('Authorize'),
                      )
                      : null,
            ),
            if (_authorizationStatus == AuthorizationStatus.authorized)
              SettingsListTile(
                title: 'Background scrobbling',
                description:
                    'If enabled, Finale will scrobble in the background '
                    'periodically.',
                icon: scrobbleIcon,
                preference: Preferences.appleMusicBackgroundScrobblingEnabled,
              ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
