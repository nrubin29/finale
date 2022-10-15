import 'dart:async';
import 'dart:collection';

import 'package:finale/services/generic.dart';
import 'package:flutter/cupertino.dart';

class EntityDisplayController<T extends Entity> {
  final bool isBackedByRequest;
  final _changes = StreamController<void>.broadcast();

  var _items = <T>[];
  var _page = 1;
  var _didInitialRequest = false;
  var _isDoingRequest = false;
  var _hasMorePages = true;

  /// Keeps track of the latest request.
  ///
  /// When a new request starts, this value is incremented. When a request ends,
  /// we make sure it's still the latest request before using the data.
  var _requestId = 0;

  PagedRequest<T>? _request;
  StreamSubscription? _subscription;

  Exception? _exception;
  StackTrace? _stackTrace;

  EntityDisplayController.forItems(this._items)
      : _didInitialRequest = true,
        _hasMorePages = false,
        isBackedByRequest = false;

  EntityDisplayController.forRequest(PagedRequest<T> this._request)
      : isBackedByRequest = true;

  EntityDisplayController.forRequestStream(Stream<PagedRequest<T>> stream)
      : isBackedByRequest = true {
    _subscription = stream.listen((newRequest) {
      _request = newRequest;
      getInitialItems();
    });
  }

  List<T> get items => UnmodifiableListView(_items);

  bool get didInitialRequest => _didInitialRequest;

  bool get isDoingRequest => _isDoingRequest;

  bool get hasMorePages => _hasMorePages;

  PagedRequest<T>? get request => _request;

  bool get hasException => _exception != null && _stackTrace != null;

  Exception? get exception => _exception;

  StackTrace? get stackTrace => _stackTrace;

  Stream<void> get changes => _changes.stream;

  Future<void> getInitialItems() async {
    if (_request == null) return;

    _didInitialRequest = false;
    _isDoingRequest = true;
    _changes.add(null);

    final id = ++_requestId;

    try {
      final initialItems = await _request!.getData(20, 1);
      if (id == _requestId) {
        _items = [...initialItems];
        _hasMorePages = initialItems.length >= 20;
        _didInitialRequest = true;

        if (_hasMorePages) {
          _page = 2;
        }
      }
    } on Exception catch (exception, stackTrace) {
      _exception = exception;
      _stackTrace = stackTrace;
      _items = <T>[];
      _hasMorePages = false;
      _didInitialRequest = true;
      debugPrintStack(stackTrace: stackTrace, label: exception.toString());
    } finally {
      _isDoingRequest = false;
      _changes.add(null);
    }
  }

  Future<void> getMoreItems() async {
    if (_request == null || _isDoingRequest || !_hasMorePages) return;

    _isDoingRequest = true;
    _changes.add(null);

    final id = ++_requestId;

    try {
      final moreItems = await _request!.getData(20, _page);
      if (id == _requestId) {
        _items.addAll(moreItems);
        _hasMorePages = moreItems.length >= 20;

        if (_hasMorePages) {
          _page += 1;
        }
      }
    } on Exception catch (exception, stackTrace) {
      _exception = exception;
      _stackTrace = stackTrace;
      _items = <T>[];
      _hasMorePages = false;
      _didInitialRequest = true;
      debugPrintStack(stackTrace: stackTrace, label: exception.toString());
    } finally {
      _isDoingRequest = false;
      _changes.add(null);
    }
  }

  void dispose() {
    _changes.close();
    _subscription?.cancel();
  }
}
