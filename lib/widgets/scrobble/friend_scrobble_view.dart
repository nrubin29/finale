import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/collapsible_form_view.dart';
import 'package:finale/widgets/base/date_range_field.dart';
import 'package:finale/widgets/base/list_tile_username_field.dart';
import 'package:finale/widgets/base/now_playing_animation.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:finale/widgets/entity/entity_checkbox_list.dart';
import 'package:finale/widgets/entity/lastfm/scrobble_filter.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class FriendScrobbleView extends StatefulWidget {
  final String? username;

  const FriendScrobbleView({this.username});

  @override
  State<StatefulWidget> createState() => _FriendScrobbleViewState();
}

class _FriendScrobbleViewState extends State<FriendScrobbleView> {
  late final _usernameTextController = TextEditingController(
    text: widget.username,
  );
  DateTimeRange? _dateRange;
  var _filters = <ScrobbleFilter>[];

  List<LRecentTracksResponseTrack>? _selection;

  bool get _hasItemsToScrobble => _selection?.isNotEmpty ?? false;

  Future<List<LRecentTracksResponseTrack>?> _loadData() async {
    setState(() {
      _selection = null;
    });

    final username = _usernameTextController.text;
    List<LRecentTracksResponseTrack> response;

    try {
      response = await GetRecentTracksRequest(
        username,
        from: _dateRange!.start,
        to: _dateRange!.end,
        includeCurrentScrobble: true,
      ).getAllData();
    } on LException catch (e) {
      if (e.code == 6) {
        response = <LRecentTracksResponseTrack>[];
      } else {
        rethrow;
      }
    }

    if (response.isEmpty) {
      if (!mounted) return null;
      showNoEntityTypePeriodDialog(
        context,
        entityType: .track,
        username: username,
      );
      return null;
    }

    response = response.whereAllFiltersMatch(_filters);

    setState(() {
      _selection = response;
    });

    return response;
  }

  Future<void> _scrobble() async {
    final response = await Lastfm.scrobble(
      _selection!,
      _selection!
          .map((track) => track.timestamp?.date ?? .now())
          .toList(growable: false),
    );

    if (!mounted) return;
    if (response.ignored == 0) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Scrobbled successfully!')));

      // Ask for a review
      if (await InAppReview.instance.isAvailable()) {
        InAppReview.instance.requestReview();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while scrobbling')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(
      context,
      'Scrobble from a friend',
      actions: [
        IconButton(
          icon: const Icon(scrobbleIcon),
          onPressed: _hasItemsToScrobble ? _scrobble : null,
        ),
      ],
    ),
    body: CollapsibleFormView<List<LRecentTracksResponseTrack>>(
      submitButtonText: 'Load Scrobbles',
      onFormSubmit: _loadData,
      formWidgetsBuilder: (_) => [
        ListTileUsernameField(
          controller: _usernameTextController,
          includeSelf: false,
        ),
        DateRangeField(
          onChanged: (dateRange) {
            setState(() {
              _dateRange = dateRange;
            });
          },
        ),
        ScrobbleFiltersListTile(
          filters: _filters,
          onChanged: (value) {
            setState(() {
              _filters = value;
            });
          },
        ),
      ],
      bodyBuilder: (_, items) => EntityCheckboxList<LRecentTracksResponseTrack>(
        items: items,
        scrollable: false,
        onSelectionChanged: (selection) {
          setState(() {
            _selection = selection;
          });
        },
        trailingWidgetBuilder: (track) => track.timestamp != null
            ? const SizedBox()
            : const NowPlayingAnimation(),
      ),
    ),
  );

  @override
  void dispose() {
    _usernameTextController.dispose();
    super.dispose();
  }
}
