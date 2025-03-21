import 'package:finale/services/lastfm/track.dart';
import 'package:finale/widgets/base/list_tile_text_field.dart';
import 'package:finale/widgets/base/string_filter_form.dart';
import 'package:flutter/material.dart';

enum ScrobbleField {
  title('Title'),
  artist('Artist'),
  album('Album');

  final String displayName;

  const ScrobbleField(this.displayName);
}

class ScrobbleFilter {
  final ScrobbleField field;
  final StringFilter filter;

  const ScrobbleFilter({required this.field, required this.filter});

  bool matches(LRecentTracksResponseTrack track) => switch (field) {
    ScrobbleField.title => filter.matches(track.name),
    ScrobbleField.album => filter.matches(track.albumName),
    ScrobbleField.artist => filter.matches(track.artistName),
  };

  @override
  String toString() => '${field.displayName} $filter';
}

Future<ScrobbleFilter?> _showScrobbleFilterDialog(
  BuildContext context, {
  ScrobbleFilter? initialValue,
}) => showDialog<ScrobbleFilter>(
  context: context,
  builder: (_) => _ScrobbleFilterDialog(initialValue: initialValue),
);

class _ScrobbleFilterDialog extends StatefulWidget {
  final ScrobbleFilter? initialValue;

  const _ScrobbleFilterDialog({this.initialValue});

  @override
  State<_ScrobbleFilterDialog> createState() => _ScrobbleFilterDialogState();
}

class _ScrobbleFilterDialogState extends State<_ScrobbleFilterDialog> {
  late ScrobbleField _field;
  late StringFilter _stringFilter;

  @override
  void initState() {
    super.initState();
    _field = widget.initialValue?.field ?? ScrobbleField.title;
    _stringFilter = widget.initialValue?.filter ?? const StringFilter();
  }

  void _save() {
    ScrobbleFilter? filter;
    if (_stringFilter.value.isNotEmpty) {
      filter = ScrobbleFilter(field: _field, filter: _stringFilter);
    }

    Navigator.pop(context, filter);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Filter'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('Field'),
          trailing: DropdownButton<ScrobbleField>(
            value: _field,
            items: [
              for (final target in ScrobbleField.values)
                DropdownMenuItem(
                  value: target,
                  child: Text(target.displayName),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              _field = value;
            },
          ),
        ),
        StringFilterForm(
          filter: _stringFilter,
          onFilterChanged: (filter) {
            setState(() {
              _stringFilter = filter;
            });
          },
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },

        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: _stringFilter.value.isEmpty ? null : _save,
        child: const Text('Save'),
      ),
    ],
  );
}

class ScrobbleFiltersListTile extends StatelessWidget {
  final List<ScrobbleFilter> filters;
  final void Function(List<ScrobbleFilter>) onChanged;

  const ScrobbleFiltersListTile({
    required this.filters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => CustomListTile(
    title: 'Filters',
    trailing: SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await _showScrobbleFilterDialog(context);
              if (result == null) return;
              onChanged([...filters, result]);
            },
          ),
          for (final (i, filter) in filters.indexed)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InputChip(
                label: Text('$filter'),
                onPressed: () async {
                  final result = await _showScrobbleFilterDialog(
                    context,
                    initialValue: filter,
                  );
                  if (result == null) return;

                  final newFilters = [...filters];
                  newFilters[i] = result;
                  onChanged(newFilters);
                },
                onDeleted: () {
                  onChanged([...filters]..removeAt(i));
                },
              ),
            ),
        ],
      ),
    ),
  );
}

extension WhereAllFiltersMatch on List<LRecentTracksResponseTrack> {
  List<LRecentTracksResponseTrack> whereAllFiltersMatch(
    List<ScrobbleFilter> filters,
  ) =>
      isEmpty || filters.isEmpty
          ? this
          : where(
            (track) => filters.every((predicate) => predicate.matches(track)),
          ).toList(growable: false);
}
