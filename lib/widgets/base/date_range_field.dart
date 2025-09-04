import 'package:finale/util/preferences.dart';
import 'package:finale/util/preset_date_range.dart';
import 'package:finale/widgets/base/date_time_field.dart';
import 'package:flutter/material.dart';

class DateRangeField extends StatefulWidget {
  final DateTime? lowerBound;
  final ValueChanged<DateTimeRange> onChanged;

  const DateRangeField({this.lowerBound, required this.onChanged});

  @override
  State<DateRangeField> createState() => _DateRangeFieldState();
}

class _DateRangeFieldState extends State<DateRangeField> {
  var _presetDateRange = PresetDateRange.pastHour;
  DateTime? _start, _end;

  String? _validator(DateTime? value) {
    if (value == null) {
      return 'This field is required.';
    } else if ((_start == null || _end == null || !_start!.isBefore(_end!))) {
      return 'Start must be before end.';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _presetDateRange = Preferences.defaultDateRange.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setValue();
    });
  }

  void _setValue() {
    _start = _presetDateRange.startDate;
    _end = _presetDateRange.endDate;
    _onChanged();
  }

  void _onChanged() {
    if (_start == null || _end == null || _start!.isAfter(_end!)) return;
    widget.onChanged(DateTimeRange(start: _start!, end: _end!));
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        title: const Text('Date range'),
        trailing: DropdownButton(
          value: _presetDateRange,
          items: [
            for (final presetDateRange in PresetDateRange.values)
              DropdownMenuItem(
                value: presetDateRange,
                child: Text(presetDateRange.displayName),
              ),
          ],
          onChanged: (value) {
            setState(() {
              if (value != null) {
                _presetDateRange = value;
                _setValue();
              }
            });
          },
        ),
      ),
      if (_presetDateRange == PresetDateRange.custom) ...[
        SafeArea(
          top: false,
          bottom: false,
          minimum: const EdgeInsets.symmetric(horizontal: 16),
          child: DateTimeField(
            label: 'Start',
            lowerBound: widget.lowerBound,
            validator: _validator,
            onChanged: (dateTime) {
              setState(() {
                _start = dateTime;
                _onChanged();
              });
            },
          ),
        ),
        SafeArea(
          top: false,
          bottom: false,
          minimum: const EdgeInsets.symmetric(horizontal: 16),
          child: DateTimeField(
            label: 'End',
            showNowIcon: true,
            includeEndOfMinute: true,
            lowerBound: widget.lowerBound,
            validator: _validator,
            onChanged: (dateTime) {
              setState(() {
                _end = dateTime;
                _onChanged();
              });
            },
          ),
        ),
      ],
    ],
  );
}
