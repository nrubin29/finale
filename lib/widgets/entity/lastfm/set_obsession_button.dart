import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/services/lastfm/obsessions.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:finale/widgets/entity/lastfm/cookie_dialog.dart';
import 'package:flutter/material.dart';

Future<void> setObsessionInUi(BuildContext context, Track track) async {
  if (!await ensureCookies(context)) {
    return;
  }

  if (!context.mounted) return;
  final reason = await showInputDialog(
    context,
    title: 'Set obsession',
    content:
        'Tell everyone why ${track.name} is your current obsession. '
        '(optional)',
    icon: Icons.star,
  );
  if (reason == null) return;
  final success = await LastfmCookie.setObsession(track, reason);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: success
          ? const Text('Obsession set!')
          : const Text('Failed to set obsession.'),
    ),
  );
}

Future<bool> deleteObsessionInUi(
  BuildContext context,
  LObsession obsession,
) async {
  if (!await ensureCookies(context)) {
    return false;
  }

  if (!context.mounted) return false;
  final success = await LastfmCookie.deleteObsession(obsession);
  if (!context.mounted || success) return success;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Failed to delete obsession.')));
  return false;
}

class SetObsessionButton extends StatelessWidget {
  final Track track;

  const SetObsessionButton({required this.track});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
    onPressed: () {
      setObsessionInUi(context, track);
    },
  );
}
