import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Device {
  String name;
  double consumptionPerHour;
  String image;

  Device({required this.name, required this.consumptionPerHour, required this.image});

  Map<String, dynamic> toJson() => {
    'name': name,
    'consumptionPerHour': consumptionPerHour,
    'image': image,
  };

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    name: json['name'],
    consumptionPerHour: (json['consumptionPerHour'] as num).toDouble(),
    image: json['image'],
  );
}

class ManageHomePage extends StatefulWidget {
  const ManageHomePage({Key? key}) : super(key: key);

  @override
  _ManageHomePageState createState() => _ManageHomePageState();
}

class _ManageHomePageState extends State<ManageHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;

  final List<Device> predefinedDevices = [
    Device(name: "Fan", consumptionPerHour: 75, image: "assets/images/placeholder.png"),
    Device(name: "Light Bulb", consumptionPerHour: 10, image: "assets/light_bulb.png"),
    Device(name: "Refrigerator", consumptionPerHour: 150, image: "assets/refrigerator.png"),
    Device(name: "Air Conditioner", consumptionPerHour: 2000, image: "assets/ac.png"),
    Device(name: "Heater", consumptionPerHour: 1500, image: "assets/heater.png"),
    Device(name: "Microwave", consumptionPerHour: 1200, image: "assets/microwave.png"),
    Device(name: "Washing Machine", consumptionPerHour: 500, image: "assets/washing_machine.png"),
    Device(name: "Dishwasher", consumptionPerHour: 1800, image: "assets/dishwasher.png"),
    Device(name: "Television", consumptionPerHour: 100, image: "assets/tv.png"),
    Device(name: "Computer", consumptionPerHour: 250, image: "assets/computer.png"),
    Device(name: "Iron", consumptionPerHour: 1000, image: "assets/iron.png"),
    Device(name: "Toaster", consumptionPerHour: 800, image: "assets/toaster.png"),
    Device(name: "Oven", consumptionPerHour: 2200, image: "assets/oven.png"),
    Device(name: "Water Pump", consumptionPerHour: 750, image: "assets/water_pump.png"),
    Device(name: "Vacuum Cleaner", consumptionPerHour: 600, image: "assets/vacuum.png"),
    Device(name: "Coffee Maker", consumptionPerHour: 900, image: "assets/coffee_maker.png"),
    Device(name: "Hair Dryer", consumptionPerHour: 1500, image: "assets/hair_dryer.png"),
    Device(name: "Mixer Grinder", consumptionPerHour: 500, image: "assets/mixer.png"),
    Device(name: "Charger", consumptionPerHour: 15, image: "assets/charger.png"),
    Device(name: "Router", consumptionPerHour: 20, image: "assets/router.png"),
  ];

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid;
  }

  Future<void> _addDevice(Device device) async {
    if (userId == null) return;

    TextEditingController nameController = TextEditingController(text: device.name);
    TextEditingController consumptionController = TextEditingController(text: device.consumptionPerHour.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Customize Device"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Device Name")),
              TextField(
                controller: consumptionController,
                decoration: const InputDecoration(labelText: "Consumption (W)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                double? consumption = double.tryParse(consumptionController.text);
                if (consumption == null) return;

                await _firestore.collection('Users').doc(userId).collection('Devices').add({
                  'name': nameController.text,
                  'consumptionPerHour': consumption,
                  'image': device.image,
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeDevice(String docId) async {
    if (userId == null) return;
    await _firestore.collection('Users').doc(userId).collection('Devices').doc(docId).delete();
  }

  void _showDeviceSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Device"),
          content: SingleChildScrollView(
            child: Column(
              children: predefinedDevices.map((device) {
                return ListTile(
                  // leading: Image.asset(device.image, width: 40, height: 40), // Added device image
                  title: Text(device.name),
                  subtitle: Text("Consumption: ${device.consumptionPerHour} W"),
                  onTap: () {
                    Navigator.pop(context);
                    _addDevice(device);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Devices")),
      body: userId == null
          ? const Center(child: Text("Please log in to manage devices"))
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Users').doc(userId).collection('Devices').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No devices added."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final device = Device.fromJson(data);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Image.asset(device.image, width: 40, height: 40),
                  title: Text(device.name),
                  subtitle: Text("Consumption: ${device.consumptionPerHour} W"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeDevice(doc.id),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDeviceSelectionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}