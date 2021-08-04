import 'package:finale/widgets/base/loading_component.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('Loading')),
        body: LoadingComponent(),
      );
}
