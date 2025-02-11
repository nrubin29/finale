import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/scrobble_distribution/scrobble_distribution_component.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:flutter/material.dart';

class ProfileScrobbleDistributionComponent extends StatelessWidget {
  final String username;

  const ProfileScrobbleDistributionComponent({required this.username});

  @override
  Widget build(BuildContext context) => ScrobbleDistributionComponent(
        username: username,
        fetchScrobbleCounts: (ranges) => ranges.map((range) =>
            GetRecentTracksRequest(username, from: range.start, to: range.end)
                .getNumItems()),
        onDayTapped: (item) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: createAppBar(
                  context,
                  dateFormatWithYear.format(item.dateTime),
                  subtitle: pluralize(item.scrobbles),
                ),
                body: EntityDisplay<LRecentTracksResponseTrack>(
                  request: GetRecentTracksRequest(username,
                      from: item.dateTimeRange.start,
                      to: item.dateTimeRange.end),
                  detailWidgetBuilder: (track) => TrackView(track: track),
                ),
              ),
            ),
          );
        },
      );
}
