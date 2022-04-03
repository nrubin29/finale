import 'package:finale/util/preferences.dart';
import 'package:flutter/material.dart';

abstract class EntityWidget extends StatelessWidget {
  /// The username of the user whose profile linked to this view.
  ///
  /// If not null and not the current user, this user's scrobbles will be
  /// included in the stats.
  final String? username;

  const EntityWidget(this.username);

  bool get hasFriend => username != null && username != Preferences().name;
}