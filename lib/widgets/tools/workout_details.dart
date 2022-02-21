import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/strava/activity.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:flutter/material.dart';

class WorkoutDetails extends StatelessWidget {
  final AthleteActivity activity;

  const WorkoutDetails({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(activity.name),
      body: EntityDisplay<LRecentTracksResponseTrack>(
        request: GetRecentTracksRequest(/*Preferences().name!*/ 'nrubin29',
            from: activity.startDate, to: activity.endDate),
        detailWidgetBuilder: (track) => TrackView(track: track),
      ),
    );
  }
}
