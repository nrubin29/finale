import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/services/apple_music/played_song.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/entity/entity_checkbox_list.dart';
import 'package:finale/widgets/settings/apple_music_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AppleMusicScrobbleView extends StatefulWidget {
  const AppleMusicScrobbleView();

  @override
  _AppleMusicScrobbleViewState createState() => _AppleMusicScrobbleViewState();
}

class _AppleMusicScrobbleViewState extends State<AppleMusicScrobbleView> {
  AuthorizationStatus? _authorizationStatus;
  List<AMPlayedSong>? _items;
  List<AMPlayedSong>? _selection;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _hasItemsToScrobble => _selection?.isNotEmpty ?? false;

  Future<void> _load() async {
    _authorizationStatus = await AppleMusic.authorize();

    if (_authorizationStatus == AuthorizationStatus.authorized) {
      final tracks = await AppleMusic.getRecentTracks();
      setState(() {
        _items = tracks;
        _selection = _items;
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _scrobble() async {
    final success = await AppleMusic.scrobble(_selection!);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scrobbled successfully!')));

      // Ask for a review
      if (await InAppReview.instance.isAvailable()) {
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
            bottom: false,
            child: Text(
              'Due to limitations imposed by Apple, Finale can only scrobble '
              'music that has been added to your library. Additionally, if you '
              'listen to a song multiple times before scrobbling, Finale will '
              'only scrobble your last listen.',
              textAlign: TextAlign.center,
            ),
          ),
          if (Preferences().lastAppleMusicScrobble != null)
            SafeArea(
              minimum: const EdgeInsets.all(8),
              top: false,
              bottom: false,
              child: Text(
                'Last scrobbled: ' +
                    dateTimeFormat
                        .format(Preferences().lastAppleMusicScrobble!),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: EntityCheckboxList<AMPlayedSong>(
              items: _items!,
              displayImages: false,
              noResultsMessage: 'No music to scrobble.',
              onRefresh: _load,
              onSelectionChanged: (selection) {
                _selection = selection;
              },
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
              icon: const Icon(Icons.settings),
              onPressed: () async {
                await showBarModalBottomSheet(
                    context: context,
                    duration: const Duration(milliseconds: 200),
                    builder: (_) => const AppleMusicSettingsView());

                if (!Preferences().isAppleMusicEnabled) {
                  Navigator.pop(context);
                }
              },
            ),
            IconButton(
              icon: const Icon(scrobbleIcon),
              onPressed: _hasItemsToScrobble ? _scrobble : null,
            ),
          ],
        ),
        body: _body,
      );
}
