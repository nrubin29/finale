import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/settings/lastfm_login_web_view.dart';
import 'package:finale/widgets/settings/lastfm_settings_view.dart';
import 'package:flutter/material.dart';

Future<bool> ensureCookies(BuildContext context) async {
  if (await LastfmCookie.hasCookies()) {
    return true;
  }

  if (!context.mounted) return false;
  return await showCookieDialog(context);
}

Future<bool> showCookieDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => const CookieDialog(),
      ) ??
      false;
}

class CookieDialog extends StatelessWidget {
  const CookieDialog();

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Row(
      spacing: 8,
      children: [Icon(SocialMediaIcons.lastfm), Text('Advanced Feature')],
    ),
    content: const Text(
      'This feature requires you to log in again using a different '
      'method.',
    ),
    actions: [
      TextButton(
        child: const Text('Cancel'),
        onPressed: () => Navigator.pop(context, false),
      ),
      TextButton(
        child: const Text('Details'),
        onPressed: () {
          Navigator.pop(context, false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LastfmSettingsView()),
          );
        },
      ),
      TextButton(
        child: const Text('Log in'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LastfmLoginWebView()),
          );
          final result = await LastfmCookie.hasCookies();
          if (!context.mounted) return;
          Navigator.pop(context, result);
        },
      ),
    ],
  );
}
