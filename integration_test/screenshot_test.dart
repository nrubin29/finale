/// Automatically takes screenshots for the App Store and Play Store.
import 'dart:io';

import 'package:finale/env.dart';
import 'package:finale/main.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });

  Future<void> settle(WidgetTester tester) async {
    try {
      await tester.pumpAndSettle(const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate, const Duration(seconds: 3));
    } on FlutterError {
      // [pumpAndSettle] will time out, but that's fine.
    }
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(MyApp(screenshotController));
    await settle(tester);
  }

  Future<void> saveScreenshot(String name) async {
    final image = await screenshotController.capture();
    expect(image, isNotNull);
    await File('$directory/$name.png').writeAsBytes(image!);
  }

  testWidgets('Profile screen', (tester) async {
    await pumpApp(tester);
    await saveScreenshot('1_profile');
  });

  testWidgets('Scrobble screen', (tester) async {
    await pumpApp(tester);
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
}
