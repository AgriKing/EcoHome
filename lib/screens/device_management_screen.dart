import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  late Box<Device> deviceBox;

  @override
  void initState() {
    super.initState();
    deviceBox = Hive.box<Device>('devices');
  }

  void _toggleDevice(int index, bool value) {
    final device = deviceBox.getAt(index);
    if (device != null) {
      device.isOn = value;
      device.save(); // Save the change
      widget.onUpdateDevices();
      setState(() {});
    }
  }

  void _removeDevice(int index) {
    deviceBox.deleteAt(index);
    widget.onUpdateDevices();
    setState(() {});
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
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter device name' : null,
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
                      return 'Enter power';
                    }
                    final watts = int.tryParse(value);
                    return (watts == null || watts <= 0)
                        ? 'Invalid power value'
                        : null;
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
                    final hours = int.tryParse(value ?? '');
                    if (hours == null || hours <= 0 || hours > 24) {
                      return 'Usage must be 1–24';
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
                final newDevice = Device(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text.trim(),
                  isOn: false,
                  watts: int.parse(wattsController.text),
                  hoursPerDay: int.parse(hoursController.text),
                );
                deviceBox.add(newDevice);
                widget.onUpdateDevices();
                Navigator.pop(context);
                setState(() {});
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
    final devices = deviceBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Device Management')),
      body: devices.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.devices_other, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No devices added yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
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
