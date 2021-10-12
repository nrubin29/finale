// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:http/http.dart';
import 'package:pool/pool.dart';

/// A middleware client that throttles the number of concurrent requests.
///
/// As long as the number of requests is within the limit, this works just like
/// a normal client. If a request is made beyond the limit, the underlying HTTP
/// request won't be sent until other requests have completed.
class ThrottleClient extends BaseClient {
  final Pool _pool;
  final Client _inner;

  /// Creates a new client that allows no more than [maxActiveRequests]
  /// concurrent requests.
  ///
  /// If [inner] is passed, it's used as the inner client for sending HTTP
  /// requests. It defaults to `http.Client()`.
  ThrottleClient(int maxActiveRequests, [Client? inner])
      : _pool = Pool(maxActiveRequests),
        _inner = inner ?? Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    var resource = await _pool.request();

    StreamedResponse response;
    try {
      response = await _inner.send(request);
    } catch (_) {
      resource.release();
      rethrow;
    }

    var stream = response.stream.transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
            handleDone: (sink) {
      resource.release();
      sink.close();
    }));
    return StreamedResponse(stream, response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
  }

  @override
  void close() => _inner.close();
}
