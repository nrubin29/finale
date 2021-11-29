# Finale

A fully-featured Last.fm client and scrobbler with Shazam-like scrobbling, a collage generator, and more!

The app is available on [iOS](https://apps.apple.com/us/app/finale-for-last-fm/id1518365620), [Android](https://play.google.com/store/apps/details?id=com.nrubintech.finale), the [web](https://web.finale.app/), and [macOS](https://apps.apple.com/us/app/finale-for-last-fm/id1518365620). Note that the web and macOS versions don't support Shazam-like scrobbling.

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

5. To use the iOS widget:
   1. Rename `EnvironmentSample.swift` in `ios/FinaleWidget/` to `Environment.swift`
   2. Uncomment the code and fill in your Last.fm API key and secret
6. `$ cd ios` or `$ cd macos`
7. `$ pod install`
8. `$ open Runner.xcworkspace`
9. Click on Runner on the left, then Signing & Capabilities, then choose your personal team as the Team
10. Change the bundle identifier to something unique; you can just append your username
11. At the top left, choose your device as the target device
12. Click run!
