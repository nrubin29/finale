import 'package:collection/collection.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/header_list_tile.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:flutter/material.dart';

class YourScrobblesView extends StatefulWidget {
  final LTrack track;

  const YourScrobblesView({required this.track});

  @override
  State<StatefulWidget> createState() => _YourScrobblesViewState();
}

class _YourScrobblesViewState extends State<YourScrobblesView> {
  List<LUserTrackScrobble>? _scrobbles;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final scrobbles =
        await UserGetTrackScrobblesRequest(widget.track).getAllData();

    setState(() {
      _scrobbles = scrobbles;
      _selectedDate = scrobbles.first.date.beginningOfDay;
    });
  }

  List<Widget> get _calendarView => [
        CalendarDatePicker(
          initialDate: _selectedDate!,
          firstDate: _scrobbles!.last.date,
          lastDate: _scrobbles!.first.date,
          currentDate: _selectedDate,
          selectableDayPredicate: (day) => _scrobbles!
              .any((scrobble) => scrobble.date.beginningOfDay == day),
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
        for (final scrobble in _scrobbles!
            .where((scrobble) => scrobble.date.beginningOfDay == _selectedDate))
          ListTile(
            title: Text(timeFormat.format(scrobble.date)),
          ),
      ];

  List<Widget> get _listView => [
        for (final entry in groupBy<LUserTrackScrobble, DateTime>(
                _scrobbles!, (scrobble) => scrobble.date.beginningOfMonth)
            .entries) ...[
          HeaderListTile(
            monthFormat.format(entry.key),
            trailing: Text(formatScrobbles(entry.value.length)),
          ),
          for (final scrobble in entry.value)
            ListTile(title: Text(dateTimeFormat.format(scrobble.date))),
        ],
      ];

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: createAppBar(
            'Your scrobbles',
            subtitle: formatScrobbles(widget.track.userPlayCount),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.calendar_today)),
                Tab(icon: Icon(Icons.list)),
              ],
            ),
          ),
          body: _scrobbles == null
              ? const LoadingComponent()
              : TabBarView(
                  children: [
                    ListView(children: _calendarView),
                    ListView(children: _listView),
                  ],
                ),
        ),
      );
}
