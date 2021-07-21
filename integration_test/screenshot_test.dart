/// Automatically takes screenshots for the App Store and Play Store.
import 'dart:io';

import 'package:finale/env.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/views/album_view.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/main_view.dart';
import 'package:finale/views/scrobble_album_view.dart';
import 'package:finale/views/track_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

const device = String.fromEnvironment('device');
const directory =
    '/Users/nrubin29/Documents/FlutterProjects/finale/screenshots/$device';

Future<void> main() async {
  await Directory(directory).create();

  late ScreenshotController screenshotController;

  setUp(() async {
    screenshotController = ScreenshotController();
    SharedPreferences.setMockInitialValues(
        const {'name': testName, 'key': testKey});
    await Preferences().setup();
    await ImageIdCache().setup();
  });

  Future<void> settle(WidgetTester tester, {int times = 1}) async {
    await tester.runAsync(() => Future.delayed(Duration(seconds: 5 * times)));
    try {
      await tester.pumpAndSettle(const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate, Duration(seconds: 5 * times));
    } on FlutterError {
      // [pumpAndSettle] might time out, but that's fine.
    }
  }

  /// Pumps [widget] inside of a [FinaleTheme]d [MaterialApp] and [Screenshot].
  ///
  /// If [asPage] is true, [widget] will be pushed as a route so that the back
  /// button will be displayed in the top left corner.
  Future<void> pumpWidget(WidgetTester tester, Widget widget,
      {bool asPage = false,
      bool asModal = false,
      bool settleLong = false}) async {
    await tester.pumpWidget(MaterialApp(
      title: 'Finale',
      theme: FinaleTheme.light,
      darkTheme: FinaleTheme.dark,
      home: asPage || asModal
          ? _AsPage(
              widget: widget,
              screenshotController: screenshotController,
              asModal: asModal)
          : Screenshot(controller: screenshotController, child: widget),
    ));
    await settle(tester, times: settleLong ? 6 : 1);
  }

  Future<void> saveScreenshot(String name) async {
    final image = await screenshotController.capture();
    expect(image, isNotNull);
    await File('$directory/$name.png').writeAsBytes(image!);
  }

  testWidgets('Profile screen', (tester) async {
    await pumpWidget(tester, MainView(username: testName));
    await saveScreenshot('1_profile');
  });

  testWidgets('Scrobble screen', (tester) async {
    await pumpWidget(tester, MainView(username: testName));
    await tester.tap(find.byIcon(Icons.add).at(1));

    final formFields =
        find.byWidgetPredicate((widget) => widget is TextFormField);
    await tester.enterText(formFields.at(0), 'A Lack of Color');
    await tester.enterText(formFields.at(1), 'Death Cab for Cutie');
    await tester.enterText(formFields.at(2), 'Transatlanticism');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    await saveScreenshot('2_scrobble');
  });

  testWidgets('Weekly track screen', (tester) async {
    await pumpWidget(tester, MainView(username: testName));
    await tester.tap(find.byIcon(Icons.access_time));
    await settle(tester, times: 6);
    await saveScreenshot('3_weekly_track');
  });

  testWidgets('Track screen', (tester) async {
    await pumpWidget(
      tester,
      TrackView(
          track: BasicConcreteTrack(
              'A Lack of Color', 'Death Cab for Cutie', 'Transatlanticism')),
      asPage: true,
      settleLong: true,
    );
    await saveScreenshot('4_track');
  });

  testWidgets('Artist screen', (tester) async {
    await pumpWidget(
      tester,
      ArtistView(artist: ConcreteBasicArtist('Mae')),
      asPage: true,
      settleLong: true,
    );
    await saveScreenshot('5_artist');
  });

  testWidgets('Album screen', (tester) async {
    await pumpWidget(
      tester,
      // TODO: Use an actual LAlbum here so that the imageId works.
      AlbumView(album: FullConcreteAlbum('Deas Vail', 'Deas Vail')),
      asPage: true,
      settleLong: true,
    );
    await saveScreenshot('6_album');
  });

  testWidgets('Album scrobble screen', (tester) async {
    await pumpWidget(
      tester,
      ScrobbleAlbumView(album: FullConcreteAlbum('Deas Vail', 'Deas Vail')),
      asPage: true,
      settleLong: true,
    );
    await tester.tap(find.byIcon(Icons.add));
    await saveScreenshot('7_album_scrobble');
  });
}

class _AsPage extends StatefulWidget {
  final Widget widget;
  final ScreenshotController screenshotController;
  final bool asModal;

  const _AsPage(
      {required this.widget,
      required this.screenshotController,
      this.asModal = false});

  @override
  State<StatefulWidget> createState() => _AsPageState();
}

class _AsPageState extends State<_AsPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () async {
      final child = Screenshot(
          controller: widget.screenshotController, child: widget.widget);

      if (widget.asModal) {
        await showBarModalBottomSheet(
            context: context, duration: Duration.zero, builder: (_) => child);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => child));
      }
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox();
}
