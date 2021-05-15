import 'dart:async';

import 'package:finale/components/display_component.dart';
import 'package:finale/preferences.dart';
import 'package:finale/services/generic.dart';
import 'package:flutter/material.dart';

class PeriodSelectorComponent<T extends Displayable> extends StatefulWidget {
  final DisplayType displayType;
  final PagedRequest<T> request;
  final DisplayableWidgetBuilder<T> detailWidgetBuilder;
  final DisplayableAndItemsWidgetBuilder<T> subtitleWidgetBuilder;

  PeriodSelectorComponent({
    this.displayType = DisplayType.list,
    required this.request,
    required this.detailWidgetBuilder,
    required this.subtitleWidgetBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PeriodSelectorComponentState<T>();
}

class _PeriodSelectorComponentState<T extends Displayable>
    extends State<PeriodSelectorComponent<T>> {
  late DisplayType _displayType;
  late Period _period;

  final _displayComponentKey = GlobalKey<DisplayComponentState>();
  late StreamSubscription _periodChangeSubscription;

  @override
  void initState() {
    super.initState();

    _displayType = widget.displayType;

    _periodChangeSubscription = Preferences().periodChange.listen((value) {
      setState(() {
        _period = value;
        _displayComponentKey.currentState?.getInitialItems();
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
            child: DisplayComponent<T>(
              key: _displayComponentKey,
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
