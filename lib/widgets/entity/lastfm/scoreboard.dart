import 'dart:async';

import 'package:finale/util/formatters.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:flutter/material.dart';

/// A widget that displays multiple [statistics] with labels.
///
/// If a statistic has a corresponding entry in [statisticActions], it will be
/// rendered as a button that will call a callback when tapped.
///
/// [actions] are arbitrary widgets that are appended to the scoreboard.
class Scoreboard extends StatefulWidget {
  final Map<String, FutureOr<Object?>> statistics;
  final Map<String, VoidCallback> statisticActions;
  final List<Widget> actions;

  const Scoreboard(
      {this.statistics = const {},
      this.statisticActions = const {},
      this.actions = const []});

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  final _data = <String, Object?>{};

  @override
  void initState() {
    super.initState();

    for (var entry in widget.statistics.entries) {
      unawaited(_resolveFuture(entry.key, entry.value));
    }
  }

  Future<void> _resolveFuture(String key, FutureOr<Object?> futureOr) async {
    try {
      final result = await futureOr;
      _data[key] = result;
    } on Exception {
      _data[key] = null;
    } finally {
      setState(() {});
    }
  }

  Widget _scoreTile(String title) {
    final value = _data[title];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        _data.containsKey(title)
            ? value != null
                ? Text(value is num
                    ? numberFormat.format(value)
                    : value.toString())
                : const Text('---')
            : const LoadingComponent.small()
      ],
    );
  }

  List<Widget> _widgets(BuildContext context) => widget.statistics.keys
      .map((key) => widget.statisticActions.containsKey(key)
          ? OutlinedButton(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                    const TextStyle(fontWeight: FontWeight.normal)),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: widget.statisticActions[key],
              child: _scoreTile(key),
            )
          : _scoreTile(key))
      .followedBy(widget.actions)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final widgets = _widgets(context);

    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widgets.length; i++) ...[
                widgets[i],
                if (i < widgets.length - 1) const VerticalDivider(width: 24),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
