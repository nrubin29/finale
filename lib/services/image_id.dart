enum ImageQuality { low, high }

/// An image identifier that can be used to build an image URL for a given
/// service.
class ImageId {
  final String _lowQualityUrl;
  final String _highQualityUrl;
  final String serializedValue;

  // small=34s, medium=64s, large=174s, extralarge=300x300
  const ImageId.lastfm(String imageId)
      : this._lowQualityUrl =
            'https://lastfm.freetls.fastly.net/i/u/64s/$imageId.jpg',
        this._highQualityUrl =
            'https://lastfm.freetls.fastly.net/i/u/300x300/$imageId.jpg',
        this.serializedValue = imageId;

  const ImageId.spotify(String lowQualityImageId, String highQualityImageId)
      : this._lowQualityUrl = 'https://i.scdn.co/image/$lowQualityImageId',
        this._highQualityUrl = 'https://i.scdn.co/image/$highQualityImageId',
        this.serializedValue = '$lowQualityImageId|$highQualityImageId';

  factory ImageId.fromSerializedValue(String serializedValue) {
    if (serializedValue.contains('|')) {
      final parts = serializedValue.split('|');
      return ImageId.spotify(parts[0], parts[1]);
    }

    return ImageId.lastfm(serializedValue);
  }

  String getUrl(ImageQuality quality) {
    return quality == ImageQuality.low ? _lowQualityUrl : _highQualityUrl;
  }
}
