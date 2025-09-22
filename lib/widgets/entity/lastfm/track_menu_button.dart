import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/functions.dart';
import 'package:finale/widgets/entity/lastfm/cookie_dialog.dart';
import 'package:finale/widgets/entity/lastfm/set_obsession_button.dart';
import 'package:finale/widgets/tools/scrobble_manager/scrobble_editor_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TrackMenuButton extends StatelessWidget {
  final LRecentTracksResponseTrack track;
  final bool enabled;
  final void Function(LRecentTracksResponseTrack track) onTrackChange;

  const TrackMenuButton({
    required this.track,
    required this.enabled,
    required this.onTrackChange,
  });

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
      if (isMobile) ...[
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.star),
            title: Text('Set as obsession'),
          ),
          onTap: () {
            setObsessionInUi(context, track);
          },
        ),
        if (track.date != null) ...[
          if (DateTime.now().difference(track.date!) < const Duration(days: 14))
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit scrobble'),
              ),
              onTap: () async {
                if (!await ensureCookies(context)) {
                  return;
                }

                if (!context.mounted) return;
                final request = await showBarModalBottomSheet(
                  context: context,
                  builder: (_) =>
                      ScrobbleEditorView.forSingleScrobble(track: track),
                );
                if (request == null) return;
                if (await LastfmCookie.editScrobble(track, request)) {
                  onTrackChange(track.copyWith(isEdited: true));
                }
              },
            ),
          PopupMenuItem(
            child: const ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete scrobble'),
            ),
            onTap: () async {
              if (!await ensureCookies(context)) {
                return;
              }

              if (!context.mounted) return;
              if (await LastfmCookie.deleteScrobble(track)) {
                onTrackChange(track.copyWith(isDeleted: true));
              }
            },
          ),
        ],
      ],
    ];
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton(
    itemBuilder: _buildItems,
    tooltip: 'Actions',
    enabled: enabled,
    child: const Icon(Icons.more_vert, color: Colors.grey),
  );
}
