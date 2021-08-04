import 'dart:async';

import 'package:finale/util/util.dart';
import 'package:flutter/material.dart';

/// A component that displays multiple [statistics] with labels.
class ScoreboardComponent extends StatelessWidget {
  final Map<String, FutureOr<int>> statistics;
  final List<Widget> actions;

  const ScoreboardComponent(
      {this.statistics = const {}, this.actions = const []});

  Widget _scoreTile(String title, FutureOr<int> value) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (value is Future<int>)
            FutureBuilder<int>(
              future: value,
              builder: (context, snapshot) => Text(snapshot.hasData
                  ? numberFormat.format(snapshot.data!)
                  : '---'),
            )
          else
            Text(numberFormat.format(value))
        ],
      );

  List<Widget> get _widgets => statistics.entries
      .map((e) => _scoreTile(e.key, e.value))
      .followedBy(actions)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final widgets = _widgets;

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < widgets.length; i++) ...[
            widgets[i],
            if (i < widgets.length - 1) VerticalDivider(),
          ]
        ],
      ),
    );
  }
}
