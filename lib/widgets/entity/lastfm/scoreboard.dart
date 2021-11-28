import 'dart:async';

import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:flutter/material.dart';

/// A widget that displays multiple [statistics] with labels.
class Scoreboard extends StatelessWidget {
  final Map<String, FutureOr<int?>> statistics;
  final Map<String, VoidCallback> statisticActions;
  final List<Widget> actions;

  const Scoreboard(
      {this.statistics = const {},
      this.statisticActions = const {},
      this.actions = const []});

  Widget _scoreTile(String title, FutureOr<int?> value) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (value is Future<int?>)
            FutureBuilder<int?>(
              future: value,
              builder: (context, snapshot) => snapshot.hasData
                  ? Text(numberFormat.format(snapshot.data!))
                  : snapshot.connectionState == ConnectionState.done
                      ? const Text('---')
                      : const LoadingComponent.small(),
            )
          else
            Text(numberFormat.format(value))
        ],
      );

  List<Widget> _widgets(BuildContext context) => statistics.entries
      .map((e) => statisticActions.containsKey(e.key)
          ? OutlinedButton(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                    const TextStyle(fontWeight: FontWeight.normal)),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: statisticActions[e.key],
              child: _scoreTile(e.key, e.value),
            )
          : _scoreTile(e.key, e.value))
      .followedBy(actions)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final widgets = _widgets(context);

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < widgets.length; i++) ...[
            widgets[i],
            if (i < widgets.length - 1) const VerticalDivider(),
          ]
        ],
      ),
    );
  }
}
