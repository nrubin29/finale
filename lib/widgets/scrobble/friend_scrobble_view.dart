import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/date_time_field.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class FriendScrobbleView extends StatefulWidget {
  final LUser user;

  const FriendScrobbleView({required this.user});

  @override
  _FriendScrobbleViewState createState() =>
      _FriendScrobbleViewState();
}

class _FriendScrobbleViewState extends State<FriendScrobbleView> {
  var _isSettingsExpanded = true;
  DateTime? _start;
  DateTime? _end;

  var _isLoading = false;
  Map<LRecentTracksResponseTrack, bool>? _items;

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isSettingsExpanded = false;
    });

    final response =
        await GetRecentTracksRequest(widget.user.name, from: _start, to: _end)
            .getAllData();

    setState(() {
      _items = Map.fromIterable(response, value: (_) => true);
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
          'Scrobble from ${widget.user.name}',
          actions: [
            if (_items?.isNotEmpty ?? false)
              IconButton(
                icon: const Icon(scrobbleIcon),
                onPressed: _scrobble,
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
                      const ListTile(title: Text('Time Range')),
                  canTapOnHeader: true,
                  isExpanded: _isSettingsExpanded,
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        DateTimeField(
                          label: 'Start',
                          initialValue: _start,
                          onChanged: (dateTime) {
                            setState(() {
                              _start = dateTime;
                            });
                          },
                        ),
                        DateTimeField(
                          label: 'End',
                          initialValue: _end,
                          onChanged: (dateTime) {
                            setState(() {
                              _end = dateTime;
                            });
                          },
                        ),
                        if (_start != null &&
                            _end != null &&
                            _start!.isBefore(_end!))
                          TextButton(
                            onPressed: _loadData,
                            child: const Text('Load Scrobbles'),
                          ),
                      ],
                    ),
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
}
