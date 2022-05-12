import 'package:finale/services/generic.dart';
import 'package:finale/util/formatters.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

double _metersToMiles(num meters) =>
    double.parse((meters / 1609.344).toStringAsFixed(2));

int _metersToFeet(num meters) => (meters * 3.2808399).round();

double _mpsToMph(num mps) => mps * 2.23693629;

int? _numToInt(num? value) => value?.toInt();

@JsonSerializable()
class StravaException implements Exception {
  final String message;

  const StravaException(this.message);

  factory StravaException.fromJson(Map<String, dynamic> json) =>
      _$StravaExceptionFromJson(json);

  @override
  String toString() => message;
}

@JsonSerializable()
class AthleteActivity extends Entity {
  final String name;

  @JsonKey(name: 'type')
  final String workoutType;

  @JsonKey(name: 'start_date', fromJson: DateTime.parse)
  final DateTime startDate;

  @JsonKey(name: 'start_date_local', fromJson: DateTime.parse)
  final DateTime startDateLocal;

  /// Elapsed time in seconds.
  @JsonKey(name: 'elapsed_time')
  final int elapsedTime;

  /// Moving time in seconds.
  @JsonKey(name: 'moving_time')
  final int movingTime;

  /// Distance in miles, truncated to two decimal places.
  @JsonKey(fromJson: _metersToMiles)
  final double distance;

  /// Total elevation gain in feet.
  @JsonKey(name: 'total_elevation_gain', fromJson: _metersToFeet)
  final int totalElevationGain;

  /// Average speed in mph.
  @JsonKey(name: 'average_speed', fromJson: _mpsToMph)
  final double averageSpeed;

  /// Average heart rate in bpm.
  @JsonKey(name: 'average_heartrate', fromJson: _numToInt)
  final int? averageHeartRate;

  AthleteActivity({
    required this.name,
    required this.workoutType,
    required this.startDate,
    required this.startDateLocal,
    required this.elapsedTime,
    required this.movingTime,
    required this.distance,
    required this.totalElevationGain,
    required this.averageSpeed,
    required this.averageHeartRate,
  });

  factory AthleteActivity.fromJson(Map<String, dynamic> json) =>
      _$AthleteActivityFromJson(json);

  DateTime get endDate => startDate.add(Duration(seconds: elapsedTime));

  DateTime get endDateLocal =>
      startDateLocal.add(Duration(seconds: elapsedTime));

  String get localTimeRangeFormatted =>
      '${dateTimeFormat.format(startDateLocal)} - '
      '${timeFormat.format(endDateLocal)}';

  @override
  EntityType get type => EntityType.other;

  @override
  String? get url => null;

  @override
  String get displayTitle => name;

  @override
  String? get displaySubtitle => localTimeRangeFormatted;

  IconData get icon {
    switch (workoutType) {
      case 'AlpineSki':
      case 'BackcountrySki':
      case 'NordicSki':
        return Icons.downhill_skiing;
      case 'EBikeRide':
      case 'Elliptical':
      case 'Handcycle':
      case 'Ride':
      case 'VirtualRide':
        return Icons.directions_bike;
      case 'Golf':
        return Icons.golf_course;
      case 'Hike':
      case 'Walk':
        return Icons.directions_walk;
      case 'Kitesurf':
        return Icons.kitesurfing;
      case 'Rowing':
        return Icons.rowing;
      case 'Sailing':
        return Icons.sailing;
      case 'Skateboarding':
        return Icons.skateboarding;
      case 'Snowboard':
        return Icons.snowboarding;
      case 'Snowshoe':
        return Icons.snowshoeing;
      case 'Soccer':
        return Icons.sports_soccer;
      case 'Surfing':
        return Icons.surfing;
      default:
        return Icons.directions_run;
    }
  }
}
