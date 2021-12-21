import 'package:flutter/material.dart';

class ListTileTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const ListTileTextField({required this.title, required this.controller});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(border: InputBorder.none),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
}
