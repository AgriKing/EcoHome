// lib/widgets/device_card.dart (continued)
import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  const DeviceCard({
    Key? key,
    required this.device,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getDeviceIcon(),
                  color: device.isOn ? Colors.teal : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${device.watts} Watts • ${device.hoursPerDay} hrs/day',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: device.isOn,
                  onChanged: onToggle,
                  activeColor: Colors.teal,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (device.isOn)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Using ${device.dailyConsumption.toStringAsFixed(2)} kWh/day',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(₹${(device.dailyConsumption * 8).toStringAsFixed(0)}/day)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon() {
    final name = device.name.toLowerCase();
    if (name.contains('ac') || name.contains('air')) return Icons.ac_unit;
    if (name.contains('light')) return Icons.lightbulb;
    if (name.contains('tv')) return Icons.tv;
    if (name.contains('fridge') || name.contains('refrigerator'))
      return Icons.kitchen;
    if (name.contains('wash')) return Icons.local_laundry_service;
    if (name.contains('fan')) return Icons.air;
    if (name.contains('heater')) return Icons.whatshot;
    if (name.contains('computer') || name.contains('pc')) return Icons.computer;
    return Icons.devices_other;
  }
}
