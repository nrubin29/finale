import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/functions.dart';
import 'package:flutter/material.dart';

class TrackMenuButton extends StatelessWidget {
  final LRecentTracksResponseTrack track;
  final void Function(LRecentTracksResponseTrack track) onTrackChange;

  const TrackMenuButton({required this.track, required this.onTrackChange});

  List<PopupMenuEntry> _buildItems(BuildContext context) {
    return [
      PopupMenuItem(
        child: const ListTile(
          leading: Icon(Icons.people),
          title: Text('Go to artist'),
        ),
        onTap: () {
          pushLastfmEntityDetailView(context, track.artist);
        },
      ),
      PopupMenuItem(
        child: const ListTile(
          leading: Icon(Icons.album),
          title: Text('Go to album'),
        ),
        onTap: () {
          pushLastfmEntityDetailView(context, track.album);
        },
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        child: ListTile(
          leading: track.isLoved
              ? const Icon(Icons.favorite_border)
              : const Icon(Icons.favorite),
          title: track.isLoved ? const Text('Unlove') : const Text('Love'),
        ),
        onTap: () async {
          final newState = !track.isLoved;
          final success = await Lastfm.love(track, newState);

          if (success) {
            onTrackChange(track.copyWith(isLoved: newState));
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton(
    itemBuilder: _buildItems,
    tooltip: 'Actions',
    child: const Icon(Icons.more_vert),
  );
}
