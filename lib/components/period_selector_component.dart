import 'dart:async';

import 'package:finale/components/entity_display_component.dart';
import 'package:finale/preferences.dart';
import 'package:finale/services/generic.dart';
import 'package:flutter/material.dart';

class PeriodSelectorComponent<T extends Entity> extends StatefulWidget {
  final DisplayType displayType;
  final PagedRequest<T> request;
  final EntityWidgetBuilder<T> detailWidgetBuilder;
  final EntityAndItemsWidgetBuilder<T> subtitleWidgetBuilder;

  PeriodSelectorComponent({
    this.displayType = DisplayType.list,
    required this.request,
    required this.detailWidgetBuilder,
    required this.subtitleWidgetBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PeriodSelectorComponentState<T>();
}

class _PeriodSelectorComponentState<T extends Entity>
    extends State<PeriodSelectorComponent<T>> {
  late DisplayType _displayType;
  late Period _period;

  final _entityDisplayComponentKey = GlobalKey<EntityDisplayComponentState>();
  late StreamSubscription _periodChangeSubscription;

  @override
  void initState() {
    super.initState();

    _displayType = widget.displayType;

    _periodChangeSubscription = Preferences().periodChange.listen((value) {
      setState(() {
        _period = value;
        _entityDisplayComponentKey.currentState?.getInitialItems();
      });
    });

    _period = Preferences().period;
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IntrinsicWidth(
                    child: DefaultTabController(
                  length: 2,
                  initialIndex: _displayType.index,
                  child: TabBar(
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.transparent,
                      tabs: [Icon(Icons.list), Icon(Icons.grid_view)],
                      onTap: (index) {
                        setState(() {
                          _displayType = DisplayType.values[index];
                        });
                      }),
                )),
                DropdownButton<Period>(
                  value: _period,
                  items: Period.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.display),
                          ))
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null && value != _period) {
                      Preferences().period = value;
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: EntityDisplayComponent<T>(
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
    super.dispose();
    _periodChangeSubscription.cancel();
  }
}
