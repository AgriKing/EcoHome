// lib/screens/device_management_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/device.dart';
import '../widgets/device_card.dart';

class DeviceManagementScreen extends StatefulWidget {
  final VoidCallback onUpdateDevices;

  const DeviceManagementScreen({Key? key, required this.onUpdateDevices})
      : super(key: key);

  @override
  _DeviceManagementScreenState createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  late List<Device> devices;

  @override
  void initState() {
    super.initState();
    devices = MockData.devices;
  }

  void _toggleDevice(int index, bool value) {
    setState(() {
      devices[index].isOn = value;
      widget.onUpdateDevices();
    });
  }

  void _removeDevice(int index) {
    setState(() {
      MockData.devices.removeAt(index);
      devices = MockData.devices;
      widget.onUpdateDevices();
    });
  }

  void _showAddDeviceDialog() {
    final nameController = TextEditingController();
    final wattsController = TextEditingController();
    final hoursController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Device'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Device Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter device name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: wattsController,
                  decoration: const InputDecoration(
                    labelText: 'Power (Watts)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter power consumption';
                    }
                    try {
                      int watts = int.parse(value);
                      if (watts <= 0) return 'Power must be positive';
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: hoursController,
                  decoration: const InputDecoration(
                    labelText: 'Usage (Hours/Day)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter hours per day';
                    }
                    try {
                      int hours = int.parse(value);
                      if (hours <= 0 || hours > 24) {
                        return 'Hours must be between 1-24';
                      }
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  MockData.devices.add(Device(
                    id: MockData.getNextDeviceId(),
                    name: nameController.text.trim(),
                    isOn: false,
                    watts: int.parse(wattsController.text),
                    hoursPerDay: int.parse(hoursController.text),
                  ));
                  devices = MockData.devices;
                  widget.onUpdateDevices();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
      ),
      body: devices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.devices_other,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No devices added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddDeviceDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Device'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return DeviceCard(
                  device: devices[index],
                  onToggle: (value) => _toggleDevice(index, value),
                  onDelete: () => _removeDevice(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
