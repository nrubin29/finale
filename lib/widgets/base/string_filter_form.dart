import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/custom_list_tile.dart';
import 'package:flutter/material.dart';

enum StringFilterType {
  equals('Equals', '='),
  startsWith('Starts with', 'starts with'),
  endsWith('Ends with', 'ends with'),
  contains('Contains', 'contains');

  final String displayName;
  final String shortName;

  const StringFilterType(this.displayName, this.shortName);
}

class StringFilter {
  final StringFilterType type;
  final bool caseSensitive;
  final String value;

  const StringFilter({
    this.type = .equals,
    this.caseSensitive = false,
    this.value = '',
  });

  StringFilter copyWith({
    StringFilterType? type,
    bool? caseSensitive,
    String? value,
  }) => StringFilter(
    type: type ?? this.type,
    caseSensitive: caseSensitive ?? this.caseSensitive,
    value: value ?? this.value,
  );

  bool matches(String test) {
    if (value.isEmpty) return true;

    final realTest = caseSensitive ? test : test.toLowerCase();
    final realValue = caseSensitive ? value : value.toLowerCase();

    return switch (type) {
      .equals => realTest == realValue,
      .startsWith => realTest.startsWith(realValue),
      .endsWith => realTest.endsWith(realValue),
      .contains => realTest.contains(realValue),
    };
  }

  @override
  String toString() => '${type.shortName} $value';
}

class StringFilterForm extends StatefulWidget {
  final StringFilter filter;
  final void Function(StringFilter filter) onFilterChanged;

  const StringFilterForm({required this.filter, required this.onFilterChanged});

  @override
  State<StringFilterForm> createState() => _StringFilterFormState();
}

class _StringFilterFormState extends State<StringFilterForm> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.filter.value);
    _textController.addListener(() {
      widget.onFilterChanged(
        widget.filter.copyWith(value: _textController.text),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        title: const Text('Op'),
        trailing: DropdownButton<StringFilterType>(
          value: widget.filter.type,
          items: [
            for (final type in StringFilterType.values)
              DropdownMenuItem(value: type, child: Text(type.displayName)),
          ],
          onChanged: (value) {
            if (value == null) return;
            widget.onFilterChanged(widget.filter.copyWith(type: value));
          },
        ),
      ),
      CheckboxListTile(
        title: const Text('Case sensitive'),
        value: widget.filter.caseSensitive,
        onChanged: (value) {
          if (value == null) return;
          widget.onFilterChanged(widget.filter.copyWith(caseSensitive: value));
        },
      ),
      CustomListTile(
        title: 'Value',
        trailing: TextFormField(
          controller: _textController,
          textAlign: .end,
          decoration: formElementBottomBorderDecoration,
        ),
      ),
    ],
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
