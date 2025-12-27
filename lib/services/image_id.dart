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

  String getUrl(ImageQuality quality) {
    return quality == .low ? _lowQualityUrl : _highQualityUrl;
  }
}
