import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/material.dart';

DateTime _combine(DateTime date, TimeOfDay? time) => DateTime(
    date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);

class DateTimeField extends StatefulWidget {
  final String label;
  final DateTime? initialValue;
  final ValueChanged<DateTime> onChanged;
  final FormFieldValidator<DateTime>? validator;

  const DateTimeField({
    this.label = 'Timestamp',
    required this.initialValue,
    required this.onChanged,
    this.validator,
  });

  @override
  State<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  DateTime? _value;
  var _dirty = false;
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialValue case DateTime value) {
      _updateValue(value, isInitState: true);
    }
  }

  void _updateValue(DateTime newValue, {bool isInitState = false}) {
    _value = newValue;
    _dateController.text = dateFormatWithYear.format(newValue);
    _timeController.text = timeFormat.format(newValue);

    if (!isInitState) {
      _dirty = true;
      widget.onChanged(newValue);
    }
  }

  Future<DateTime?> _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 14)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialEntryMode: Preferences.inputDateTimeAsText.value
          ? DatePickerEntryMode.input
          : DatePickerEntryMode.calendar,
    );

    if (date == null) {
      return null;
    }

    if (_value case DateTime value when _dirty) {
      // Only update the date in this case.
      return _combine(date, TimeOfDay.fromDateTime(value));
    }

    return await _showTimePicker(dateToCombineWith: date);
  }

  Future<DateTime?> _showTimePicker({DateTime? dateToCombineWith}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_value ?? DateTime.now()),
      initialEntryMode: Preferences.inputDateTimeAsText.value
          ? TimePickerEntryMode.input
          : TimePickerEntryMode.dial,
    );

    if (time != null) {
      return _combine(dateToCombineWith ?? _value!, time);
    }

    return dateToCombineWith;
  }

  String? _validator(String? value) => widget.validator?.call(_value);

  @override
  Widget build(BuildContext context) => Row(
        spacing: 8,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await _showDatePicker();
                if (result != null) {
                  _updateValue(result);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(labelText: widget.label),
                  controller: _dateController,
                  validator: _validator,
                ),
              ),
            ),
          ),
          if (_value != null)
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final result = await _showTimePicker();
                  if (result != null) {
                    _updateValue(result);
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: ''),
                    controller: _timeController,
                    validator: (value) => _validator(value) == null ? null : '',
                  ),
                ),
              ),
            ),
        ],
      );
}
