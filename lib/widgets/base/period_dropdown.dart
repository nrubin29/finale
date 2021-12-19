import 'package:finale/util/period.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/material.dart';

class PeriodDropdownButton extends StatefulWidget {
  const PeriodDropdownButton();

  @override
  _PeriodDropdownButtonState createState() => _PeriodDropdownButtonState();
}

class _PeriodDropdownButtonState extends State<PeriodDropdownButton> {
  Period? _period;

  @override
  void initState() {
    super.initState();
    _period = Preferences().period;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Period?>(
      value: _period,
      items: [
        for (final period in Period.apiValues)
          DropdownMenuItem(
            value: period,
            child: Text(period.display),
          ),
        if (_period?.isCustom ?? false)
          DropdownMenuItem(
            value: _period,
            child: Text(_period!.display),
          )
        else
          const DropdownMenuItem(
            value: null,
            child: Text('Custom'),
          ),
      ],
      onChanged: (value) async {
        if (value?.isCustom ?? true) {
          final dateRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2010),
            lastDate: DateTime.now(),
          );

          if (dateRange != null) {
            setState(() {
              _period = Preferences().period =
                  Period(start: dateRange.start, end: dateRange.end);
            });
          }
        } else if (value != null && value != _period) {
          setState(() {
            _period = Preferences().period = value;
          });
        }
      },
    );
  }
}
