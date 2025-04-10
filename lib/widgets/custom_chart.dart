// lib/widgets/custom_chart.dart
import 'package:flutter/material.dart';

class CustomChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const CustomChart({
    Key? key,
    required this.data,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxValue = data.reduce((curr, next) => curr > next ? curr : next);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              data.length,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${data[index].toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: (data[index] / maxValue) * 180,
                        decoration: BoxDecoration(
                          color: _getBarColor(data[index], maxValue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            labels.length,
            (index) => Expanded(
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getBarColor(double value, double maxValue) {
    double ratio = value / maxValue;

    if (ratio < 0.5) {
      return Colors.green.shade400;
    } else if (ratio < 0.75) {
      return Colors.amber.shade400;
    } else {
      return Colors.red.shade400;
    }
  }
}
