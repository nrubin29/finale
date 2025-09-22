import 'dart:math';

import 'package:collection/collection.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:flutter/foundation.dart';

class _CacheKey {
  final String username;
  final Period period;

  const _CacheKey(this.username, this.period);

  @override
  bool operator ==(Object other) =>
      other is _CacheKey &&
      other.username == username &&
      other.period == period;

  @override
  int get hashCode => Object.hash(username, period);
}

/// A global cache of (username, period) -> tracks.
///
/// This cache can be global because all custom requests are based on tracks.
final _globalCache = <_CacheKey, List<LRecentTracksResponseTrack>>{};

abstract class PeriodPagedRequest<T extends HasPlayCount>
    extends PagedRequest<T> {
  final String username;
  final Period period;

  /// A local cache of post-processed data.
  ///
  /// This is useful for speeding up subsequent page loads as [map], which can
  /// do async work, only needs to be called once per track.
  List<T>? _localCachedData;

  PeriodPagedRequest(this.username, this.period);

  Future<LPagedResponse<T>> doPeriodRequest(
    ApiPeriod period,
    int limit,
    int page,
  );

  String groupBy(LRecentTracksResponseTrack track);

  Future<T> map(MapEntry<String, List<LRecentTracksResponseTrack>> entry);

  /// Populates [_globalCache] and [_localCachedData] for this request, as
  /// needed.
  Future<void> _populateCachedData(Period period) async {
    List<LRecentTracksResponseTrack> response;
    final cacheKey = _CacheKey(username, period);
    final globalCachedData = _globalCache[cacheKey];

    if (globalCachedData != null) {
      response = globalCachedData;
    } else {
      final request = GetRecentTracksRequest.forPeriod(
        username,
        period,
        extended: true,
      );

      response = await request.getAllData();
      _globalCache[cacheKey] = response;
    }

    final groupedData = response.groupListsBy(groupBy);
    // If an entity doesn't have a name, it will be grouped into the empty
    // string group which will mess up the request. The best we can do is
    // filter it out.
    groupedData.remove('');
    _localCachedData = (await Future.wait(
      groupedData.entries.map(map),
    )).sorted((a, b) => b.playCount.compareTo(a.playCount));
  }

  @override
  @nonVirtual
  doRequest(int limit, int page) async {
    if (period case ApiPeriod period) {
      return (await doPeriodRequest(period, limit, page)).items;
    }

    // If page 1 is being requested, either it's the first request and
    // [_cachedData] is already null or we probably want fresh data.
    if (page == 1) {
      _localCachedData = null;
    }

    if (_localCachedData == null) {
      await _populateCachedData(period);
    }

    return _localCachedData!.slice(
      limit * (page - 1),
      min(limit * page, _localCachedData!.length),
    );
  }

  @nonVirtual
  Future<int> getNumItems() async {
    if (period case ApiPeriod period) {
      return (await doPeriodRequest(period, 1, 1)).attr.total;
    }

    return _localCachedData?.length ?? (await getAllData()).length;
  }

  @override
  String toString() => '$runtimeType(user=$username, period=$period)';
}
