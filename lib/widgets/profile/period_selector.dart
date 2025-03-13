import 'dart:async';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/services/lastfm/period_paged_request.dart';
import 'package:finale/util/extensions.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/period_dropdown.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PeriodSelector<T extends HasPlayCount> extends StatefulWidget {
  final EntityType entityType;
  final DisplayType displayType;
  final PeriodPagedRequest<T> Function(String username, Period period)
  requestConstructor;
  final String username;
  final EntityWidgetBuilder<T> detailWidgetBuilder;
  final EntityAndItemsWidgetBuilder<T> subtitleWidgetBuilder;

  const PeriodSelector({
    required this.entityType,
    this.displayType = DisplayType.list,
    required this.requestConstructor,
    required this.username,
    required this.detailWidgetBuilder,
    required this.subtitleWidgetBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PeriodSelectorState<T>();
}

class _PeriodSelectorState<T extends HasPlayCount>
    extends State<PeriodSelector<T>> {
  late DisplayType _displayType;
  late Period _period;

  late StreamSubscription _periodChangeSubscription;
  final _requestSubject = BehaviorSubject<PeriodPagedRequest<T>>();

  @override
  void initState() {
    super.initState();

    _displayType = widget.displayType;
    _period = Preferences.period.value;
    _updatePeriod();

    _periodChangeSubscription = Preferences.period.changes.listen((value) {
      if (mounted) {
        setState(() {
          _period = value;
          _updatePeriod();
        });
      }
    });
  }

  void _updatePeriod() {
    _requestSubject.add(widget.requestConstructor(widget.username, _period));
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SegmentedButton<DisplayType>(
                  showSelectedIcon: false,
                  style: minimumSizeButtonStyle,
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
      ),
      Expanded(
        child: EntityDisplay<T>(
          displayType: _displayType,
          requestStream: _requestSubject.stream,
          detailWidgetBuilder: widget.detailWidgetBuilder,
          subtitleWidgetBuilder: widget.subtitleWidgetBuilder,
          scoreboardItems: [
            ScoreboardItemModel.future(
              label: 'Scrobbles',
              futureProvider:
                  () =>
                      GetRecentTracksRequest.forPeriod(widget.username, _period)
                          .getNumItems()
                          .errorToNull<
                            RecentListeningInformationHiddenException
                          >(),
            ),
            ScoreboardItemModel.future(
              label: '${widget.entityType.displayName}s',
              futureProvider: () => _requestSubject.value.getNumItems(),
            ),
          ],
        ),
      ),
    ],
  );

  @override
  void dispose() {
    _periodChangeSubscription.cancel();
    _requestSubject.close();
    super.dispose();
  }
}
