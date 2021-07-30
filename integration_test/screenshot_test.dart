/// Automatically takes screenshots for the App Store and Play Store.
import 'dart:io';

import 'package:finale/env.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/util/util.dart';
import 'package:finale/views/album_view.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/main_view.dart';
import 'package:finale/views/scrobble_album_view.dart';
import 'package:finale/views/track_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OffsetLayer;
import 'package:flutter_test/flutter_test.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

const device = String.fromEnvironment('device');
final isIos = device.contains('iPhone') || device.contains('iPad');
final isIpad = device.contains('iPad');
const directory =
    '/Users/nrubin29/Documents/FlutterProjects/finale/screenshots/$device';

Future<void> main() async {
  if (isIos) {
    await Directory(directory).create();
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(
        const {'name': testName, 'key': testKey});
    await Preferences().setup();
    await ImageIdCache().setup();
  });

  /// Pumps [widget] inside of a [FinaleTheme]d [MaterialApp].
  ///
  /// If [asPage] is true, [widget] will be pushed as a route so that the back
  /// button will be displayed in the top left corner.
  ///
  /// If [widgetBehindModal] is not null, [widget] will be displayed as a bar
  /// bottom modal on top of [widgetBehindModal].
  Future<void> pumpWidget(WidgetTester tester, Widget widget,
      {bool asPage = false, Widget? widgetBehindModal}) async {
    await tester.pumpWidget(MaterialApp(
      title: 'Finale',
      theme: FinaleTheme.light,
      darkTheme: FinaleTheme.dark,
      debugShowCheckedModeBanner: false,
      home: asPage || widgetBehindModal != null
          ? _AsPage(widget: widget, widgetBehindModal: widgetBehindModal)
          : widget,
    ));

    if (asPage || widgetBehindModal != null) {
      await tester.pumpMany();
    }

    await tester.pumpAndSettle();
  }

  testWidgets('Profile screen', (tester) async {
    await pumpWidget(tester, MainView(username: testName));
    await tester.saveScreenshot('1_profile');
  });

  testWidgets('Scrobble screen', (tester) async {
    await pumpWidget(tester, MainView(username: testName));
    await tester.tap(find.byIcon(scrobbleIcon).at(1));

    final formFields =
        find.byWidgetPredicate((widget) => widget is TextFormField);
    await tester.enterText(formFields.at(0), 'A Lack of Color');
    await tester.enterText(formFields.at(1), 'Death Cab for Cutie');
    await tester.enterText(formFields.at(2), 'Transatlanticism');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.saveScreenshot('2_scrobble');
  });

  testWidgets('Weekly track screen', (tester) async {
    await pumpWidget(tester, MainView(username: testName));
    await tester.tap(find.byIcon(Icons.access_time));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    await tester.pumpMany();
    await tester.pumpMany();
    await tester.saveScreenshot('3_weekly_track');
  });

  testWidgets('Collage screen', (tester) async {
    await pumpWidget(tester, MainView(username: testName));
    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate'));
    await tester.pumpMany();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.saveScreenshot('4_collage');
  });

  testWidgets('Track screen', (tester) async {
    final track = await Lastfm.getTrack(BasicConcreteTrack(
        'A Lack of Color', 'Death Cab for Cutie', 'Transatlanticism'));

    await pumpWidget(tester, TrackView(track: track), asPage: true);
    await tester.saveScreenshot('5_track');
  });

  testWidgets('Artist screen', (tester) async {
    final artist = await Lastfm.getArtist(ConcreteBasicArtist('Mae'));

    await pumpWidget(tester, ArtistView(artist: artist), asPage: true);
    await tester.saveScreenshot('6_artist');
  });

  testWidgets('Album screen', (tester) async {
    final album =
        await Lastfm.getAlbum(FullConcreteAlbum('Deas Vail', 'Deas Vail'));

    await pumpWidget(tester, AlbumView(album: album), asPage: true);
    await tester.saveScreenshot('7_album');
  });

  testWidgets('Album scrobble screen', (tester) async {
    final album =
        await Lastfm.getAlbum(FullConcreteAlbum('Deas Vail', 'Deas Vail'));

    await pumpWidget(tester, ScrobbleAlbumView(album: album),
        widgetBehindModal: AlbumView(album: album));
    await tester.saveScreenshot('8_album_scrobble');
  });
}

class _AsPage extends StatefulWidget {
  final Widget widget;
  final Widget? widgetBehindModal;

  const _AsPage({required this.widget, this.widgetBehindModal});

  @override
  State<StatefulWidget> createState() => _AsPageState();
}

class _AsPageState extends State<_AsPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () async {
      if (widget.widgetBehindModal != null) {
        await showBarModalBottomSheet(
            context: context,
            duration: Duration.zero,
            builder: (_) => widget.widget);
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => widget.widget));
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.widgetBehindModal ?? SizedBox();
}

extension on WidgetTester {
  Future<void> saveScreenshot(String name) async {
    if (isIos) {
      final element = find.byType(MaterialApp).evaluate().single;

      // BEGIN: Copied from flutter_test/lib/src/_matchers_io.dart:23 because I
      // need to set [pixelRatio].
      assert(element.renderObject != null);
      var renderObject = element.renderObject!;
      while (!renderObject.isRepaintBoundary) {
        renderObject = renderObject.parent! as RenderObject;
      }
      assert(!renderObject.debugNeedsPaint);
      final layer = renderObject.debugLayer! as OffsetLayer;
      final image =
          layer.toImage(renderObject.paintBounds, pixelRatio: isIpad ? 2 : 3);
      // END: Copied code.

      await expectLater(image, matchesGoldenFile('$directory/$name.png'));
    } else {
      // On Android, we can't save screenshots for some reason, so we have to
      // take them ourselves.
      await pumpMany();
      await pumpMany();
    }
  }

  /// Pumps for 10 seconds, 100 milliseconds at a time.
  Future<void> pumpMany() async {
    final endTime = binding.clock.fromNowBy(const Duration(seconds: 10));
    do {
      await binding.pump(const Duration(milliseconds: 100));
    } while (binding.clock.now().isBefore(endTime));
  }
}
