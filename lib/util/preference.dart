import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

typedef _StringList = List<String>;

/// A preference stored in [SharedPreferences].
///
/// [T] is the type of the value and [U] is the type stored in shared
/// preferences (the underlying type). [U] must be non-nullable since null
/// values aren't stored in shared preferences.
class Preference<T, U extends Object> {
  static late final SharedPreferences _preferences;

  static Future<void> setup() async {
    _preferences = await SharedPreferences.getInstance();
  }

  final String _key;
  final T _defaultValue;
  final U? Function(T value)? serialize;
  final T Function(U serialized)? deserialize;

  late final _changes = StreamController<T>.broadcast();

  Preference(this._key, {T? defaultValue, this.serialize, this.deserialize})
      : assert(null is T || defaultValue != null),
        assert((serialize != null) == (deserialize != null)),
        _defaultValue = null is T ? defaultValue as T : defaultValue!;

  static Preference<DateTime?, int> dateTime(String key) =>
      Preference<DateTime?, int>(
        key,
        serialize: (value) => value?.millisecondsSinceEpoch,
        deserialize: DateTime.fromMillisecondsSinceEpoch,
      );

  static Preference<T, int> forEnum<T extends Enum>(
          String key, List<T> enumValues,
          {required T defaultValue}) =>
      Preference<T, int>(
        key,
        defaultValue: defaultValue,
        serialize: (value) => value.index,
        deserialize: (serialized) => serialized < enumValues.length
            ? enumValues[serialized]
            : enumValues.first,
      );

  Stream<T> get changes => _changes.stream;

  T get value {
    if (!_preferences.containsKey(_key)) {
      return _defaultValue;
    }

    final preferenceValue = U == _StringList
        ? _preferences.getStringList(_key) as U
        : _preferences.get(_key) as U;

    if (deserialize != null) {
      return deserialize!(preferenceValue);
    }

    return preferenceValue as T;
  }

  set value(T newValue) {
    final value = serialize != null ? serialize!(newValue) : newValue;

    if (value == null) {
      clear();
    } else if (value is String) {
      _preferences.setString(_key, value);
    } else if (value is bool) {
      _preferences.setBool(_key, value);
    } else if (value is int) {
      _preferences.setInt(_key, value);
    } else if (value is double) {
      _preferences.setDouble(_key, value);
    } else if (value is List<String>) {
      _preferences.setStringList(_key, value);
    } else {
      throw ArgumentError.value(newValue, null,
          "Can't handle type $T. Provide a serialize function.");
    }

    _changes.add(newValue);
  }

  bool get hasValue => _preferences.containsKey(_key);

  void clear() {
    _preferences.remove(_key);
    _changes.add(_defaultValue);
  }
}
