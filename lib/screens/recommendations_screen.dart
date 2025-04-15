// lib/screens/recommendations_screen.dart
import 'package:flutter/material.dart';
import '../models/device.dart';
import '../utils/api_service.dart';
import '../data/mock_data.dart'; // Keep for fallback data

class RecommendationsScreen extends StatefulWidget {
  final List<Device> devices;

  const RecommendationsScreen({Key? key, required this.devices}) : super(key: key);

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<Map<String, String>> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    try {
      final result = await ApiService.getRecommendations(widget.devices);
      setState(() {
        recommendations = result;
        isLoading = false;
      });
    } catch (e) {
      // Fallback to mock data if API fails
      setState(() {
        recommendations = MockData.energyTips.map((tip) => {
          'device': 'General',
          'tip': tip,
        }).toList();
        isLoading = false;
      });
      print('Error fetching recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Saving Tips'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recommendations.isEmpty
          ? const Center(child: Text('No recommendations at the moment.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final item = recommendations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['device'] ?? 'General',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['tip'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}