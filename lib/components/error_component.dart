import 'package:flutter/material.dart';

class ErrorComponent extends StatelessWidget {
  final Object error;

  ErrorComponent({@required this.error});

  @override
  Widget build(BuildContext context) => Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 36),
          SizedBox(height: 5),
          Text(
            '$error',
            textAlign: TextAlign.center,
          )
        ],
      ));
}
