import 'dart:async';

import 'package:finale/components/display_component.dart';
import 'package:finale/lastfm.dart';
import 'package:finale/types/generic.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeriodSelectorComponent<T extends Displayable> extends StatefulWidget {
  // This Subject must remain open for the entire lifetime of the app, so no
  // need to close it.
  // ignore: close_sinks
  static final _periodChange = PublishSubject<String>();

  final DisplayType displayType;
  final PagedLastfmRequest<T> request;
  final DisplayableWidgetBuilder<T> detailWidgetBuilder;
  final DisplayableAndItemsWidgetBuilder<T> subtitleWidgetBuilder;

  PeriodSelectorComponent({
    this.displayType = DisplayType.list,
    this.request,
    this.detailWidgetBuilder,
    this.subtitleWidgetBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PeriodSelectorComponentState<T>();
}

class _PeriodSelectorComponentState<T extends Displayable>
    extends State<PeriodSelectorComponent<T>> {
  static const _periods = {
    '7 days': '7day',
    '1 month': '1month',
    '3 months': '3month',
    '6 months': '6month',
    '12 months': '12month',
    'Overall': 'overall'
  };

  DisplayType _displayType;
  String _period;

  final _displayComponentKey = GlobalKey<DisplayComponentState>();
  StreamSubscription _periodChangeSubscription;

  @override
  void initState() {
    super.initState();

    _displayType = widget.displayType;

    _periodChangeSubscription =
        PeriodSelectorComponent._periodChange.listen((value) {
      setState(() {
        _period = value;
        _displayComponentKey.currentState.getInitialItems();
      });
    });

    SharedPreferences.getInstance().then((sharedPrefs) {
      setState(() {
        if (!sharedPrefs.containsKey('period')) {
          sharedPrefs.setString('period', '7day');
          PeriodSelectorComponent._periodChange.add('7day');
        }

        _period = sharedPrefs.getString('period');
      });
    });
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
                DropdownButton<String>(
                  value: _period,
                  items: _periods.entries
                      .map((e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.key),
                          ))
                      .toList(growable: false),
                  onChanged: (value) async {
                    if (value != _period) {
                      final sharedPrefs = await SharedPreferences.getInstance();
                      await sharedPrefs.setString('period', value);
                      PeriodSelectorComponent._periodChange.add(value);
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
