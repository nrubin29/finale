import 'dart:collection';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:finale/services/acrcloud/acrcloud.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/settings/listen_continuously_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum ListenContinuouslyTrackStatus {
  listening,
  scrobbled,
  skipped,
  noResults,
  acrCloudError,
  scrobbleError,
}

class ListenContinuouslyTrack extends BasicConcreteTrack {
  final DateTime timestamp;
  ListenContinuouslyTrackStatus? status;

  ListenContinuouslyTrack(
    super.name,
    super.artistName,
    super.albumName, [
    this.status,
  ]) : timestamp = DateTime.now();

  ListenContinuouslyTrack.noResults()
    : this(
        'No music detected',
        null,
        null,
        ListenContinuouslyTrackStatus.noResults,
      );

  ListenContinuouslyTrack.acrCloudError(String errorMessage)
    : this(
        errorMessage,
        null,
        null,
        ListenContinuouslyTrackStatus.acrCloudError,
      );

  ListenContinuouslyTrack.listening()
    : this('Listening...', null, null, ListenContinuouslyTrackStatus.listening);

  bool get hasResult =>
      status == ListenContinuouslyTrackStatus.scrobbled ||
      status == ListenContinuouslyTrackStatus.skipped;

  @override
  String get displayTrailing => timeFormatWithSeconds.format(timestamp);

  @override
  bool operator ==(Object other) {
    // Omit album on purpose as ACRCloud will sometimes return different albums
    // for the same song (e.g. I Will Possess Your Heart is on Narrow Stairs but
    // it's also a single).
    return other is ListenContinuouslyTrack &&
        other.name == name &&
        other.artistName == artistName;
  }

  @override
  int get hashCode => Object.hash(name, artistName);
}

class ListenContinuouslyView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListenContinuouslyViewState();
}

class _ListenContinuouslyViewState extends State<ListenContinuouslyView> {
  static const _iconForTrackStatus = {
    ListenContinuouslyTrackStatus.listening: Icons.mic,
    ListenContinuouslyTrackStatus.scrobbled: Icons.check_circle,
    ListenContinuouslyTrackStatus.skipped: Icons.skip_next,
    ListenContinuouslyTrackStatus.acrCloudError: Icons.error,
    ListenContinuouslyTrackStatus.scrobbleError: Icons.error,
    ListenContinuouslyTrackStatus.noResults: Icons.cancel,
  };

  static final _tagRegex = RegExp(r'[[(].*?[\])]');
  static final _spaceRegex = RegExp(r' {2,}');

  final _tracks = Queue<ListenContinuouslyTrack>();

  bool get _isListening =>
      _tracks.isNotEmpty &&
      _tracks.first.status == ListenContinuouslyTrackStatus.listening;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _listenContinuously();
  }

  void _listenContinuously() async {
    while (mounted) {
      await _listen();

      await Future.delayed(
        Preferences.listenMoreFrequently.value
            ? const Duration(seconds: 30)
            : const Duration(minutes: 1),
      );
    }
  }

  Future<void> _listen() async {
    if (_isListening) {
      return;
    }

    setState(() {
      _tracks.addFirst(ListenContinuouslyTrack.listening());
    });

    final session = ACRCloud.startSession();
    final result = await session.result;
    session.dispose();

    // If the user navigated away while we were listening, discard the result.
    if (!mounted) {
      return;
    }

    setState(() {
      _tracks.removeFirst();
    });

    final errorMessage = result?.errorMessage;
    if (errorMessage != null) {
      setState(() {
        _tracks.addFirst(ListenContinuouslyTrack.acrCloudError(errorMessage));
      });
      return;
    }

    if (result?.metadata?.music.isNotEmpty ?? false) {
      final resultMusicItem = result!.metadata!.music.first;
      var title = resultMusicItem.title;

      if (Preferences.stripTags.value) {
        title =
            title.replaceAll(_tagRegex, '').replaceAll(_spaceRegex, ' ').trim();
      }

      final track = ListenContinuouslyTrack(
        title,
        resultMusicItem.artists.first.name,
        resultMusicItem.album.name,
      );

      if (_tracks.firstWhereOrNull((t) => t.hasResult) == track) {
        track.status = ListenContinuouslyTrackStatus.skipped;
      } else {
        final response = await Lastfm.scrobble([track], [track.timestamp]);
        track.status =
            response.accepted == 1
                ? ListenContinuouslyTrackStatus.scrobbled
                : ListenContinuouslyTrackStatus.scrobbleError;
      }

      setState(() {
        _tracks.addFirst(track);
      });
    } else {
      setState(() {
        _tracks.addFirst(ListenContinuouslyTrack.noResults());
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(
      context,
      'Listening Continuously',
      actions: [
        IconButton(
          icon: const Icon(Icons.mic),
          onPressed: _isListening ? null : _listen,
          tooltip: 'Listen now',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            await showBarModalBottomSheet(
              context: context,
              duration: const Duration(milliseconds: 200),
              builder: (_) => const ListenContinuouslySettingsView(),
            );
            setState(() {});
          },
        ),
      ],
    ),
    body: Column(
      children: [
        SafeArea(
          minimum: const EdgeInsets.all(8),
          child: Text(
            'Keep your device on this page with the screen on. Your device '
            'will listen for music every '
            '${Preferences.listenMoreFrequently.value ? '30 seconds' : 'minute'} '
            'or so and automatically scrobble the songs it detects. '
            'Duplicate songs will be skipped.',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: EntityDisplay<ListenContinuouslyTrack>(
            items: _tracks.toList(growable: false),
            displayImages: false,
            leadingWidgetBuilder:
                (track) => Icon(_iconForTrackStatus[track.status]),
            noResultsMessage: null,
          ),
        ),
      ],
    ),
  );

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
  }
}
