# Finale

A fully-featured Last.fm client and scrobbler with Shazam-like scrobbling written in Flutter.

The app is available on [iOS](https://apps.apple.com/us/app/finale-for-last-fm/id1518365620), [Android](https://play.google.com/store/apps/details?id=com.nrubintech.finale), the [web](https://web.finale.app/), and [macOS](https://apps.apple.com/us/app/finale-for-last-fm/id1518365620). Note that the web and macOS versions don't support music recognition.

Check out [finale.app](https://finale.app) for screenshots.

## Running the app

To run Finale, you'll need:
* [Flutter](https://flutter.dev/docs/get-started/install)
* A [Last.fm API key and secret](https://www.last.fm/api/account/create)
* To use the music recognition feature, you'll need [ACRCloud credentials](https://www.acrcloud.com)
* To use Spotify search, you'll need a [Spotify client ID](https://developer.spotify.com/dashboard)
* To run Finale on an iOS device or Mac, you'll also need:
    * A Mac
    * Xcode 11 or greater
    * An [Apple Developer account](https://developer.apple.com) (personal account will work)

1. `$ git clone https://github.com/nrubin29/finale.git`
2. Rename `env_sample.dart` in `lib/` to `env.dart` and fill in your keys
3. `$ flutter pub get`
4. `$ flutter pub run build_runner build`

### Running the app on an iOS device or Mac

5. `$ cd ios` or `$ cd macos`
6. `$ pod install`
7. `$ open Runner.xcworkspace`
8. Click on Runner on the left, then Signing & Capabilities, then choose your personal team as the Team
9. Change the bundle identifier to something unique; you can just append your username
10. At the top left, choose your device as the target device
11. Click run!
