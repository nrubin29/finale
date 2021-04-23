# Finale

A fully-featured Last.fm client and scrobbler with Shazam-like scrobbling written in Flutter.

## Running the app

To run Finale, you'll need:
* [Flutter](https://flutter.dev/docs/get-started/install)
* A [Last.fm API key and secret](https://www.last.fm/api/account/create)
* If you want to run Finale on an iOS device, you'll also need:
    * A Mac
    * Xcode 11 or greater
    * An [Apple Developer account](https://developer.apple.com) (personal account will work)

1. `$ git clone https://github.com/nrubin29/finale.git`
2. Rename `env-sample.dart` in `lib/` to `env.dart` and fill in your Last.fm API key and secret
3. `$ flutter pub get`
4. `$ flutter pub run build_runner build`

### Running the app on an iOS device

5. `cd` into the `ios/` directory and `$ pod install`
6. While still in the `ios/` directory, `$ open Runner.xcworkspace`
7. Click on Runner on the left, the Signing & Capabilities, then choose your personal team as the Team
8. Change the bundle identifier to something unique; you can just append your username
9. At the top left, choose your device as the target device
10. Click run!
