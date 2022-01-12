import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/date_time_field.dart';
import 'package:finale/widgets/base/list_tile_text_field.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/entity/entity_display.dart';
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
  Map<LRecentTracksResponseTrack, bool>? _items;

  @override
  void initState() {
    super.initState();
    _usernameTextController = TextEditingController(text: widget.username);
  }

  bool get _hasItemsToScrobble =>
      _items != null && _items!.isNotEmpty && _items!.values.any((e) => e);

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
        _items = Map.fromIterable(response, value: (_) => true);
      }

      _isLoading = false;
    });
  }

  Future<void> _scrobble() async {
    final tracks = _items!.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList(growable: false);

    final response = await Lastfm.scrobble(
        tracks,
        tracks
            .map((track) => track.timestamp?.date ?? DateTime.now())
            .toList(growable: false));

    if (response.ignored == 0) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scrobbled successfully!')));

      // Ask for a review
      if (!isWeb && await InAppReview.instance.isAvailable()) {
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
                child: EntityDisplay<LRecentTracksResponseTrack>(
                  items: _items!.keys.toList(growable: false),
                  leadingWidgetBuilder: (item) => Checkbox(
                    value: _items![item],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _items![item] = value;
                        });
                      }
                    },
                  ),
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
