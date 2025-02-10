import 'dart:async';

import 'package:collection/collection.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/request_sequencer.dart';
import 'package:finale/util/theme.dart';
import 'package:flutter/material.dart';

import 'scrobble_distribution_bar_chart.dart';

enum ScrobbleDistributionLevel { overall, year, month }

class ScrobbleDistributionItem {
  final ScrobbleDistributionLevel level;
  final DateTime dateTime;
  final int scrobbles;

  const ScrobbleDistributionItem(
      {required this.level, required this.dateTime, required this.scrobbles});

  String get title => switch (level) {
        ScrobbleDistributionLevel.overall => '${dateTime.year}',
        ScrobbleDistributionLevel.year => monthNameFormat.format(dateTime),
        ScrobbleDistributionLevel.month => '${dateTime.day}',
      };

  String get shortTitle => switch (level) {
        ScrobbleDistributionLevel.overall => '${dateTime.year}',
        ScrobbleDistributionLevel.year =>
          abbreviatedMonthNameFormat.format(dateTime),
        ScrobbleDistributionLevel.month => '${dateTime.day}',
      };

  String get subtitle => pluralize(scrobbles);
}

class ScrobbleDistributionComponent extends StatefulWidget {
  final String username;
  final Iterable<Future<int>> Function(List<DateTimeRange> ranges)
      fetchScrobbleCounts;

  const ScrobbleDistributionComponent({
    required this.username,
    required this.fetchScrobbleCounts,
  });

  @override
  State<ScrobbleDistributionComponent> createState() =>
      _ScrobbleDistributionComponentState();
}

class _ScrobbleDistributionComponentState
    extends State<ScrobbleDistributionComponent>
    with AutomaticKeepAliveClientMixin {
  var _level = ScrobbleDistributionLevel.overall;
  late DateTime _scrobblingSince, _dateTime;
  var _items = <ScrobbleDistributionItem>[];
  var _isLoading = true;

  final _requestSequencer = RequestSequencer();

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  Future<void> _setUp() async {
    final user = await Lastfm.getUser(widget.username);
    _scrobblingSince = user.registered.date;
    _dateTime = _scrobblingSince;
    await _update();
  }

  Future<void> _drillDown(ScrobbleDistributionItem item) async {
    _level = ScrobbleDistributionLevel.values[_level.index + 1];
    _dateTime = item.dateTime;
    await _update();
  }

  Future<void> _drillUp() async {
    _level = ScrobbleDistributionLevel.values[_level.index - 1];
    _dateTime = switch (_level) {
      ScrobbleDistributionLevel.overall => _scrobblingSince,
      ScrobbleDistributionLevel.year => DateTime(_dateTime.year),
      ScrobbleDistributionLevel.month =>
        throw Exception('Tried to drill up to month level.'),
    };
    await _update();
  }

  Future<void> _update() async {
    final requestHandle = _requestSequencer.startRequest();

    setState(() {
      _isLoading = true;
    });

    final dateTimes = switch (_level) {
      ScrobbleDistributionLevel.overall => _listGenerateRange(
          _dateTime.year, DateTime.now().year + 1, DateTime.new),
      ScrobbleDistributionLevel.year =>
        _listGenerateRange(1, 13, (month) => DateTime(_dateTime.year, month)),
      ScrobbleDistributionLevel.month => _listGenerateRange(
          1,
          DateUtils.getDaysInMonth(_dateTime.year, _dateTime.month) + 1,
          (day) => DateTime(_dateTime.year, _dateTime.month, day)),
    };
    final ranges = IterableZip([dateTimes, dateTimes.skip(1)])
        .map((item) => DateTimeRange(start: item.first, end: item.last))
        .toList(growable: false);
    final scrobbleCounts =
        await Future.wait(widget.fetchScrobbleCounts(ranges));

    if (!requestHandle.isLatestRequest) {
      return;
    }

    _items = IterableZip([dateTimes, scrobbleCounts])
        .map((data) => ScrobbleDistributionItem(
            level: _level,
            dateTime: data.first as DateTime,
            scrobbles: data.last as int))
        .toList(growable: false);

    setState(() {
      _isLoading = false;
    });
  }

  String get _levelTitle => switch (_level) {
        ScrobbleDistributionLevel.overall => 'Overall',
        ScrobbleDistributionLevel.year => '${_dateTime.year}',
        ScrobbleDistributionLevel.month => monthFormat.format(_dateTime),
      };

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              IconButton(
                style: minimumSizeButtonStyle,
                icon: const Icon(Icons.arrow_upward),
                onPressed: _level == ScrobbleDistributionLevel.overall
                    ? null
                    : _drillUp,
              ),
              const SizedBox(width: 8),
              Text(_levelTitle),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ScrobbleDistributionBarChart(
                  level: _level, items: _items, onTap: _drillDown),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

List<E> _listGenerateRange<E>(
        int start, int end, E Function(int index) generator) =>
    [for (var i = start; i <= end; i++) generator(i)];
