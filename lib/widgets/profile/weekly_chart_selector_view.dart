import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/user.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/profile/weekly_chart_component.dart';
import 'package:flutter/material.dart';

class WeeklyChartSelectorView extends StatefulWidget {
  final LUser user;

  const WeeklyChartSelectorView({required this.user});

  @override
  State<StatefulWidget> createState() => _WeeklyChartSelectorViewState();
}

class _WeeklyChartSelectorViewState extends State<WeeklyChartSelectorView>
    with AutomaticKeepAliveClientMixin<WeeklyChartSelectorView> {
  var _loaded = false;
  late List<LUserWeeklyChart> _charts;
  late int _index;

  @override
  void initState() {
    super.initState();

    Lastfm.getWeeklyChartList(widget.user).then((chartList) {
      setState(() {
        _charts = chartList.charts;
        _index = _charts.length - 1;
        _loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return !_loaded
        ? const LoadingComponent()
        : Column(
            children: [
              ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _index > 0
                          ? () {
                              setState(() {
                                _index--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      _charts[_index].title,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _index < _charts.length - 1
                          ? () {
                              setState(() {
                                _index++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: WeeklyChartComponent(
                  user: widget.user,
                  chart: _charts[_index],
                ),
              ),
            ],
          );
  }

  @override
  bool get wantKeepAlive => true;
}
