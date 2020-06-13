import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/lastfm.dart';
import 'package:finale/types/generic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScrobbleAlbumView extends StatefulWidget {
  final FullAlbum album;

  ScrobbleAlbumView({Key key, this.album}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScrobbleAlbumViewState();
}

class _ScrobbleAlbumViewState extends State<ScrobbleAlbumView> {
  var _scrobbleNow = true;
  DateTime _datetime;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _scrobble(BuildContext context) async {
    final timestamps = [_scrobbleNow ? DateTime.now() : _datetime];

    widget.album.tracks.forEach((track) {
      timestamps.add(timestamps.last.add(Duration(seconds: track.duration)));
    });

    final response = await Lastfm.scrobble(widget.album.tracks, timestamps);

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
                    CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.red,
                      title: Text('Scrobble starting now'),
                      value: _scrobbleNow,
                      onChanged: (value) {
                        setState(() {
                          _scrobbleNow = value;

                          if (!_scrobbleNow) {
                            _datetime = DateTime.now();
                          }
                        });
                      },
                    ),
                    Visibility(
                      visible: !_scrobbleNow,
                      child: DateTimeField(
                          decoration: InputDecoration(labelText: 'Timestamp'),
                          format: DateFormat('yyyy-MM-dd HH:mm:ss'),
                          initialValue: _datetime,
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
                              _datetime = datetime;
                            });
                          }),
                    ),
                  ],
                ))));
  }
}
