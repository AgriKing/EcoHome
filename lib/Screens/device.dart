import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Device {
  String name;
  double consumptionPerHour;
  bool isOn;
  String image;

  Device({
    required this.name,
    required this.consumptionPerHour,
    required this.isOn,
    required this.image,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'consumptionPerHour': consumptionPerHour,
    'isOn': isOn,
    'image': image,
  };

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    name: json['name'],
    consumptionPerHour: (json['consumptionPerHour'] as num).toDouble(),
    isOn: json['isOn'] ?? false,
    image: json['image'],
  );
}

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key}) : super(key: key);

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid;
  }

  Future<void> _toggleDevice(String docId, bool currentStatus) async {
    if (userId == null) return;
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Devices')
        .doc(docId)
        .update({'isOn': !currentStatus});
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Devices')),
        body: const Center(child: Text("Please log in to view your devices.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Users')
            .doc(userId)
            .collection('Devices')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No devices added."));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final device = Device.fromJson(data);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 3,
                child: ListTile(
                  leading: Image.asset(device.image, width: 50, height: 50),
                  title: Text(
                    device.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Consumption: ${device.consumptionPerHour.toStringAsFixed(2)} W"),
                  trailing: Switch(
                    value: device.isOn,
                    onChanged: (value) => _toggleDevice(doc.id, device.isOn),
                    activeColor: Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
