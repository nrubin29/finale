import 'package:finale/services/generic.dart';
import 'package:finale/util/profile_tab.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'time_safe_stream.dart';

/// An action taken outside of the app that causes the app to open.
///
/// Sources are quick actions, iOS widgets, and notifications.
class ExternalAction {
  final ExternalActionType type;
  final dynamic value;

  ExternalAction.scrobbleOnce()
      : type = ExternalActionType.scrobbleOnce,
        value = null;

  ExternalAction.scrobbleContinuously()
      : type = ExternalActionType.scrobbleContinuously,
        value = null;

  ExternalAction.viewAlbum(BasicAlbum album)
      : type = ExternalActionType.viewAlbum,
        value = album;

  ExternalAction.viewArtist(BasicArtist artist)
      : type = ExternalActionType.viewArtist,
        value = artist;

  ExternalAction.viewTrack(Track track)
      : type = ExternalActionType.viewTrack,
        value = track;

  ExternalAction.viewTab(ProfileTab tab)
      : type = ExternalActionType.viewTab,
        value = tab;

  ExternalAction.openSpotifyChecker()
      : type = ExternalActionType.openSpotifyChecker,
        value = null;
}

enum ExternalActionType {
  scrobbleOnce,
  scrobbleContinuously,
  viewAlbum,
  viewArtist,
  viewTrack,
  viewTab,
  openSpotifyChecker,
}

// This stream needs to be open for the entire lifetime of the app.
// ignore: close_sinks
@protected
final externalActions = ReplaySubject<Timestamped<ExternalAction>>();

/// A stream of [ExternalAction]s that should be handled.
Stream<ExternalAction> get externalActionsStream =>
    externalActions.timeSafeStream();
