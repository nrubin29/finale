import 'package:flutter/foundation.dart'
    show kIsWeb, kDebugMode, defaultTargetPlatform;
import 'package:flutter/material.dart';

const isDebug = kDebugMode;
const isWeb = kIsWeb;
// The [isWeb] checks are necessary because on web, [defaultTargetPlatform] is
// the platform that the browser is running on.
final isIos = !isWeb && defaultTargetPlatform == TargetPlatform.iOS;
final isAndroid = !isWeb && defaultTargetPlatform == TargetPlatform.android;
final isMobile = isIos || isAndroid;

const isScreenshotTest = bool.fromEnvironment(
  'isScreenshotTest',
  defaultValue: false,
);
const censorImages = bool.fromEnvironment('censorImages', defaultValue: false);

const spotifyGreen = Color.fromRGBO(30, 215, 96, 1);
const appleMusicPink = Color.fromRGBO(252, 90, 113, 1);
const scrobbleIcon = Icons.playlist_add;
