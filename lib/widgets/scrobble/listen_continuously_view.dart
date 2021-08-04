import 'package:collection/collection.dart' show IterableExtension;
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar_component.dart';
import 'package:finale/widgets/entity/entity_display_component.dart';
import 'package:finale/widgets/settings/listen_continuously_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:wakelock/wakelock.dart';

enum ListenContinuouslyTrackStatus { scrobbled, skipped, noResults, error }

class ListenContinuouslyTrack extends BasicConcreteTrack {
  final DateTime timestamp;
  ListenContinuouslyTrackStatus? status;

  ListenContinuouslyTrack(String name, String? artist, String? album,
      [this.status])
      : timestamp = DateTime.now(),
        super(name, artist, album);

  ListenContinuouslyTrack.noResults()
      : this('No music detected', null, null,
            ListenContinuouslyTrackStatus.noResults);

  bool get hasResult =>
      status == ListenContinuouslyTrackStatus.scrobbled ||
      status == ListenContinuouslyTrackStatus.skipped;

  @override
  String get displayTrailing => timeFormat.format(timestamp);

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    // Omit album on purpose as ACRCloud will sometimes return different albums
    // for the same song (e.g. I Will Possess Your Heart is on Narrow Stairs but
    // it's also a single).
    return other is ListenContinuouslyTrack &&
        other.name == name &&
        other.artistName == artistName;
  }
}

class ListenContinuouslyView extends StatefulWidget {
  @override
  _ListenContinuouslyViewState createState() => _ListenContinuouslyViewState();
}

class _ListenContinuouslyViewState extends State<ListenContinuouslyView> {
  static const _iconForTrackStatus = {
    ListenContinuouslyTrackStatus.scrobbled: Icons.check_circle,
    ListenContinuouslyTrackStatus.skipped: Icons.skip_next,
    ListenContinuouslyTrackStatus.error: Icons.error,
    ListenContinuouslyTrackStatus.noResults: Icons.cancel,
  };

  static final _tagRegex = RegExp(r'[[(].*?[\])]');
  static final _spaceRegex = RegExp(r' {2,}');

  var _tracks = <ListenContinuouslyTrack>[];

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _listen();
  }

  void _listen() async {
    while (mounted) {
      final session = ACRCloud.startSession();
      final result = await session.result;
      session.dispose();

      // If the user navigated away while we were listening, discard the result.
      if (!mounted) {
        break;
      }

      if (result?.metadata?.music.isNotEmpty ?? false) {
        final resultMusicItem = result!.metadata!.music.first;
        var title = resultMusicItem.title;

        if (Preferences().stripTags) {
          title = title
              .replaceAll(_tagRegex, '')
              .replaceAll(_spaceRegex, ' ')
              .trim();
        }

        final track = ListenContinuouslyTrack(title,
            resultMusicItem.artists.first.name, resultMusicItem.album.name);

        if (_tracks.firstWhereOrNull((t) => t.hasResult) == track) {
          track.status = ListenContinuouslyTrackStatus.skipped;
        } else {
          final response = await Lastfm.scrobble([track], [track.timestamp]);
          track.status = response.accepted == 1
              ? ListenContinuouslyTrackStatus.scrobbled
              : ListenContinuouslyTrackStatus.error;
        }

        setState(() {
          _tracks.insert(0, track);
        });
      } else {
        setState(() {
          _tracks.insert(0, ListenContinuouslyTrack.noResults());
        });
      }

      await Future.delayed(Duration(minutes: 1));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar('Listening Continuously', actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                showBarModalBottomSheet(
                    context: context,
                    builder: (context) => ListenContinuouslySettingsView());
              })
        ]),
        body: Column(children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Keep your device on this page with the screen on. Your device '
              'will listen for music every minute or so and automatically '
              'scrobble the songs it detects. Duplicate songs will be skipped.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
              child: EntityDisplayComponent<ListenContinuouslyTrack>(
            items: _tracks,
            leadingWidgetBuilder: (track) =>
                Icon(_iconForTrackStatus[track.status]),
            showNoResultsMessage: false,
          ))
        ]),
      );

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
  }
}
