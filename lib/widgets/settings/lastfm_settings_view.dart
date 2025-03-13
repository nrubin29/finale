import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:finale/widgets/settings/lastfm_login_web_view.dart';
import 'package:flutter/material.dart';

class LastfmSettingsView extends StatefulWidget {
  const LastfmSettingsView();

  @override
  State<LastfmSettingsView> createState() => _LastfmSettingsViewState();
}

class _LastfmSettingsViewState extends State<LastfmSettingsView> {
  var _hasCookies = false;

  @override
  void initState() {
    super.initState();
    _setHasCookies();
  }

  Future<void> _setHasCookies() async {
    final hasCookies = await LastfmCookie.hasCookies();
    setState(() {
      _hasCookies = hasCookies;
    });
  }

  void _logIn() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LastfmLoginWebView()),
    );
    await _setHasCookies();
  }

  void _reset() async {
    await LastfmCookie.clear();
    await _setHasCookies();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(context, 'Last.fm Settings'),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'Certain advanced Last.fm features require you to sign in '
            'again using a different method. This authorization must be '
            'renewed once per year.',
          ),
        ),
        CaptionedListTile(
          title: 'Advanced Features',
          icon: Icons.key,
          trailing:
              _hasCookies
                  ? TextButton(onPressed: _reset, child: const Text('Reset'))
                  : TextButton(onPressed: _logIn, child: const Text('Log In')),
          // It would be great to show the expiration date in the caption, but
          // Android doesn't return it even though it stores it.
        ),
        if (_hasCookies)
          TextButton(
            onPressed: () async {
              final latestScrobbles = await GetRecentTracksRequest(
                Preferences.name.value!,
              ).getData(1, 1);
              final latestScrobble = latestScrobbles.single;
              print('Going to delete $latestScrobble');
              final result = await LastfmCookie.deleteScrobble(latestScrobble);
              print('Result: $result');
            },
            child: const Text("Delete latest scrobble"),
          ),
      ],
    ),
  );
}
