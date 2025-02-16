import 'dart:async';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/period_paged_request.dart';
import 'package:finale/util/extensions.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/period_dropdown.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:flutter/material.dart';

class PeriodSelector<T extends HasPlayCount> extends StatefulWidget {
  final EntityType entityType;
  final DisplayType displayType;
  final PeriodPagedRequest<LPagedResponse<T>, T> request;
  final EntityWidgetBuilder<T> detailWidgetBuilder;
  final EntityAndItemsWidgetBuilder<T> subtitleWidgetBuilder;

  const PeriodSelector({
    required this.entityType,
    this.displayType = DisplayType.list,
    required this.request,
    required this.detailWidgetBuilder,
    required this.subtitleWidgetBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PeriodSelectorState<T>();
}

class _PeriodSelectorState<T extends HasPlayCount>
    extends State<PeriodSelector<T>> {
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
              key: _entityDisplayComponentKey,
              displayType: _displayType,
              request: widget.request,
              detailWidgetBuilder: widget.detailWidgetBuilder,
              subtitleWidgetBuilder: widget.subtitleWidgetBuilder,
              scoreboardItems: [
                ScoreboardItemModel.future(
                  label: 'Scrobbles',
                  futureProvider: () => GetRecentTracksRequest(
                    widget.request.username,
                    from: (widget.request.period ?? Preferences.period.value)
                        .relativeStart,
                    to: (widget.request.period ?? Preferences.period.value).end,
                  )
                      .getNumItems()
                      .errorToNull<RecentListeningInformationHiddenException>(),
                ),
                ScoreboardItemModel.future(
                  label: '${widget.entityType.displayName}s',
                  futureProvider: () => widget.request.getNumItems(),
                ),
              ],
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
