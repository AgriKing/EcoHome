import 'package:hive/hive.dart';
import '../models/device.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  late Box<Device> _deviceBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen('devices')) {
      _deviceBox = await Hive.openBox<Device>('devices');
    } else {
      _deviceBox = Hive.box<Device>('devices');
    }
  }

  Future<void> addDevice(Device device) async {
    await _deviceBox.put(device.id, device);
  }

  List<Device> getDevices() {
    return _deviceBox.values.toList();
  }

  Future<void> deleteDevice(int id) async {
    await _deviceBox.delete(id);
  }

  Future<void> updateDevice(Device updatedDevice) async {
    await _deviceBox.put(updatedDevice.id, updatedDevice);
  }

  Future<void> toggleDeviceState(int id, bool isOn) async {
    Device? device = _deviceBox.get(id);
    if (device != null) {
      Device updatedDevice = device.copyWith(isOn: isOn);
      await _deviceBox.put(id, updatedDevice);
    }
  }
}