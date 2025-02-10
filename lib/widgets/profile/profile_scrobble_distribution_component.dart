import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/widgets/entity/lastfm/scrobble_distribution/scrobble_distribution_component.dart';
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
      );
}
