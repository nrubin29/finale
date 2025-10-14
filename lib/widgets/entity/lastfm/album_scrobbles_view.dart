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

  Future<LAlbum> _loadAlbum() async {
    final username = widget.username ?? Preferences.name.value!;
    return widget.username == null
        ? widget.album
        : await Lastfm.getAlbum(widget.album, username: username);
  }

  Future<List<LTrack>> _loadTracks(LAlbum album) async {
    final username = widget.username ?? Preferences.name.value!;

    return [
      for (final track in album.tracks)
        await Lastfm.getTrack(track, username: username),
    ];
  }

  int _comparator(LTrack a, LTrack b) {
    return switch (_sort) {
      _Sort.ordinal => 0,
      _Sort.scrobbleCount => b.userPlayCount.compareTo(a.userPlayCount),
    };
  }

  @override
  Widget build(BuildContext context) => FutureBuilderView<LAlbum>(
    futureFactory: _loadAlbum,
    baseEntity: widget.album,
    builder: (album) => Scaffold(
      appBar: createAppBar(
        context,
        album.name,
        leadingEntity: album,
        subtitle: pluralize(album.userPlayCount),
      ),
      body: FutureBuilderView(
        futureFactory: () => _loadTracks(album),
        isView: false,
        builder: (tracks) => Column(
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
                items: tracks.sorted(_comparator),
                displayImages: false,
                displayNumbers: true,
                detailWidgetBuilder: (track) => TrackView(track: track),
                subtitleWidgetBuilder: FractionalBar.forEntity,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
