import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/util/web_auth.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LastfmLoginWebView extends StatefulWidget {
  const LastfmLoginWebView();

  @override
  State<LastfmLoginWebView> createState() => _LastfmLoginWebViewState();
}

class _LastfmLoginWebViewState extends State<LastfmLoginWebView> {
  final _controller = WebViewController();

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  void _setUp() async {
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) async {
          if (request.url.startsWith(authCallbackUrl)) {
            await LastfmCookie.loadCookiesFromWebView();
            if (!mounted) return .prevent;
            Navigator.of(context).pop();
            return .prevent;
          }
          return .navigate;
        },
      ),
    );

    await _controller.loadRequest(Lastfm.authorizationUri);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(context, 'Log in with Last.fm'),
    body: WebViewWidget(controller: _controller),
  );
}
