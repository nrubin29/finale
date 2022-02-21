import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/date_time_field.dart';
import 'package:finale/widgets/base/list_tile_text_field.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/base/now_playing_animation.dart';
import 'package:finale/widgets/entity/entity_checkbox_list.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class FriendScrobbleView extends StatefulWidget {
  final String? username;

  const FriendScrobbleView({this.username});

  @override
  _FriendScrobbleViewState createState() => _FriendScrobbleViewState();
}

class _FriendScrobbleViewState extends State<FriendScrobbleView> {
  var _isSettingsExpanded = true;
  late TextEditingController _usernameTextController;
  DateTime? _start;
  DateTime? _end;

  var _isLoading = false;
  List<LRecentTracksResponseTrack>? _items;
  List<LRecentTracksResponseTrack>? _selection;

  @override
  void initState() {
    super.initState();
    _usernameTextController = TextEditingController(text: widget.username);
  }

  bool get _hasItemsToScrobble => _selection?.isNotEmpty ?? false;

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isSettingsExpanded = false;
    });

    List<LRecentTracksResponseTrack>? response;

    try {
      response = await GetRecentTracksRequest(_usernameTextController.text,
              from: _start, to: _end)
          .getAllData();
    } on LException catch (e) {
      if (e.code == 6) {
        response = <LRecentTracksResponseTrack>[];
      } else {
        rethrow;
      }
    }

    setState(() {
      if (response != null) {
        _items = response;
        _selection = response;
      }

      _isLoading = false;
    });
  }

  Future<void> _scrobble() async {
    final response = await Lastfm.scrobble(
        _selection!,
        _selection!
            .map((track) => track.timestamp?.date ?? DateTime.now())
            .toList(growable: false));

    if (response.ignored == 0) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scrobbled successfully!')));

      // Ask for a review
      if (await InAppReview.instance.isAvailable()) {
        InAppReview.instance.requestReview();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while scrobbling')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar(
          'Scrobble from a friend',
          actions: [
            IconButton(
              icon: const Icon(scrobbleIcon),
              onPressed: _hasItemsToScrobble ? _scrobble : null,
            ),
          ],
        ),
        body: Column(
          children: [
            ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (_, __) {
                setState(() {
                  _isSettingsExpanded = !_isSettingsExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (_, __) =>
                      const ListTile(title: Text('Settings')),
                  canTapOnHeader: true,
                  isExpanded: _isSettingsExpanded,
                  body: Column(
                    children: [
                      ListTileTextField(
                        title: 'Username',
                        controller: _usernameTextController,
                      ),
                      SafeArea(
                        top: false,
                        bottom: false,
                        minimum: const EdgeInsets.symmetric(horizontal: 16),
                        child: DateTimeField(
                          label: 'Start',
                          initialValue: _start,
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
                          onChanged: (dateTime) {
                            setState(() {
                              _end = dateTime;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: OutlinedButton(
                          onPressed: _usernameTextController.text.isNotEmpty &&
                                  _start != null &&
                                  _end != null &&
                                  _start!.isBefore(_end!)
                              ? _loadData
                              : null,
                          child: const Text('Load Scrobbles'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Expanded(child: LoadingComponent())
            else if (_items != null)
              Expanded(
                child: EntityCheckboxList<LRecentTracksResponseTrack>(
                  items: _items!,
                  onSelectionChanged: (selection) {
                    _selection = selection;
                  },
                  trailingWidgetBuilder: (track) => track.timestamp != null
                      ? const SizedBox()
                      : const NowPlayingAnimation(),
                ),
              ),
          ],
        ),
      );

  @override
  void dispose() {
    _usernameTextController.dispose();
    super.dispose();
  }
}
