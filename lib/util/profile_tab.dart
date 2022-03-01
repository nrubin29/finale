import 'package:flutter/material.dart';

enum ProfileTab {
  recentScrobbles,
  topArtists,
  topAlbums,
  topTracks,
  friends,
  charts,
}

extension ProfileTabDisplayName on ProfileTab {
  String get displayName {
    switch (this) {
      case ProfileTab.recentScrobbles: return 'Recent Scrobbles';
      case ProfileTab.topArtists: return 'Top Artists';
      case ProfileTab.topAlbums: return 'Top Albums';
      case ProfileTab.topTracks: return 'Top Tracks';
      case ProfileTab.friends: return 'Friends';
      case ProfileTab.charts: return 'Charts';
    }
  }
}

extension ProfileTabIcon on ProfileTab {
  IconData get icon {
    switch (this) {
      case ProfileTab.recentScrobbles: return Icons.queue_music;
      case ProfileTab.topArtists: return Icons.people;
      case ProfileTab.topAlbums: return Icons.album;
      case ProfileTab.topTracks: return Icons.audiotrack;
      case ProfileTab.friends: return Icons.person;
      case ProfileTab.charts: return Icons.access_time;
    }
  }
}
