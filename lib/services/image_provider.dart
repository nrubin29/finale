import 'dart:typed_data';

import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/preferences.dart';
import 'package:html/parser.dart';
import 'package:meta/meta.dart';

sealed class ImageProvider {
  ImageProvider._();

  factory ImageProvider.imageId(ImageId imageId) => ImageIdProvider._(imageId);

  factory ImageProvider.data(Uint8List? imageData) =>
      DataImageProvider._(imageData);

  factory ImageProvider.delegated(String? url, Future<Entity?> delegate) =>
      DelegatedImageProvider._(url, delegate);

  factory ImageProvider.scrapeLastfmImageId(
    String? url, {
    required String selector,
    required PagedRequest<Entity> spotifyFallback,
  }) {
    if (!isWeb) {
      return ScrapingImageIdProvider._(url, selector: selector);
    }

    if (!Preferences.hasSpotifyAuthData) {
      return .delegated(url, .value(null));
    }

    return .delegated(
      url,
      spotifyFallback.getData(1, 1).then((items) => items.firstOrNull),
    );
  }

  Future<ImageId?> loadImageId();
}

class ImageIdProvider extends ImageProvider {
  final ImageId imageId;

  ImageIdProvider._(this.imageId) : super._();

  @override
  Future<ImageId?> loadImageId() async => imageId;
}

class DataImageProvider extends ImageProvider {
  final Uint8List? imageData;

  DataImageProvider._(this.imageData) : super._();

  @override
  Future<ImageId?> loadImageId() async => null;
}

sealed class CachingImageProvider extends ImageProvider {
  final String? _url;
  ImageId? _cachedImageId;

  CachingImageProvider._(this._url) : super._();

  @override
  @nonVirtual
  Future<ImageId?> loadImageId() async {
    if (_cachedImageId != null) {
      return _cachedImageId;
    }

    if (_url case final url?) {
      try {
        final cachedValue = await ImageIdCache().get(url);
        if (cachedValue != null) {
          return _cachedImageId = cachedValue;
        }
      } on Exception {
        // Do nothing.
      }
    }

    final imageId = await _fetchImageId();
    if (imageId != null) {
      _cachedImageId = imageId;
      if (_url case final url?) {
        await ImageIdCache().insert(url, imageId);
      }
    }
    return imageId;
  }

  Future<ImageId?> _fetchImageId();
}

class DelegatedImageProvider extends CachingImageProvider {
  final Future<Entity?> delegate;

  DelegatedImageProvider._(super.url, this.delegate) : super._();

  @override
  Future<ImageId?> _fetchImageId() async {
    if (await delegate case final entity?) {
      return await entity.imageProvider?.loadImageId();
    }
    return null;
  }
}

class ScrapingImageIdProvider extends CachingImageProvider {
  final String selector;

  ScrapingImageIdProvider._(super.url, {required this.selector}) : super._();

  @override
  Future<ImageId?> _fetchImageId() async {
    final url = _url;
    if (url == null) return null;

    final lastfmResponse = await httpClient.get(.parse(url));

    try {
      final doc = parse(lastfmResponse.body);
      final rawUrl = doc.querySelector(selector)?.attributes['href'];

      if (rawUrl == null) {
        return null;
      }

      final rawImageId = rawUrl.substring(rawUrl.lastIndexOf('/') + 1);
      return .lastfm(rawImageId);
    } on Exception {
      // Do nothing.
    }

    return null;
  }
}
