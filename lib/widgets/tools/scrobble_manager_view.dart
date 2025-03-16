import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/collapsible_form_view.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:finale/widgets/entity/entity_checkbox_list.dart';
import 'package:flutter/material.dart';

class ScrobbleManagerView extends StatefulWidget {
  const ScrobbleManagerView();

  @override
  State<ScrobbleManagerView> createState() => _ScrobbleManagerViewState();
}

class _ScrobbleManagerViewState extends State<ScrobbleManagerView> {
  List<LRecentTracksResponseTrack>? _selectedTracks;

  Future<List<LRecentTracksResponseTrack>> _fetchTracks() async {
    setState(() {
      _selectedTracks = null;
    });

    final result =
        await GetRecentTracksRequest(
          Preferences.name.value!,
          from: DateTime.now().subtract(const Duration(days: 1)),
        ).getAllData();

    if (result.isEmpty) {
      if (!mounted) return const [];
      showNoEntityTypePeriodDialog(
        context,
        entityType: EntityType.track,
        username: Preferences.name.value!,
      );
      return const [];
    }

    setState(() {
      _selectedTracks = result;
    });

    return result;
  }

  void _deleteScrobbles() {}

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(
      context,
      'Scrobble Manager',
      actions: [
        if (_selectedTracks != null)
          IconButton(
            onPressed: _selectedTracks!.isEmpty ? null : _deleteScrobbles,
            icon: const Icon(Icons.delete),
          ),
      ],
    ),
    body: CollapsibleFormView<List<LRecentTracksResponseTrack>>(
      submitButtonText: 'Load Scrobbles',
      onFormSubmit: _fetchTracks,
      formWidgetsBuilder: (_) => [],
      bodyBuilder:
          (_, tracks) => EntityCheckboxList<LRecentTracksResponseTrack>(
            scrollable: false,
            items: tracks,
            onSelectionChanged: (selection) {
              setState(() {
                _selectedTracks = selection;
              });
            },
          ),
    ),
  );
}
