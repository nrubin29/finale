import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/settings/lastfm_login_web_view.dart';
import 'package:finale/widgets/settings/lastfm_settings_view.dart';
import 'package:flutter/material.dart';

Future<bool> ensureCookies(BuildContext context) async {
  final hasCookies = await LastfmCookie.hasCookies();
  final isExpired = DateTime.now().isAfter(
    Preferences.cookieExpirationDate.value,
  );

  if (hasCookies && !isExpired) {
    return true;
  }

  if (!context.mounted) return false;
  return await _showCookieDialog(context, isExpired: hasCookies && isExpired);
}

Future<bool> _showCookieDialog(
  BuildContext context, {
  bool isExpired = false,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => CookieDialog(isExpired: isExpired),
      ) ??
      false;
}

class CookieDialog extends StatelessWidget {
  final bool isExpired;

  const CookieDialog({this.isExpired = false});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      spacing: 8,
      children: [
        const Icon(SocialMediaIcons.lastfm),
        isExpired
            ? const Text('Credentials expired')
            : const Text('Advanced Feature'),
      ],
    ),
    content: isExpired
        ? const Text(
            'Your credentials have expired and you need to log in again.',
          )
        : const Text(
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
