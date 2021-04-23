import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/lastfm.dart';
import 'package:finale/types/generic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ScrobbleTimestampBehavior {
  startingNow,
  endingNow,
  startingCustom,
  endingCustom
}

class ScrobbleAlbumView extends StatefulWidget {
  final FullAlbum album;

  ScrobbleAlbumView({this.album});

  @override
  State<StatefulWidget> createState() => _ScrobbleAlbumViewState();
}

class _ScrobbleAlbumViewState extends State<ScrobbleAlbumView> {
  var _behavior = ScrobbleTimestampBehavior.startingNow;
  DateTime _customTimestamp;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _scrobble(BuildContext context) async {
    List<BasicScrobbleableTrack> tracks = widget.album.tracks;
    List<DateTime> timestamps;

    if (_behavior == ScrobbleTimestampBehavior.startingNow ||
        _behavior == ScrobbleTimestampBehavior.startingCustom) {
      timestamps = [
        _behavior == ScrobbleTimestampBehavior.startingNow
            ? DateTime.now()
            : _customTimestamp
      ];

      tracks.forEach((track) {
        timestamps.add(timestamps.last.add(Duration(seconds: track.duration)));
      });
    } else {
      timestamps = [
        _behavior == ScrobbleTimestampBehavior.endingNow
            ? DateTime.now()
            : _customTimestamp
      ];

      tracks = tracks.reversed.toList(growable: false);
      tracks.forEach((track) {
        timestamps
            .add(timestamps.last.subtract(Duration(seconds: track.duration)));
      });
    }

    final response = await Lastfm.scrobble(tracks, timestamps);
    Navigator.pop(context, response.ignored == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Scrobble'),
          actions: [
            Builder(
                builder: (context) => IconButton(
                    icon: Icon(Icons.add), onPressed: () => _scrobble(context)))
          ],
        ),
        body: Form(
            child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                        leading: ImageComponent(displayable: widget.album),
                        title: Text(widget.album.name),
                        subtitle: Text(widget.album.artist.name)),
                    SizedBox(height: 10),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Scrobble behavior',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .color))),
                    RadioListTile(
                        activeColor: Colors.red,
                        value: ScrobbleTimestampBehavior.startingNow,
                        groupValue: _behavior,
                        onChanged: (value) => setState(() => _behavior = value),
                        title: Text('Starting now')),
                    RadioListTile(
                        activeColor: Colors.red,
                        value: ScrobbleTimestampBehavior.startingCustom,
                        groupValue: _behavior,
                        onChanged: (value) => setState(() {
                              _behavior = value;
                              _customTimestamp = DateTime.now();
                            }),
                        title: Text('Starting at a custom timestamp')),
                    RadioListTile(
                        activeColor: Colors.red,
                        value: ScrobbleTimestampBehavior.endingNow,
                        groupValue: _behavior,
                        onChanged: (value) => setState(() => _behavior = value),
                        title: Text('Ending now')),
                    RadioListTile(
                        activeColor: Colors.red,
                        value: ScrobbleTimestampBehavior.endingCustom,
                        groupValue: _behavior,
                        onChanged: (value) => setState(() {
                              _behavior = value;
                              _customTimestamp = DateTime.now();
                            }),
                        title: Text('Ending at a custom timestamp')),
                    Visibility(
                      visible: _behavior ==
                              ScrobbleTimestampBehavior.startingCustom ||
                          _behavior == ScrobbleTimestampBehavior.endingCustom,
                      child: DateTimeField(
                          decoration: InputDecoration(labelText: 'Timestamp'),
                          resetIcon: null,
                          format: DateFormat('yyyy-MM-dd HH:mm:ss'),
                          initialValue: _customTimestamp,
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                                context: context,
                                initialDate: currentValue ?? DateTime.now(),
                                firstDate:
                                    DateTime.now().subtract(Duration(days: 14)),
                                lastDate:
                                    DateTime.now().add(Duration(days: 1)));

                            if (date != null) {
                              final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()));

                              return DateTimeField.combine(date, time);
                            }

                            return currentValue;
                          },
                          onChanged: (datetime) {
                            setState(() {
                              _customTimestamp = datetime;
                            });
                          }),
                    ),
                  ],
                ))));
  }
}
