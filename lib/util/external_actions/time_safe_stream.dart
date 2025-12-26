import 'package:rxdart/rxdart.dart';

const _duration = Duration(seconds: 1);

extension TimeSafeStream<T> on ReplaySubject<Timestamped<T>> {
  void addTimestamped(T value) {
    add(Timestamped(.now(), value));
  }

  /// A time-safe [Stream] of values from this [ReplaySubject].
  ///
  /// This stream will emit all recent values to every subscriber. This deals
  /// with the issue where a value may be emitted before the subscriber is ready
  /// to handle it as well as the issue where a subscriber may receive values
  /// that have already been handled.
  Stream<T> timeSafeStream() => where(
    (item) => DateTime.now().difference(item.timestamp) < _duration,
  ).map((item) => item.value);
}
