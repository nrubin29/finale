import 'package:flutter/material.dart';

class LoadingComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      color: Theme.of(context).backgroundColor,
      child: Center(child: CircularProgressIndicator()));
}
