import 'package:finale/services/generic.dart';
import 'package:finale/widgets/base/error_component.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final Entity? entity;
  final bool showSendFeedbackButton;

  const ErrorView(
      {required this.error,
      required this.stackTrace,
      this.entity,
      this.showSendFeedbackButton = true});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('Error')),
        body: Container(
          margin: EdgeInsets.all(10),
          child: ErrorComponent(
            error: error,
            stackTrace: stackTrace,
            entity: entity,
            showSendFeedbackButton: showSendFeedbackButton,
          ),
        ),
      );
}
