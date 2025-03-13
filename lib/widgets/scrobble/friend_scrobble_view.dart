import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/collapsible_form_view.dart';
import 'package:finale/widgets/base/date_time_field.dart';
import 'package:finale/widgets/base/list_tile_text_field.dart';
import 'package:finale/widgets/base/now_playing_animation.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:finale/widgets/entity/entity_checkbox_list.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class FriendScrobbleView extends StatefulWidget {
  final String? username;

  const FriendScrobbleView({this.username});

  @override
  State<StatefulWidget> createState() => _FriendScrobbleViewState();
}

class _FriendScrobbleViewState extends State<FriendScrobbleView> {
  late TextEditingController _usernameTextController;
  DateTime? _start;
  DateTime? _end;

  List<LRecentTracksResponseTrack>? _selection;

  @override
  void initState() {
    super.initState();
    _usernameTextController = TextEditingController(text: widget.username);
  }

  bool get _hasItemsToScrobble => _selection?.isNotEmpty ?? false;

  Future<List<LRecentTracksResponseTrack>?> _loadData() async {
    setState(() {
      _selection = null;
    });

    final username = _usernameTextController.text;
    List<LRecentTracksResponseTrack> response;

    try {
      response =
          await GetRecentTracksRequest(
            username,
            from: _start,
            to: _end,
          ).getAllData();
    } on LException catch (e) {
      if (e.code == 6) {
        response = <LRecentTracksResponseTrack>[];
      } else {
        rethrow;
      }
    }

    if (response.isEmpty) {
      showNoEntityTypePeriodDialog(
        context,
        entityType: EntityType.track,
        username: username,
      );
      return null;
    }

    setState(() {
      _selection = response;
    });

    return response;
  }

  Future<void> _scrobble() async {
    final response = await Lastfm.scrobble(
      _selection!,
      _selection!
          .map((track) => track.timestamp?.date ?? DateTime.now())
          .toList(growable: false),
    );

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

  String? _validator(Object? value) {
    if (value == null || (value is String && value.isEmpty)) {
      return 'This field is required.';
    } else if (value is DateTime &&
        (_start == null || _end == null || !_start!.isBefore(_end!))) {
      return 'Start must be before end.';
    }

    return null;
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
      formWidgetsBuilder:
          (_) => [
            ListTileTextField(
              title: 'Username',
              controller: _usernameTextController,
              validator: _validator,
            ),
            SafeArea(
              top: false,
              bottom: false,
              minimum: const EdgeInsets.symmetric(horizontal: 16),
              child: DateTimeField(
                label: 'Start',
                initialValue: _start,
                validator: _validator,
                onChanged: (dateTime) {
                  setState(() {
                    _start = dateTime;
                  });
                },
              ),
            ),
            SafeArea(
              top: false,
              bottom: false,
              minimum: const EdgeInsets.symmetric(horizontal: 16),
              child: DateTimeField(
                label: 'End',
                initialValue: _end,
                validator: _validator,
                onChanged: (dateTime) {
                  setState(() {
                    _end = dateTime;
                  });
                },
              ),
            ),
          ],
      bodyBuilder:
          (_, items) => EntityCheckboxList<LRecentTracksResponseTrack>(
            items: items,
            scrollable: false,
            onSelectionChanged: (selection) {
              setState(() {
                _selection = selection;
              });
            },
            trailingWidgetBuilder:
                (track) =>
                    track.timestamp != null
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
