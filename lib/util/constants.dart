import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

const isDebug = kDebugMode;
const isWeb = kIsWeb;
final isDesktop = !isWeb && Platform.isMacOS;
final isMobile = !isWeb && !isDesktop;

const isScreenshotTest =
    bool.fromEnvironment('isScreenshotTest', defaultValue: false);
const censorImages = bool.fromEnvironment('censorImages', defaultValue: false);

const authCallbackUrl = isWeb
    ? isDebug
        ? 'http://localhost:52486/auth.html'
        : 'https://web.finale.app/auth.html'
    : 'finale://web.finale.app/auth';

const spotifyGreen = Color.fromRGBO(30, 215, 96, 1);
const appleMusicPink = Color.fromRGBO(252, 90, 113, 1);
const scrobbleIcon = Icons.playlist_add;

const rateLimitExceededMessage =
    'Too many people are using Finale right now. Please try again. If the '
    'error persists, try again later.';
