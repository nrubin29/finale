import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/widgets/tools/scrobble_manager/scrobble_modification_view.dart';
import 'package:finale/widgets/tools/scrobble_manager/scrobble_selector_view.dart';
import 'package:flutter/material.dart';

enum _Mode { select, modify }

class ScrobbleManagerView extends StatefulWidget {
  const ScrobbleManagerView();

  @override
  State<ScrobbleManagerView> createState() => _ScrobbleManagerViewState();
}

class _ScrobbleManagerViewState extends State<ScrobbleManagerView> {
  var _mode = _Mode.select;
  List<LRecentTracksResponseTrack>? _selectedTracks;
  ScrobbleEditRequest? _editRequest;

  void _changeModeToModify(
    List<LRecentTracksResponseTrack> selectedTracks, [
    ScrobbleEditRequest? editRequest,
  ]) {
    setState(() {
      _selectedTracks = selectedTracks;
      _editRequest = editRequest;
      _mode = _Mode.modify;
    });
  }

  @override
  Widget build(BuildContext context) => switch (_mode) {
    _Mode.select => ScrobbleSelectorView(onOperationReady: _changeModeToModify),
    _Mode.modify => ScrobbleModificationView(
      selectedTracks: _selectedTracks!,
      editRequest: _editRequest,
    ),
  };
}
