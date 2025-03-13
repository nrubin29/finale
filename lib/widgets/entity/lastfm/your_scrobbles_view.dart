import 'package:collection/collection.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/util/extensions.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/header_list_tile.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/entity/lastfm/scrobble_distribution/scrobble_distribution_component.dart';
import 'package:flutter/material.dart';

class YourScrobblesView extends StatefulWidget {
  final LTrack track;
  final String? username;

  const YourScrobblesView({required this.track, this.username});

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
        await UserGetTrackScrobblesRequest(
          widget.track,
          widget.username,
        ).getAllData();

    setState(() {
      _scrobbles = scrobbles;
      _selectedDate = scrobbles.first.date.beginningOfDay;
    });
  }

  Widget get _barChartView => ScrobbleDistributionComponent(
    username: widget.username ?? Preferences.name.value!,
    fetchScrobbleCounts: (ranges) {
      final counts = List.filled(ranges.length, 0);

      for (final scrobble in _scrobbles!) {
        final index = ranges.binarySearchIndexWhere(
          scrobble.date,
          (range, date) => range.compareContains(date),
        );

        if (index != -1) {
          counts[index]++;
        }
      }

      return counts.map(Future.value);
    },
  );

  List<Widget> get _calendarView => [
    CalendarDatePicker(
      initialDate: _selectedDate!,
      firstDate: _scrobbles!.last.date,
      lastDate: _scrobbles!.first.date,
      currentDate: _selectedDate,
      selectableDayPredicate:
          (day) => _scrobbles!.any(
            (scrobble) => scrobble.date.beginningOfDay == day,
          ),
      onDateChanged: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    ),
    const Divider(),
    for (final scrobble in _scrobbles!.where(
      (scrobble) => scrobble.date.beginningOfDay == _selectedDate,
    ))
      ListTile(
        title: Text(timeFormatWithSeconds.format(scrobble.date)),
        trailing: Text(scrobble.album.name),
      ),
  ];

  List<Widget> get _listView => [
    for (final entry
        in groupBy<LUserTrackScrobble, DateTime>(
          _scrobbles!,
          (scrobble) => scrobble.date.beginningOfMonth,
        ).entries) ...[
      HeaderListTile(
        monthFormat.format(entry.key),
        trailing: Text(pluralize(entry.value.length)),
      ),
      for (final scrobble in entry.value)
        ListTile(
          title: Text(dateTimeFormatWithSeconds.format(scrobble.date)),
          trailing: Text(scrobble.album.name),
        ),
    ],
  ];

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: createAppBar(
        context,
        widget.track.name,
        leadingEntity: widget.track,
        subtitle: _scrobbles != null ? pluralize(_scrobbles!.length) : null,
        actions: [const SizedBox(width: 32)],
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.bar_chart)),
            Tab(icon: Icon(Icons.calendar_today)),
            Tab(icon: Icon(Icons.list)),
          ],
        ),
      ),
      body:
          _scrobbles == null
              ? const LoadingComponent()
              : TabBarView(
                children: [
                  _barChartView,
                  ListView(children: _calendarView),
                  ListView(children: _listView),
                ],
              ),
    ),
  );
}
