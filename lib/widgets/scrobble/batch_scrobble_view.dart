import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
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
                activeColor: Colors.red,
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
                activeColor: Colors.red,
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
                activeColor: Colors.red,
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
                activeColor: Colors.red,
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
                  decoration: const InputDecoration(labelText: 'Timestamp'),
                  resetIcon: null,
                  format: dateTimeFormatWithYear,
                  initialValue: _customTimestamp,
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                        context: context,
                        initialDate: currentValue ?? DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 14)),
                        lastDate: DateTime.now().add(const Duration(days: 1)));

                    if (date != null) {
                      final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()));

                      if (time != null) {
                        return DateTimeField.combine(date, time);
                      }
                    }

                    return currentValue;
                  },
                  onChanged: (dateTime) {
                    if (dateTime != null) {
                      setState(() {
                        _customTimestamp = dateTime;
                      });
                    }
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
