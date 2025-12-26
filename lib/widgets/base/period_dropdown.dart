import 'dart:async';

import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/material.dart';

class PeriodDropdownButton extends StatefulWidget {
  final ValueChanged<Period>? periodChanged;

  const PeriodDropdownButton({this.periodChanged});

  @override
  State<StatefulWidget> createState() => _PeriodDropdownButtonState();
}

class _PeriodDropdownButtonState extends State<PeriodDropdownButton> {
  late Period _period;
  late StreamSubscription _periodChangeSubscription;

  @override
  void initState() {
    super.initState();
    _period = Preferences.period.value;

    _periodChangeSubscription = Preferences.period.changes.listen((value) {
      if (mounted) {
        setState(() {
          _period = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Period>(
      value: _period,
      items: [
        for (final period in ApiPeriod.values)
          DropdownMenuItem(value: period, child: Text(period.display)),
        if (_period is CustomPeriod)
          DropdownMenuItem(value: _period, child: Text(_period.display))
        else
          const DropdownMenuItem(value: null, child: Text('Custom')),
      ],
      onChanged: (value) async {
        if (value == null || value is CustomPeriod) {
          final dateRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2010),
            lastDate: .now(),
            initialEntryMode: Preferences.inputDateTimeAsText.value
                ? .input
                : .calendar,
          );

          if (dateRange != null) {
            setState(() {
              _period = Preferences.period.value = CustomPeriod(
                start: dateRange.start,
                end: dateRange.end.add(
                  const Duration(hours: 23, minutes: 59, seconds: 59),
                ),
              );
              widget.periodChanged?.call(_period);
            });
          }
        } else if (value != _period) {
          setState(() {
            _period = Preferences.period.value = value;
            widget.periodChanged?.call(value);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _periodChangeSubscription.cancel();
    super.dispose();
  }
}
