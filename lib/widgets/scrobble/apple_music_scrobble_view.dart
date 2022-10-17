import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/services/apple_music/played_song.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/error_component.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/entity/entity_checkbox_list.dart';
import 'package:finale/widgets/settings/apple_music_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AppleMusicScrobbleView extends StatefulWidget {
  const AppleMusicScrobbleView();

  @override
  State<StatefulWidget> createState() => _AppleMusicScrobbleViewState();
}

class _AppleMusicScrobbleViewState extends State<AppleMusicScrobbleView> {
  AuthorizationStatus? _authorizationStatus;
  List<AMPlayedSong>? _items;
  List<AMPlayedSong>? _selection;

  Exception? _exception;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _hasItemsToScrobble => _selection?.isNotEmpty ?? false;

  Future<void> _load() async {
    try {
      final authorizationStatus = await AppleMusic.authorize();

      if (authorizationStatus == AuthorizationStatus.authorized) {
        final tracks = await const AMRecentTracksRequest().getAllData();
        setState(() {
          _authorizationStatus = authorizationStatus;
          _items = tracks;
          _selection = _items;
        });
      } else {
        setState(() {
          _authorizationStatus = authorizationStatus;
        });
      }
    } on Exception catch (err, stackTrace) {
      setState(() {
        _exception = err;
        _stackTrace = stackTrace;
      });

      if (isDebug) {
        rethrow;
      }
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
    if (_exception != null && _stackTrace != null) {
      return ErrorComponent(error: _exception!, stackTrace: _stackTrace!);
    } else if (_authorizationStatus == null || _items == null) {
      return const LoadingComponent();
    } else if (_authorizationStatus != AuthorizationStatus.authorized) {
      return const Center(
        child: Text('Unable to access your music library.'),
      );
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
          if (Preferences.lastAppleMusicScrobble.value != null)
            SafeArea(
              minimum: const EdgeInsets.all(8),
              top: false,
              bottom: false,
              child: Text(
                'Last scrobbled: '
                '${dateTimeFormat.format(Preferences.lastAppleMusicScrobble.value!)}',
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: EntityCheckboxList<AMPlayedSong>(
              items: _items!,
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

                if (!Preferences.appleMusicEnabled.value) {
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
