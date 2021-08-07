import 'dart:async';

import 'package:finale/services/generic.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/scrobble/batch_scrobble_view.dart';
import 'package:finale/widgets/scrobble/scrobble_view.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// A button that, when tapped, opens the appropriate scrobble view.
///
/// Either [entity] or [entityProvider] must be specified depending on if the
/// [Entity] is available immediately or if it must be fetched.
class ScrobbleButton<T extends Entity> extends StatefulWidget {
  final T? entity;
  final Future<T> Function()? entityProvider;
  final Color? color;

  const ScrobbleButton({this.entity, this.entityProvider, this.color})
      : assert(entity != null || entityProvider != null);

  @override
  State<StatefulWidget> createState() => _ScrobbleButtonState<T>();
}

class _ScrobbleButtonState<T extends Entity> extends State<ScrobbleButton<T>> {
  T? _cachedEntity;

  void _onPressed() async {
    if (_cachedEntity == null) {
      if (widget.entity != null) {
        _cachedEntity = widget.entity;
      } else {
        _cachedEntity = await widget.entityProvider!();
      }
    }

    Widget scrobbleView;

    if (_cachedEntity is HasTracks) {
      if ((_cachedEntity as HasTracks).tracks.isEmpty) {
        _showSnackbar(
            "This ${_cachedEntity!.type.name} doesn't have any tracks.");
        return;
      } else if (!(_cachedEntity as HasTracks).canScrobble) {
        _showSnackbar(
            "Can't scrobble ${_cachedEntity!.type.name} because track duration "
            'data is missing.');
        return;
      }

      scrobbleView = BatchScrobbleView(entity: _cachedEntity as HasTracks);
    } else if (_cachedEntity is Track) {
      scrobbleView = ScrobbleView(track: _cachedEntity as Track, isModal: true);
    } else {
      assert(false, "${_cachedEntity.runtimeType} can't be scrobbled.");
      return;
    }

    final result = await showBarModalBottomSheet<bool>(
        context: context,
        duration: const Duration(milliseconds: 200),
        builder: (_) => scrobbleView);

    if (result != null) {
      if (result) {
        _showSnackbar('Scrobbled successfully!');

        // Ask for a review.
        if (isMobile && await InAppReview.instance.isAvailable()) {
          InAppReview.instance.requestReview();
        }
      } else {
        _showSnackbar('An error occurred while scrobbling.');
      }
    }
  }

  void _showSnackbar(String text) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(scrobbleIcon),
        color: widget.color,
        onPressed: _onPressed,
      );
}
