import 'package:flutter/material.dart';

class ListTileTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const ListTileTextField({
    required this.title,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    bottom: false,
    minimum: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.end,
            validator: validator,
          ),
        ),
      ],
    ),
  );
}
