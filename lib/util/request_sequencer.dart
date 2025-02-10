class RequestHandle {
  final RequestSequencer _requestIdManager;

  RequestHandle._(this._requestIdManager);

  bool get isLatestRequest => _requestIdManager._latestRequestHandle == this;
}

/// Keeps track of the latest request in a sequence.
///
/// Clients call [startRequest] before starting a request, then call
/// [RequestHandle.isLatestRequest] when the request is finished to see if they
/// should use the data or if the user sent another request while the data was
/// being fetched.
class RequestSequencer {
  RequestHandle? _latestRequestHandle;

  RequestHandle startRequest() => _latestRequestHandle = RequestHandle._(this);
}
