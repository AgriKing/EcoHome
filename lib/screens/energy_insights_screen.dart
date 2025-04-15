import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/custom_chart.dart';
import '../models/device.dart'; // Add this import

class EnergyInsightsScreen extends StatefulWidget {
  @override
  _EnergyInsightsScreenState createState() => _EnergyInsightsScreenState();
}

class _EnergyInsightsScreenState extends State<EnergyInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTimeLabel(int index, String period) {
    switch (period) {
      case 'daily':
        final now = DateTime.now();
        final day = now.subtract(Duration(days: 6 - index));
        return '${day.day}/${day.month}';
      case 'weekly':
        return 'Week ${index + 1}';
      case 'monthly':
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
        return months[index];
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Insights'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChartTab('daily'),
          _buildChartTab('weekly'),
          _buildChartTab('monthly'),
        ],
      ),
    );
  }

  Widget _buildChartTab(String period) {
    final data = MockData.energyUsage[period]!;
    final labels = List.generate(data.length, (i) => _getTimeLabel(i, period));

    double average = data.reduce((a, b) => a + b) / data.length;
    double total = data.reduce((a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${period.substring(0, 1).toUpperCase()}${period.substring(1)} Energy Usage',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: CustomChart(
                      data: data,
                      labels: labels,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${total.toStringAsFixed(1)} kWh',
                  Icons.power,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Average',
                  '${average.toStringAsFixed(1)} kWh',
                  Icons.show_chart,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDeviceBreakdown(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceBreakdown() {
    final activeDevices = MockData.initialDevices.where((d) => d.isOn).toList();

    if (activeDevices.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No active devices'),
          ),
        ),
      );
    }

    double totalConsumption = activeDevices.fold(
        0, (total, device) => total + device.dailyConsumption);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...activeDevices.map((device) {
              double percentage =
                  (device.dailyConsumption / totalConsumption) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          '${device.dailyConsumption.toStringAsFixed(1)} kWh',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${percentage.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      color: _getColorForPercentage(percentage / 100),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getColorForPercentage(double value) {
    if (value < 0.3) return Colors.green;
    if (value < 0.7) return Colors.amber;
    return Colors.red;
  }
}
