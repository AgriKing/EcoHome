// lib/models/device.dart
class Device {
  final int id;
  final String name;
  bool isOn;
  final int watts;
  final int hoursPerDay;

  Device({
    required this.id,
    required this.name,
    required this.isOn,
    required this.watts,
    required this.hoursPerDay,
  });

  double get dailyConsumption => watts * hoursPerDay / 1000; // in kWh

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isOn': isOn,
      'watts': watts,
      'hoursPerDay': hoursPerDay,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'],
      name: map['name'],
      isOn: map['isOn'],
      watts: map['watts'],
      hoursPerDay: map['hoursPerDay'],
    );
  }
}
