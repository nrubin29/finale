import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/strava/activity.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:flutter/material.dart';

class WorkoutDetails extends StatelessWidget {
  final AthleteActivity activity;

  const WorkoutDetails({required this.activity});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: createAppBar(
            activity.name,
            subtitle: activity.localTimeRangeFormatted,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(activity.icon)),
                const Tab(icon: Icon(Icons.queue_music)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView(
                children: [
                  ListTile(
                    title: const Text('Time'),
                    trailing: Text(formatDuration(
                        Duration(seconds: activity.elapsedTime))),
                  ),
                  if (activity.distance > 0)
                    ListTile(
                      title: const Text('Distance'),
                      trailing:
                          Text(formatScrobbles(activity.distance, 'mile')),
                    ),
                  if (activity.totalElevationGain > 0)
                    ListTile(
                      title: const Text('Elevation Gain'),
                      trailing: Text('${activity.totalElevationGain} ft'),
                    ),
                  if (activity.averageSpeed > 0)
                    ListTile(
                      title: const Text('Average Speed'),
                      trailing: Text(
                          '${activity.averageSpeed.toStringAsFixed(1)} mph'),
                    ),
                  if (activity.averageHeartRate != null)
                    ListTile(
                      title: const Text('Average Heart Rate'),
                      trailing: Text('${activity.averageHeartRate} bpm'),
                    ),
                ],
              ),
              EntityDisplay<LRecentTracksResponseTrack>(
                request: GetRecentTracksRequest(
                    /*Preferences().name!*/
                    'nrubin29',
                    from: activity.startDate,
                    to: activity.endDate),
                detailWidgetBuilder: (track) => TrackView(track: track),
              ),
            ],
          ),
        ),
      );
}
