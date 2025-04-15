// lib/screens/bill_prediction_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/device.dart';
import '../data/mock_data.dart';
import '../screens/bill_details_screen.dart';

class ElectricityProvider {
  final String id;
  final String name;
  final String logo;
  final double fixedCharge;
  final double energyCharge;
  final double fuelAdjustmentCharge;
  final double taxRate;

  ElectricityProvider({
    required this.id,
    required this.name,
    required this.logo,
    required this.fixedCharge,
    required this.energyCharge,
    required this.fuelAdjustmentCharge,
    required this.taxRate,
  });
}

class PredictedBill {
  final String id;
  final String providerId;
  final double totalUnits;
  final double fixedCharge;
  final double energyCharge;
  final double fuelAdjustmentCharge;
  final double taxAmount;
  final double totalAmount;
  final DateTime generatedDate;

  PredictedBill({
    required this.id,
    required this.providerId,
    required this.totalUnits,
    required this.fixedCharge,
    required this.energyCharge,
    required this.fuelAdjustmentCharge,
    required this.taxAmount,
    required this.totalAmount,
    required this.generatedDate,
  });
}

class BillPredictionScreen extends StatefulWidget {
  @override
  _BillPredictionScreenState createState() => _BillPredictionScreenState();
}

class _BillPredictionScreenState extends State<BillPredictionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ElectricityProvider? selectedProvider;
  final List<ElectricityProvider> providers = [
    ElectricityProvider(
      id: 'msedcl',
      name: 'Maharashtra State Electricity Distribution Co. Ltd (MSEDCL)',
      logo: 'assets/images/msedcl_logo.png',
      fixedCharge: 120.0,
      energyCharge: 7.5,
      fuelAdjustmentCharge: 1.2,
      taxRate: 0.18,
    ),
    ElectricityProvider(
      id: 'adani',
      name: 'Adani Electricity Mumbai Limited (AEML)',
      logo: 'assets/images/adani_logo.png',
      fixedCharge: 150.0,
      energyCharge: 8.2,
      fuelAdjustmentCharge: 1.5,
      taxRate: 0.18,
    ),
    ElectricityProvider(
      id: 'tata',
      name: 'Tata Power',
      logo: 'assets/images/tata_logo.png',
      fixedCharge: 135.0,
      energyCharge: 7.8,
      fuelAdjustmentCharge: 1.3,
      taxRate: 0.18,
    ),
  ];

  // Sample previous bills
  final List<PredictedBill> previousBills = [
    PredictedBill(
      id: '1',
      providerId: 'msedcl',
      totalUnits: 210.0,
      fixedCharge: 120.0,
      energyCharge: 1575.0,
      fuelAdjustmentCharge: 252.0,
      taxAmount: 350.46,
      totalAmount: 2297.46,
      generatedDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
    PredictedBill(
      id: '2',
      providerId: 'adani',
      totalUnits: 195.0,
      fixedCharge: 150.0,
      energyCharge: 1599.0,
      fuelAdjustmentCharge: 292.5,
      taxAmount: 367.47,
      totalAmount: 2408.97,
      generatedDate: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  PredictedBill _generateBill(ElectricityProvider provider) {
    final deviceBox = Hive.box<Device>('devices');
    final devices = deviceBox.values.toList();

    // Calculate total units from devices usage
    double totalUnits = MockData.calculateTotalConsumption(devices);
    double energyCharge = totalUnits * provider.energyCharge;
    double fuelCharge = totalUnits * provider.fuelAdjustmentCharge;
    double subtotal = provider.fixedCharge + energyCharge + fuelCharge;
    double taxAmount = subtotal * provider.taxRate;
    double totalAmount = subtotal + taxAmount;

    return PredictedBill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      providerId: provider.id,
      totalUnits: totalUnits,
      fixedCharge: provider.fixedCharge,
      energyCharge: energyCharge,
      fuelAdjustmentCharge: fuelCharge,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      generatedDate: DateTime.now(),
    );
  }

  void _showBillDetails(BuildContext context, PredictedBill bill) {
    final provider = providers.firstWhere((p) => p.id == bill.providerId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillDetailsScreen(
          bill: bill,
          provider: provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicted Bill'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Generate Bill'),
            Tab(text: 'Previous Bills'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenerateBillTab(),
          _buildPreviousBillsTab(),
        ],
      ),
    );
  }

  Widget _buildGenerateBillTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Your Electricity Provider',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...providers.map((provider) => _buildProviderTile(provider)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (selectedProvider != null)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Bill for ${selectedProvider!.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'This will generate a predicted electricity bill based on your current device usage patterns and the selected provider\'s rates.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final bill = _generateBill(selectedProvider!);
                          _showBillDetails(context, bill);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Generate Predicted Bill',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProviderTile(ElectricityProvider provider) {
    bool isSelected = selectedProvider?.id == provider.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.teal : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            provider.logo,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.electric_bolt,
                color: Colors.amber.shade700,
                size: 30,
              );
            },
          ),
        ),
        title: Text(
          provider.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Fixed Charge: ₹${provider.fixedCharge.toStringAsFixed(2)}'),
            Text('Energy Charge: ₹${provider.energyCharge.toStringAsFixed(2)}/unit'),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.teal)
            : const Icon(Icons.circle_outlined, color: Colors.grey),
        onTap: () {
          setState(() {
            selectedProvider = provider;
          });
        },
        isThreeLine: true,
      ),
    );
  }

  Widget _buildPreviousBillsTab() {
    if (previousBills.isEmpty) {
      return const Center(
        child: Text('No previous bills generated yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: previousBills.length,
      itemBuilder: (context, index) {
        final bill = previousBills[index];
        final provider = providers.firstWhere((p) => p.id == bill.providerId);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () => _showBillDetails(context, bill),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          provider.logo,
                          width: 30,
                          height: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.electric_bolt,
                              color: Colors.teal.shade700,
                              size: 24,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${bill.generatedDate.day}/${bill.generatedDate.month}/${bill.generatedDate.year}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBillInfoItem(
                        'Total Units',
                        '${bill.totalUnits.toStringAsFixed(1)}',
                        Icons.flash_on,
                        Colors.amber,
                      ),
                      _buildBillInfoItem(
                        'Amount',
                        '₹${bill.totalAmount.toStringAsFixed(2)}',
                        Icons.currency_rupee,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          color: Colors.teal.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.teal.shade700,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillInfoItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}