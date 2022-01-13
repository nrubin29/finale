import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';
import 'package:in_app_review/in_app_review.dart';

class _PlayedSong extends BasicScrobbledTrack {
  final PlayedSong _playedSong;

  _PlayedSong(this._playedSong);

  @override
  DateTime get date => _playedSong.lastPlayedDate;

  @override
  String? get albumName => _playedSong.album;

  @override
  String? get artistName => _playedSong.artist;

  @override
  String get name => _playedSong.title;

  @override
  String? get url => null;
}

class AppleMusicScrobbleView extends StatefulWidget {
  const AppleMusicScrobbleView();

  @override
  _AppleMusicScrobbleViewState createState() => _AppleMusicScrobbleViewState();
}

class _AppleMusicScrobbleViewState extends State<AppleMusicScrobbleView> {
  AuthorizationStatus? _authorizationStatus;
  Map<_PlayedSong, bool>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _hasItemsToScrobble =>
      _items != null && _items!.isNotEmpty && _items!.values.any((e) => e);

  Future<void> _load() async {
    _authorizationStatus = await FlutterMPMediaPlayer.authorize();

    if (_authorizationStatus == AuthorizationStatus.authorized) {
      var after = DateTime.now().subtract(const Duration(days: 14));
      final last = Preferences().lastAppleMusicScrobble;
      if (last != null && last.isAfter(after)) {
        after = last;
      }

      final tracks = await FlutterMPMediaPlayer.getRecentTracks(after: after);
      setState(() {
        _items = Map.fromIterable(tracks.map((e) => _PlayedSong(e)),
            value: (_) => true);
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _scrobble() async {
    final now = DateTime.now();

    final tracks = _items!.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList(growable: false);

    final response = await Lastfm.scrobble(
        tracks, tracks.map((track) => track.date).toList(growable: false));

    if (response.ignored == 0) {
      Preferences().lastAppleMusicScrobble = now;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scrobbled successfully!')));

      // Ask for a review
      if (!isWeb && await InAppReview.instance.isAvailable()) {
        InAppReview.instance.requestReview();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while scrobbling')));
    }
  }

  Widget get _body {
    if (_authorizationStatus == null) {
      return const SizedBox();
    } else if (_authorizationStatus != AuthorizationStatus.authorized) {
      return const Center(
        child: Text('Unable to access your music library.'),
      );
    } else if (_items == null) {
      return const Center(child: LoadingComponent());
    } else {
      return Column(
        children: [
          const SafeArea(
            minimum: EdgeInsets.all(8),
            child: Text(
              'Due to limitations imposed by Apple, Finale can only scrobble '
              'music that has been added to your library. Additionally, if you '
              'listen to a song multiple times before scrobbling, Finale will '
              'only scrobble your last listen.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: EntityDisplay<_PlayedSong>(
              items: _items!.keys.toList(growable: false),
              displayImages: false,
              noResultsMessage: 'No music to scrobble.',
              leadingWidgetBuilder: (item) => Checkbox(
                value: _items![item],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _items![item] = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar(
          'Scrobble from Apple Music',
          actions: [
            IconButton(
              icon: const Icon(scrobbleIcon),
              onPressed: _hasItemsToScrobble ? _scrobble : null,
            ),
          ],
        ),
        body: _body,
      );
}
