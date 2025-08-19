import 'package:collection/collection.dart';
import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/fractional_bar.dart';
import 'package:finale/widgets/base/future_builder_view.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:flutter/material.dart';

enum _Sort { ordinal, scrobbleCount }

class AlbumScrobblesView extends StatefulWidget {
  final LAlbum album;
  final String? username;

  const AlbumScrobblesView({required this.album, this.username});

  @override
  State<AlbumScrobblesView> createState() => _AlbumScrobblesViewState();
}

class _AlbumScrobblesViewState extends State<AlbumScrobblesView> {
  var _sort = _Sort.ordinal;

  int _comparator(LTrack a, LTrack b) {
    return switch (_sort) {
      _Sort.ordinal => 0,
      _Sort.scrobbleCount => b.userPlayCount.compareTo(a.userPlayCount),
    };
  }

  @override
  Widget build(BuildContext context) => FutureBuilderView<List<LTrack>>(
    futureFactory: () => Future.wait(
      widget.album.tracks.map(
        (track) => Lastfm.getTrack(
          track,
          username: widget.username ?? Preferences.name.value,
        ),
      ),
    ),
    builder: (value) => Scaffold(
      appBar: createAppBar(
        context,
        widget.album.name,
        leadingEntity: widget.album,
        subtitle: pluralize(widget.album.userPlayCount),
      ),
      body: Column(
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SegmentedButton<_Sort>(
                    showSelectedIcon: false,
                    style: minimumSizeButtonStyle,
                    segments: const [
                      ButtonSegment(
                        value: _Sort.ordinal,
                        icon: Icon(Icons.format_list_numbered),
                      ),
                      ButtonSegment(
                        value: _Sort.scrobbleCount,
                        icon: Icon(Icons.numbers),
                      ),
                    ],
                    selected: {_sort},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _sort = newSelection.single;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: EntityDisplay(
              items: value.sorted(_comparator),
              displayImages: false,
              displayNumbers: true,
              detailWidgetBuilder: (track) => TrackView(track: track),
              subtitleWidgetBuilder: FractionalBar.forEntity,
            ),
          ),
        ],
      ),
    ),
  );
}
