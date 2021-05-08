import 'package:finale/components/error_component.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final Object error;

  ErrorView({@required this.error});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('Error')),
        body: Container(
          margin: EdgeInsets.all(10),
          child: ErrorComponent(error: error),
        ),
      );
}
