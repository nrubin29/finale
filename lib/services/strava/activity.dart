import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class AthleteActivity {
  final String name;
  final String type;

  @JsonKey(name: 'start_date', fromJson: DateTime.parse)
  final DateTime startDate;

  @JsonKey(name: 'start_date_local', fromJson: DateTime.parse)
  final DateTime startDateLocal;

  @JsonKey(name: 'elapsed_time')
  final int elapsedTime;

  const AthleteActivity({
    required this.name,
    required this.type,
    required this.startDate,
    required this.startDateLocal,
    required this.elapsedTime,
  });

  factory AthleteActivity.fromJson(Map<String, dynamic> json) =>
      _$AthleteActivityFromJson(json);

  DateTime get endDate => startDate.add(Duration(seconds: elapsedTime));

  DateTime get endDateLocal =>
      startDateLocal.add(Duration(seconds: elapsedTime));
}
