import 'package:datetime_picker_formfield/datetime_picker_formfield.dart'
    as impl;
import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/material.dart';

class DateTimeField extends StatelessWidget {
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
  Widget build(BuildContext context) => impl.DateTimeField(
        decoration: InputDecoration(labelText: label),
        resetIcon: null,
        format: dateTimeFormatWithYear,
        initialValue: initialValue,
        validator: validator,
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
            context: context,
            initialDate: currentValue ?? DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 14)),
            lastDate: DateTime.now().add(const Duration(days: 1)),
            initialEntryMode: Preferences().inputDateTimeAsText
                ? DatePickerEntryMode.input
                : DatePickerEntryMode.calendar,
          );

          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              initialEntryMode: Preferences().inputDateTimeAsText
                  ? TimePickerEntryMode.input
                  : TimePickerEntryMode.dial,
            );

            if (time != null) {
              return impl.DateTimeField.combine(date, time);
            }
          }

          return currentValue;
        },
        onChanged: (dateTime) {
          if (dateTime != null) {
            onChanged.call(dateTime);
          }
        },
      );
}
