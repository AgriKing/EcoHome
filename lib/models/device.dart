import 'package:hive/hive.dart';

part 'device.g.dart'; // Needed for Hive codegen

@HiveType(typeId: 0)
class Device extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  bool isOn;

  @HiveField(3)
  final int watts;

  @HiveField(4)
  final int hoursPerDay;

  Device({
    required this.id,
    required this.name,
    required this.isOn,
    required this.watts,
    required this.hoursPerDay,
  });

  double get dailyConsumption => watts * hoursPerDay / 1000;

  Device copyWith({
    int? id,
    String? name,
    bool? isOn,
    int? watts,
    int? hoursPerDay,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      isOn: isOn ?? this.isOn,
      watts: watts ?? this.watts,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'isOn': isOn,
    'watts': watts,
    'hoursPerDay': hoursPerDay,
  };

  factory Device.fromMap(Map<String, dynamic> map) => Device(
    id: map['id'],
    name: map['name'],
    isOn: map['isOn'],
    watts: map['watts'],
    hoursPerDay: map['hoursPerDay'],
  );
}
