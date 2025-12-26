import 'package:finale/services/apple_music/playlist.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/spotify/playlist.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/date_time_field.dart';
import 'package:finale/widgets/base/header_list_tile.dart';
import 'package:finale/widgets/entity/entity_checkbox_list.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

enum ScrobbleTimestampBehavior {
  startingNow,
  endingNow,
  startingCustom,
  endingCustom,
}

class BatchScrobbleView extends StatefulWidget {
  final HasTracks entity;

  const BatchScrobbleView({required this.entity});

  @override
  State<StatefulWidget> createState() => _BatchScrobbleViewState();
}

class _BatchScrobbleViewState extends State<BatchScrobbleView> {
  static const _defaultDuration = 60 * 3;

  var _behavior = ScrobbleTimestampBehavior.startingNow;
  DateTime? _customTimestamp;

  late bool _isTracksExpanded;
  late List<ScrobbleableTrack> _selection;

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isTracksExpanded = !widget.entity.hasTrackDurations;
    _selection = widget.entity.tracks;
  }

  Future<void> _scrobble(BuildContext context) async {
    var tracks = _selection;
    List<DateTime> timestamps;

    if (_behavior == .startingNow || _behavior == .startingCustom) {
      timestamps = [_behavior == .startingNow ? .now() : _customTimestamp!];

      for (var track in tracks) {
        timestamps.add(
          timestamps.last.add(
            Duration(seconds: track.duration ?? _defaultDuration),
          ),
        );
      }
    } else {
      timestamps = [_behavior == .endingNow ? .now() : _customTimestamp!];

      tracks = tracks.reversed.toList(growable: false);
      for (var track in tracks) {
        timestamps.add(
          timestamps.last.subtract(
            Duration(seconds: track.duration ?? _defaultDuration),
          ),
        );
      }
    }

    setState(() {
      _isLoading = true;
    });

    final response = await Lastfm.scrobble(tracks, timestamps);

    setState(() {
      _isLoading = false;
    });

    if (!context.mounted) return;
    Navigator.pop(context, response.ignored == 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: createAppBar(
        context,
        'Scrobble',
        actions: [
          Builder(
            builder: (context) => _isLoading
                ? const AppBarLoadingIndicator()
                : IconButton(
                    icon: const Icon(scrobbleIcon),
                    onPressed: _selection.isNotEmpty
                        ? () => _scrobble(context)
                        : null,
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          child: ListView(
            physics: const ScrollPhysics(),
            children: [
              const SizedBox(height: 16),
              ListTile(
                leading: EntityImage(entity: widget.entity),
                title: Text(widget.entity.displayTitle),
                subtitle: widget.entity.displaySubtitle != null
                    ? Text(widget.entity.displaySubtitle!)
                    : null,
                trailing: Text(pluralize(_selection.length, 'track')),
              ),
              if (widget.entity.hasTrackDurations)
                const SizedBox(height: 16)
              else ...[
                Card(
                  margin: const .all(8),
                  child: Padding(
                    padding: const .all(8),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        children: const [
                          TextSpan(text: 'Tracks marked with '),
                          WidgetSpan(child: Icon(Icons.timer_off, size: 16)),
                          TextSpan(
                            text:
                                " don't have duration data. These tracks will "
                                'be treated as having a duration of 3 minutes '
                                'for the purpose of spacing out the scrobbles.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const HeaderListTile('Scrobble timing'),
              RadioGroup(
                groupValue: _behavior,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _behavior = value;
                    });
                  }
                },
                child: const Column(
                  children: [
                    RadioListTile<ScrobbleTimestampBehavior>(
                      value: .startingNow,
                      title: Text('Starting now'),
                    ),
                    RadioListTile<ScrobbleTimestampBehavior>(
                      value: .startingCustom,
                      title: Text('Starting at a custom timestamp'),
                    ),
                    RadioListTile<ScrobbleTimestampBehavior>(
                      value: .endingNow,
                      title: Text('Ending now'),
                    ),
                    RadioListTile<ScrobbleTimestampBehavior>(
                      value: .endingCustom,
                      title: Text('Ending at a custom timestamp'),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible:
                    _behavior == .startingCustom || _behavior == .endingCustom,
                child: Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: DateTimeField(
                    initialValue: _customTimestamp,
                    onChanged: (dateTime) {
                      setState(() {
                        _customTimestamp = dateTime;
                      });
                    },
                  ),
                ),
              ),
              ExpansionPanelList(
                expandedHeaderPadding: .zero,
                expansionCallback: (_, isExpanded) {
                  setState(() {
                    _isTracksExpanded = isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (_, _) =>
                        const ListTile(title: Text('Tracks')),
                    canTapOnHeader: true,
                    isExpanded: _isTracksExpanded,
                    body: EntityCheckboxList<ScrobbleableTrack>(
                      items: widget.entity.tracks,
                      displayImages:
                          widget.entity is SPlaylistFull ||
                          widget.entity is AMFullPlaylist,
                      scrollable: false,
                      onSelectionChanged: (selection) {
                        setState(() {
                          _selection = selection;
                        });
                      },
                      trailingWidgetBuilder: (track) => track.duration == null
                          ? const Icon(Icons.timer_off)
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
