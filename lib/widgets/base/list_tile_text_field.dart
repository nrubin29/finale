import 'package:flutter/material.dart';

class ListTileTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const ListTileTextField(
      {required this.title,
      required this.controller,
      this.onChanged,
      this.validator});

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        bottom: false,
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller,
                onChanged: onChanged,
                textAlign: TextAlign.end,
                validator: validator,
              ),
            ),
          ],
        ),
      );
}
