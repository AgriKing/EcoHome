import 'package:hive/hive.dart';
import '../models/device.dart';

class MockData {
  static final List<Device> initialDevices = [
    Device(id: 1, name: "AC", isOn: true, watts: 1500, hoursPerDay: 4),
    Device(id: 2, name: "LED Lights", isOn: true, watts: 20, hoursPerDay: 6),
    Device(id: 3, name: "Refrigerator", isOn: true, watts: 200, hoursPerDay: 24),
    Device(id: 4, name: "TV", isOn: false, watts: 120, hoursPerDay: 2),
    Device(id: 5, name: "Washing Machine", isOn: false, watts: 500, hoursPerDay: 1),
  ];

  static List<String> energyTips = [
    "Use AC at 24°C to save 10% energy",
    "Turn off lights in unused rooms",
    "Avoid peak-hour appliance usage (6-10 PM)",
    "Use natural light during daytime",
    "Run full loads in washing machine",
    "Unplug devices when not in use to avoid phantom loads",
    "Replace old appliances with energy-efficient models",
    "Use smart power strips for electronics",
    "Install ceiling fans to reduce AC usage",
    "Regularly clean AC filters for optimal efficiency",
  ];

  static Map<String, List<double>> energyUsage = {
    'daily': [2.5, 3.2, 2.8, 4.5, 3.7, 2.9, 3.3],
    'weekly': [18.5, 22.3, 19.8, 24.5, 21.7, 20.4, 23.8],
    'monthly': [85.5, 92.3, 78.8, 88.5, 94.7, 89.4, 82.3],
  };

  static Future<void> loadInitialMockData() async {
    final deviceBox = Hive.box<Device>('devices');
    if (deviceBox.isEmpty) {
      for (final device in initialDevices) {
        await deviceBox.put(device.id, device);
      }
    }
  }

  static double calculateTotalConsumption(List devices) {
    return devices
        .where((device) => device.isOn)
        .fold(0, (total, device) => total + device.dailyConsumption);
  }

  static double calculateCost(List<Device> devices) {
    // Assuming ₹8 per kWh
    return calculateTotalConsumption(devices) * 8;
  }

  static int getNextDeviceId(List<Device> devices) {
    if (devices.isEmpty) return 1;
    return devices.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
