import 'package:finale/util/constants.dart';
import 'package:flutter/material.dart';

enum ProfileTab {
  recentScrobbles('Recent Scrobbles', Icons.queue_music),
  topArtists('Top Artists', Icons.people),
  topAlbums('Top Albums', Icons.album),
  topTracks('Top Tracks', Icons.audiotrack),
  lovedTracks('Loved Tracks', Icons.favorite),
  obsessions('Obsessions', Icons.star, isSupportedOnWeb: false),
  friends('Friends', Icons.person),
  charts('Charts', Icons.access_time_filled),
  scrobbleDistribution(
    'Scrobble Distribution',
    Icons.bar_chart,
    iconRotationDegrees: 90,
  );

  final String displayName;
  final IconData icon;
  final int? iconRotationDegrees;
  final bool isSupportedOnWeb;

  const ProfileTab(
    this.displayName,
    this.icon, {
    this.iconRotationDegrees,
    this.isSupportedOnWeb = true,
  });

  static List<ProfileTab> get allowedValues => values
      .where((profileTab) => !isWeb || profileTab.isSupportedOnWeb)
      .toList(growable: false);
}
