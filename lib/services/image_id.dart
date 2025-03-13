import 'package:finale/services/generic.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:html/parser.dart' show parse;

enum ImageQuality {
  low(64),
  high(470);

  final double width;

  const ImageQuality(this.width);
}

/// An image identifier that can be used to build an image URL for a given
/// service.
class ImageId {
  final String _lowQualityUrl;
  final String _highQualityUrl;
  final String serializedValue;

  // small=34s, medium=64s, large=174s, extralarge=300x300
  const ImageId.lastfm(String imageId)
    : _lowQualityUrl =
          'https://lastfm.freetls.fastly.net/i/u/174s/$imageId.jpg',
      _highQualityUrl =
          'https://lastfm.freetls.fastly.net/i/u/470x470/$imageId.jpg',
      serializedValue = imageId;

  const ImageId.spotify(String lowQualityImageId, String highQualityImageId)
    : _lowQualityUrl = 'https://i.scdn.co/image/$lowQualityImageId',
      _highQualityUrl = 'https://i.scdn.co/image/$highQualityImageId',
      serializedValue = '$lowQualityImageId|$highQualityImageId';

  factory ImageId.fromSerializedValue(String serializedValue) {
    if (serializedValue.contains('|')) {
      final parts = serializedValue.split('|');
      return ImageId.spotify(parts[0], parts[1]);
    }

    return ImageId.lastfm(serializedValue);
  }

  /// Creates an [ImageIdProvider] that scrapes an ImageId from the web.
  ///
  /// First, it loads [url], then it finds the element matching [selector], then
  /// it access attribute [attribute] which should contain the image url.
  /// Finally, it extracts the image id from the image url.
  ///
  /// The web app can't scrape images due to CORS, so if [spotifyFallback] is
  /// specified and the user is logged in with Spotify, the web app will execute
  /// the request and return the image id if a result is found.
  static ImageIdProvider scrape(
    String? url,
    String selector, {
    String attribute = 'href',
    bool endUrlAtPeriod = false,
    PagedRequest<Entity>? spotifyFallback,
  }) => () async {
    if (isWeb) {
      if (spotifyFallback != null && Preferences.hasSpotifyAuthData) {
        final fallbackEntity = await spotifyFallback.getData(1, 1);
        if (fallbackEntity.isNotEmpty) {
          return fallbackEntity.single.imageId ??
              await fallbackEntity.single.imageIdProvider?.call();
        }
      }
      return null;
    }

    if (url == null) {
      return null;
    }

    final lastfmResponse = await httpClient.get(Uri.parse(url));

    try {
      final doc = parse(lastfmResponse.body);
      final rawUrl = doc.querySelector(selector)?.attributes[attribute];

      if (rawUrl == null) {
        return null;
      }

      final imageId = rawUrl.substring(
        rawUrl.lastIndexOf('/') + 1,
        endUrlAtPeriod ? rawUrl.lastIndexOf('.') : null,
      );
      return ImageId.lastfm(imageId);
    } on Exception {
      return null;
    }
  };

  String getUrl(ImageQuality quality) {
    return quality == ImageQuality.low ? _lowQualityUrl : _highQualityUrl;
  }
}
