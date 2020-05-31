import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../lastfm.dart';

class ScrobbleView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScrobbleViewState();
}

class _ScrobbleViewState extends State<ScrobbleView> {
  final _trackController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  var _datetime = DateTime.now();

  Future<void> _scrobble() async {
    final response = await Lastfm.scrobble(_trackController.text,
        _artistController.text, _albumController.text, _datetime);

    if (response.ignored == 0) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Scrobbled successfully!')));
      _trackController.text = '';
      _artistController.text = '';
      _albumController.text = '';
    } else {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while scrobbling')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Scrobble'),
          actions: [IconButton(icon: Icon(Icons.add), onPressed: _scrobble)],
        ),
        body: Form(
            child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _trackController,
                      decoration: InputDecoration(labelText: 'Song'),
                    ),
                    TextFormField(
                      controller: _artistController,
                      decoration: InputDecoration(labelText: 'Artist'),
                    ),
                    TextFormField(
                      controller: _albumController,
                      decoration: InputDecoration(labelText: 'Album'),
                    ),
                    DateTimeField(
                        decoration: InputDecoration(labelText: 'Timestamp'),
                        format: DateFormat('yyyy-MM-dd HH:mm:ss'),
                        initialValue: _datetime,
                        onShowPicker: (context, currentValue) async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: currentValue ?? DateTime.now(),
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 14)),
                              lastDate: DateTime.now().add(Duration(days: 1)));

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
                  ],
                ))));
  }

  @override
  void dispose() {
    super.dispose();
    _trackController.dispose();
    _artistController.dispose();
    _albumController.dispose();
  }
}
