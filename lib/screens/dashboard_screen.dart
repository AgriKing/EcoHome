// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/stat_card.dart';
import 'device_management_screen.dart';
import 'energy_insights_screen.dart';
import 'recommendations_screen.dart';
import 'package:hive/hive.dart';
import '../models/device.dart';
import 'bill_prediction_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_home_system/screens/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Add this for Google sign out

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _refreshData() {
    setState(() {});
  }

  // Handle logout functionality
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Show a confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;

      if (confirm) {
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Also sign out from Google if user signed in with Google
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();

        // Navigate to login screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LogIn()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceBox = Hive.box<Device>('devices');
    final devices = deviceBox.values.toList();
    int activeDevices = devices.where((d) => d.isOn).length;
    double todayCost = MockData.calculateCost(devices);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home Dashboard'),
        elevation: 0,
        actions: [
          // Add logout icon button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Monitor and manage your home energy usage',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.devices,
                      title: '$activeDevices Devices',
                      subtitle: 'Active now',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      icon: Icons.currency_rupee,
                      title: '₹${todayCost.toStringAsFixed(0)}',
                      subtitle: 'Used today',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                'Device Management',
                'Monitor and control your connected devices',
                Icons.devices_other,
                Colors.purple.shade100,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DeviceManagementScreen(onUpdateDevices: _refreshData),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                'Energy Insights',
                'View your energy consumption patterns',
                Icons.insert_chart,
                Colors.blue.shade100,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnergyInsightsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                'Predicted Bill',
                'View your estimated electricity bill',
                Icons.receipt_long,
                Colors.teal.shade100,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillPredictionScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                'Recommendations',
                'Get tips to save energy and money',
                Icons.lightbulb_outline,
                Colors.amber.shade100,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendationsScreen(devices: devices,),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tips_and_updates, color: Colors.amber),
                          const SizedBox(width: 8),
                          const Text(
                            'Tip of the Day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        MockData.energyTips[
                        DateTime.now().day % MockData.energyTips.length],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}