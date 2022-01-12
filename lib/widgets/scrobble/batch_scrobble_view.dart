import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/date_time_field.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

enum ScrobbleTimestampBehavior {
  startingNow,
  endingNow,
  startingCustom,
  endingCustom
}

class BatchScrobbleView extends StatefulWidget {
  final HasTracks entity;

  BatchScrobbleView({required this.entity}) : assert(entity.canScrobble);

  @override
  State<StatefulWidget> createState() => _BatchScrobbleViewState();
}

class _BatchScrobbleViewState extends State<BatchScrobbleView> {
  var _behavior = ScrobbleTimestampBehavior.startingNow;
  DateTime? _customTimestamp;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _scrobble(BuildContext context) async {
    var tracks = widget.entity.tracks;
    List<DateTime> timestamps;

    if (_behavior == ScrobbleTimestampBehavior.startingNow ||
        _behavior == ScrobbleTimestampBehavior.startingCustom) {
      timestamps = [
        _behavior == ScrobbleTimestampBehavior.startingNow
            ? DateTime.now()
            : _customTimestamp!
      ];

      for (var track in tracks) {
        timestamps.add(timestamps.last.add(Duration(seconds: track.duration!)));
      }
    } else {
      timestamps = [
        _behavior == ScrobbleTimestampBehavior.endingNow
            ? DateTime.now()
            : _customTimestamp!
      ];

      tracks = tracks.reversed.toList(growable: false);
      for (var track in tracks) {
        timestamps
            .add(timestamps.last.subtract(Duration(seconds: track.duration!)));
      }
    }

    final response = await Lastfm.scrobble(tracks, timestamps);
    Navigator.pop(context, response.ignored == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
        'Scrobble',
        actions: [
          Builder(
              builder: (context) => IconButton(
                  icon: const Icon(scrobbleIcon),
                  onPressed: () => _scrobble(context)))
        ],
      ),
      body: SafeArea(
        child: Form(
          child: ListView(
            padding: const EdgeInsets.all(10),
            physics: const ScrollPhysics(),
            children: [
              ListTile(
                leading: EntityImage(entity: widget.entity),
                title: Text(widget.entity.displayTitle),
                subtitle: widget.entity.displaySubtitle != null
                    ? Text(widget.entity.displaySubtitle!)
                    : null,
                trailing:
                    Text(formatScrobbles(widget.entity.tracks.length, 'track')),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Scrobble behavior',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Theme.of(context).textTheme.caption!.color),
                ),
              ),
              RadioListTile<ScrobbleTimestampBehavior>(
                value: ScrobbleTimestampBehavior.startingNow,
                groupValue: _behavior,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _behavior = value;
                    });
                  }
                },
                title: const Text('Starting now'),
              ),
              RadioListTile<ScrobbleTimestampBehavior>(
                value: ScrobbleTimestampBehavior.startingCustom,
                groupValue: _behavior,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _behavior = value;
                      _customTimestamp = DateTime.now();
                    });
                  }
                },
                title: const Text('Starting at a custom timestamp'),
              ),
              RadioListTile<ScrobbleTimestampBehavior>(
                value: ScrobbleTimestampBehavior.endingNow,
                groupValue: _behavior,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _behavior = value;
                    });
                  }
                },
                title: const Text('Ending now'),
              ),
              RadioListTile<ScrobbleTimestampBehavior>(
                value: ScrobbleTimestampBehavior.endingCustom,
                groupValue: _behavior,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _behavior = value;
                      _customTimestamp = DateTime.now();
                    });
                  }
                },
                title: const Text('Ending at a custom timestamp'),
              ),
              Visibility(
                visible:
                    _behavior == ScrobbleTimestampBehavior.startingCustom ||
                        _behavior == ScrobbleTimestampBehavior.endingCustom,
                child: DateTimeField(
                  initialValue: _customTimestamp,
                  onChanged: (dateTime) {
                    setState(() {
                      _customTimestamp = dateTime;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
