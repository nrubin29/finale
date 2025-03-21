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
  final LRecentTracksResponseTrack _track;
  var _status = _ScrobbleStatus.pending;

  _Scrobble(this._track) {
    cachedImageId = _track.cachedImageId;
  }

  @override
  String get name => _track.name;

  @override
  String get artistName => _track.artistName;

  @override
  String get albumName => _track.albumName;

  @override
  String? get albumArtist => _track.albumArtist;

  @override
  String get url => _track.url;

  @override
  ImageId? get imageId => _track.imageId;

  @override
  DateTime? get date => _track.date;

  @override
  String? get displayTrailing =>
      _status == _ScrobbleStatus.pending ? 'Pending' : null;
}

class ScrobbleModificationView extends StatefulWidget {
  final List<LRecentTracksResponseTrack> selectedTracks;

  const ScrobbleModificationView({required this.selectedTracks});

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

      final success = await LastfmCookie.deleteScrobble(scrobble);

      setState(() {
        scrobble._status =
            success ? _ScrobbleStatus.success : _ScrobbleStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(context, 'Deleting scrobbles...'),
    body: EntityDisplay(
      items: _scrobbles,
      trailingWidgetBuilder:
          (item) => switch (item._status) {
            _ScrobbleStatus.pending => const SizedBox(),
            _ScrobbleStatus.processing => const LoadingComponent.small(),
            _ScrobbleStatus.success => const Icon(Icons.check),
            _ScrobbleStatus.error => const Icon(Icons.error),
          },
    ),
  );
}
