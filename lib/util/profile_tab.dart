import 'package:flutter/material.dart';

enum ProfileTab {
  recentScrobbles('Recent Scrobbles', Icons.queue_music),
  topArtists('Top Artists', Icons.people),
  topAlbums('Top Albums', Icons.album),
  topTracks('Top Tracks', Icons.audiotrack),
  friends('Friends', Icons.person),
  charts('Charts', Icons.access_time_filled),
  scrobbleDistribution(
    'Scrobble Distribution',
    Icons.bar_chart,
    iconRotationDegrees: 90,
  ),
  ;

  final String displayName;
  final IconData icon;
  final int? iconRotationDegrees;

  const ProfileTab(this.displayName, this.icon, {this.iconRotationDegrees});
}
