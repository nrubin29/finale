import 'package:finale/widgets/base/date_time_field.dart';
import 'package:flutter/material.dart';

class DateRangeField extends StatefulWidget {
  final ValueChanged<DateTimeRange> onChanged;

  const DateRangeField({required this.onChanged});

  @override
  State<DateRangeField> createState() => _DateRangeFieldState();
}

class _DateRangeFieldState extends State<DateRangeField> {
  DateTime? _start, _end;

  String? _validator(DateTime? value) {
    if (value == null) {
      return 'This field is required.';
    } else if ((_start == null || _end == null || !_start!.isBefore(_end!))) {
      return 'Start must be before end.';
    }

    return null;
  }

  void _onChanged() {
    if (_start == null || _end == null || _start!.isAfter(_end!)) return;
    widget.onChanged(DateTimeRange(start: _start!, end: _end!));
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SafeArea(
        top: false,
        bottom: false,
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: DateTimeField(
          label: 'Start',
          initialValue: _start,
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
          initialValue: _end,
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
  );
}
