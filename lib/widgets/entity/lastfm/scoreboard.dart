import 'dart:async';

import 'package:finale/util/formatters.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:flutter/material.dart';

/// An item in a [Scoreboard].
class ScoreboardItemModel {
  final String label;
  final FutureOr<Object?> Function() supplier;

  /// An optional function to call when the item is pressed.
  ///
  /// If not null, the item will be rendered as a button.
  final void Function()? callback;
  final bool isLazy;

  ScoreboardItemModel(
      {required this.label, required FutureOr<Object?> value, this.callback})
      : supplier = (() => value),
        isLazy = false;

  const ScoreboardItemModel.lazy({required this.label, required this.supplier})
      : callback = null,
        isLazy = true;
}

/// A widget that displays multiple [items] in a row.
///
/// [actions] are arbitrary widgets that are appended to the scoreboard.
class Scoreboard extends StatelessWidget {
  final List<ScoreboardItemModel> items;
  final List<Widget> actions;

  const Scoreboard({
    required this.items,
    this.actions = const [],
  });

  List<Widget> _widgets(BuildContext context) => items
      .map<Widget>((item) => _ScoreboardItem(model: item))
      .followedBy(actions)
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

class _ScoreboardItem extends StatefulWidget {
  final ScoreboardItemModel model;

  const _ScoreboardItem({required this.model});

  @override
  State<_ScoreboardItem> createState() => _ScoreboardItemState();
}

class _ScoreboardItemState extends State<_ScoreboardItem> {
  var _isLoading = false;
  Object? _value;

  @override
  void initState() {
    super.initState();
    unawaited(_loadValue());
  }

  Future<void> _loadValue({bool forceLoad = false}) async {
    if (widget.model.isLazy && !forceLoad) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _value = await widget.model.supplier();
    } on Exception {
      _value = null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget get _scoreTile {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.model.label),
        _isLoading
            ? const LoadingComponent.small()
            : _value != null
                ? Text(_value is num
                    ? numberFormat.format(_value)
                    : _value.toString())
                : widget.model.isLazy
                    ? const Text('Tap to load')
                    : const Text('---'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => widget.model.callback != null ||
          (widget.model.isLazy && _value == null)
      ? OutlinedButton(
          style: ButtonStyle(
              side: WidgetStateProperty.all(
                  BorderSide(color: Theme.of(context).colorScheme.primary))),
          onPressed: () => widget.model.isLazy
              ? _loadValue(forceLoad: true)
              : widget.model.callback?.call(),
          child: _scoreTile,
        )
      : _scoreTile;
}
