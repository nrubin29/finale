import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:flutter/material.dart';

enum _ScrobbleStatus { pending, processing, success, error }

class _Scrobble extends BasicScrobbledTrack {
  var _status = _ScrobbleStatus.pending;

  _Scrobble(LRecentTracksResponseTrack track)
    : name = track.name,
      artistName = track.artistName,
      albumName = track.albumName,
      albumArtist = track.albumArtist,
      url = track.url,
      imageId = track.imageId,
      date = track.date {
    cachedImageId = track.cachedImageId;
  }

  @override
  final String name;

  @override
  final String artistName;

  @override
  final String albumName;

  @override
  final String? albumArtist;

  @override
  final String url;

  @override
  final ImageId? imageId;

  @override
  final DateTime? date;

  @override
  String? get displayTrailing =>
      _status == _ScrobbleStatus.pending ? 'Pending' : null;
}

class ScrobbleModificationView extends StatefulWidget {
  final List<LRecentTracksResponseTrack> selectedTracks;
  final ScrobbleEditRequest? editRequest;

  const ScrobbleModificationView({
    required this.selectedTracks,
    this.editRequest,
  });

  @override
  State<ScrobbleModificationView> createState() =>
      _ScrobbleModificationViewState();
}

class _ScrobbleModificationViewState extends State<ScrobbleModificationView> {
  late final List<_Scrobble> _scrobbles;

  @override
  void initState() {
    super.initState();
    _scrobbles = widget.selectedTracks
        .map(_Scrobble.new)
        .toList(growable: false);
    start();
  }

  void start() async {
    for (final scrobble in _scrobbles) {
      setState(() {
        scrobble._status = _ScrobbleStatus.processing;
      });

      bool success;

      if (widget.editRequest case ScrobbleEditRequest request) {
        success = await LastfmCookie.editScrobble(scrobble, request);
      } else {
        success = await LastfmCookie.deleteScrobble(scrobble);
      }

      setState(() {
        scrobble._status = success
            ? _ScrobbleStatus.success
            : _ScrobbleStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(
      context,
      widget.editRequest == null
          ? 'Deleting scrobbles...'
          : 'Editing scrobbles...',
    ),
    body: EntityDisplay(
      items: _scrobbles,
      trailingWidgetBuilder: (item) => switch (item._status) {
        _ScrobbleStatus.pending => const SizedBox(),
        _ScrobbleStatus.processing => const LoadingComponent.small(),
        _ScrobbleStatus.success => const Icon(Icons.check),
        _ScrobbleStatus.error => const Icon(Icons.error),
      },
    ),
  );
}
