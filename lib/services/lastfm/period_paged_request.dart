import 'dart:math';

import 'package:collection/collection.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/period.dart';
import 'package:finale/util/preferences.dart';
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

final _cache = <_CacheKey, List<LRecentTracksResponseTrack>>{};

abstract class PeriodPagedRequest<T extends HasPlayCount>
    extends PagedRequest<T> {
  final String username;
  final Period? period;

  PeriodPagedRequest(this.username, this.period);

  Future<List<T>> doPeriodRequest(Period period, int limit, int page);

  String groupBy(LRecentTracksResponseTrack track);

  Future<T> map(MapEntry<String, List<LRecentTracksResponseTrack>> entry);

  @override
  @nonVirtual
  doRequest(int limit, int page) async {
    final period = this.period ?? Preferences().period;

    if (period.isCustom) {
      List<LRecentTracksResponseTrack> response;
      final cacheKey = _CacheKey(username, period);
      final cachedData = _cache[cacheKey];

      if (cachedData != null) {
        response = cachedData;
      } else {
        final request = GetRecentTracksRequest(username,
            from: period.start, to: period.end, extended: true);

        response = await request.getAllData();
        _cache[cacheKey] = response;
      }

      final groupedData = response.groupListsBy(groupBy);
      final data = (await Future.wait(groupedData.entries.map(map)))
          .sorted((a, b) => b.playCount.compareTo(a.playCount));

      return data.slice(limit * (page - 1), min(limit * page, data.length));
    }

    return doPeriodRequest(period, limit, page);
  }
}
