import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/collapsible_form_view.dart';
import 'package:finale/widgets/base/date_range_field.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:finale/widgets/entity/entity_checkbox_list.dart';
import 'package:finale/widgets/entity/lastfm/profile_stack.dart';
import 'package:finale/widgets/entity/lastfm/scrobble_filter.dart';
import 'package:finale/widgets/tools/scrobble_manager/scrobble_editor_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ScrobbleSelectorView extends StatefulWidget {
  final void Function(
    List<LRecentTracksResponseTrack> selectedTracks, [
    ScrobbleEditRequest? editRequest,
  ])
  onOperationReady;

  const ScrobbleSelectorView({required this.onOperationReady});

  @override
  State<ScrobbleSelectorView> createState() => _ScrobbleSelectorViewState();
}

class _ScrobbleSelectorViewState extends State<ScrobbleSelectorView> {
  List<LRecentTracksResponseTrack>? _selectedTracks;
  DateTimeRange? _dateRange;
  var _scrobbleFilters = <ScrobbleFilter>[];

  Future<List<LRecentTracksResponseTrack>> _fetchTracks() async {
    setState(() {
      _selectedTracks = null;
    });

    var result =
        await GetRecentTracksRequest(
          Preferences.name.value!,
          from: _dateRange!.start,
          to: _dateRange!.end,
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

    result = result.whereAllFiltersMatch(_scrobbleFilters);

    setState(() {
      _selectedTracks = result;
    });

    return result;
  }

  void _deleteScrobbles() async {
    final confirmation = await showConfirmationDialog(
      context,
      content:
          'Are you sure you want to delete '
          '${pluralize(_selectedTracks!.length)}?',
    );
    if (!confirmation) return;
    widget.onOperationReady(_selectedTracks!);
  }

  void _editScrobbles() async {
    final cutoff = DateTime.now().subtract(
      const Duration(days: 14, minutes: 1),
    );
    if (_selectedTracks!.any((track) => track.date!.isBefore(cutoff))) {
      showMessageDialog(
        context,
        title: 'Error',
        content:
            'Only tracks scrobbled in the last two weeks (since '
            '${dateTimeFormat.format(cutoff)}) can be edited.',
      );
      return;
    }

    final editRequest = await showBarModalBottomSheet<ScrobbleEditRequest>(
      context: context,
      duration: const Duration(milliseconds: 200),
      builder: (_) => ScrobbleEditorView(tracks: _selectedTracks!),
    );
    if (editRequest == null) return;
    widget.onOperationReady(_selectedTracks!, editRequest);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(
      context,
      'Scrobble Manager',
      actions: [
        if (_selectedTracks != null) ...[
          IconButton(
            onPressed: _selectedTracks!.isEmpty ? null : _editScrobbles,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _selectedTracks!.isEmpty ? null : _deleteScrobbles,
            icon: const Icon(Icons.delete),
          ),
        ],
      ],
    ),
    body: CollapsibleFormView<List<LRecentTracksResponseTrack>>(
      submitButtonText: 'Load Scrobbles',
      onFormSubmit: _fetchTracks,
      formWidgetsBuilder:
          (_) => [
            DateRangeField(
              lowerBound: ProfileStack.of(context).me.registered.date,
              onChanged: (dateRange) {
                setState(() {
                  _dateRange = dateRange;
                });
              },
            ),
            ScrobbleFiltersListTile(
              filters: _scrobbleFilters,
              onChanged: (value) {
                setState(() {
                  _scrobbleFilters = value;
                });
              },
            ),
          ],
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
