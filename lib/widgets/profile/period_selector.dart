import 'dart:async';

import 'package:finale/services/generic.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/period_dropdown.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:flutter/material.dart';

class PeriodSelector<T extends Entity> extends StatefulWidget {
  final DisplayType displayType;
  final PagedRequest<T> request;
  final EntityWidgetBuilder<T> detailWidgetBuilder;
  final EntityAndItemsWidgetBuilder<T> subtitleWidgetBuilder;

  const PeriodSelector({
    this.displayType = DisplayType.list,
    required this.request,
    required this.detailWidgetBuilder,
    required this.subtitleWidgetBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PeriodSelectorState<T>();
}

class _PeriodSelectorState<T extends Entity> extends State<PeriodSelector<T>> {
  late DisplayType _displayType;

  final _entityDisplayComponentKey = GlobalKey<EntityDisplayState>();
  late StreamSubscription _periodChangeSubscription;

  @override
  void initState() {
    super.initState();

    _displayType = widget.displayType;

    _periodChangeSubscription = Preferences.period.changes.listen((value) {
      if (mounted) {
        setState(() {
          _entityDisplayComponentKey.currentState?.reload();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SegmentedButton<DisplayType>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: DisplayType.list,
                        icon: Icon(Icons.list),
                      ),
                      ButtonSegment(
                        value: DisplayType.grid,
                        icon: Icon(Icons.grid_view),
                      ),
                    ],
                    selected: {_displayType},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _displayType = newSelection.single;
                      });
                    },
                  ),
                  const PeriodDropdownButton(),
                ],
              ),
            ),
          ),
          Expanded(
            child: EntityDisplay<T>(
              key: _entityDisplayComponentKey,
              displayType: _displayType,
              request: widget.request,
              detailWidgetBuilder: widget.detailWidgetBuilder,
              subtitleWidgetBuilder: widget.subtitleWidgetBuilder,
            ),
          ),
        ],
      );

  @override
  void dispose() {
    _periodChangeSubscription.cancel();
    super.dispose();
  }
}
