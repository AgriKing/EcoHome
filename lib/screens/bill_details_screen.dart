// lib/screens/bill_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'bill_prediction_screen.dart';

class BillDetailsScreen extends StatefulWidget {
  final PredictedBill bill;
  final ElectricityProvider provider;

  const BillDetailsScreen({
    Key? key,
    required this.bill,
    required this.provider,
  }) : super(key: key);

  @override
  _BillDetailsScreenState createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  bool _showComparison = false;
  final _actualBillController = TextEditingController();
  double? _actualBillAmount;
  String? _differencePercentage;
  Color _differenceColor = Colors.black;

  void _compareWithActualBill() {
    if (_actualBillController.text.isEmpty) return;

    try {
      setState(() {
        _actualBillAmount = double.parse(_actualBillController.text);
        double diff = ((_actualBillAmount! - widget.bill.totalAmount) / widget.bill.totalAmount) * 100;
        _differencePercentage = diff.abs().toStringAsFixed(2);

        if (diff > 0) {
          // Actual bill is higher than predicted
          _differenceColor = Colors.red;
        } else if (diff < 0) {
          // Actual bill is lower than predicted
          _differenceColor = Colors.green;
        } else {
          _differenceColor = Colors.black;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
    }
  }

  @override
  void dispose() {
    _actualBillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    final billDate = dateFormat.format(widget.bill.generatedDate);
    final fromDate = dateFormat.format(
      DateTime.now().subtract(const Duration(days: 30)),
    );
    final toDate = dateFormat.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing functionality will be implemented soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBillHeader(billDate),
            const SizedBox(height: 24),
            _buildConsumerInfo(),
            const SizedBox(height: 24),
            _buildBillingDetails(fromDate, toDate),
            const SizedBox(height: 24),
            _buildChargesBreakdown(),
            const SizedBox(height: 24),
            _buildTotalSection(),
            const SizedBox(height: 32),
            _buildComparisonSection(),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download functionality will be implemented soon')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillHeader(String billDate) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  widget.provider.logo,
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.electric_bolt,
                        color: Colors.amber.shade700,
                        size: 30,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.provider.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Electricity Bill Prediction',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        billDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Bill No.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'PRED-${widget.bill.id.substring(0, 6)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumerInfo() {
    return Card(
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
              'Consumer Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Consumer No.', '12345678901'),
                ),
                Expanded(
                  child: _buildInfoItem('Name', 'John Doe'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Connection Type', 'Residential'),
                ),
                Expanded(
                  child: _buildInfoItem('Sanctioned Load', '5 kW'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Address', '123 Main Street, Mumbai, Maharashtra 400001'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingDetails(String fromDate, String toDate) {
    return Card(
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
              'Billing Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateItem('From', fromDate),
                Container(
                  width: 20,
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                _buildDateItem('To', toDate),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildUsageItem(
                    'Meter Reading',
                    'Previous',
                    '${(widget.bill.totalUnits * 0.7).toInt()}',
                  ),
                ),
                Expanded(
                  child: _buildUsageItem(
                    'Meter Reading',
                    'Current',
                    '${(widget.bill.totalUnits * 1.7).toInt()}',
                  ),
                ),
                Expanded(
                  child: _buildUsageItem(
                    'Units Consumed',
                    'Total',
                    '${widget.bill.totalUnits.toInt()}',
                    isHighlighted: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(String label, String date) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageItem(
      String label,
      String sublabel,
      String value, {
        bool isHighlighted = false,
      }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          sublabel,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: isHighlighted
              ? BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.teal.shade300,
              width: 1,
            ),
          )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.teal : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChargesBreakdown() {
    return Card(
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
              'Charges Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChargeItem(
              'Fixed/Demand Charges',
              '₹${widget.bill.fixedCharge.toStringAsFixed(2)}',
            ),
            _buildChargeItem(
              'Energy Charges (₹${widget.provider.energyCharge}/unit × ${widget.bill.totalUnits.toInt()} units)',
              '₹${widget.bill.energyCharge.toStringAsFixed(2)}',
            ),
            _buildChargeItem(
              'Fuel Adjustment Charge',
              '₹${widget.bill.fuelAdjustmentCharge.toStringAsFixed(2)}',
            ),
            const Divider(),
            _buildChargeItem(
              'GST @ ${(widget.provider.taxRate * 100).toInt()}%',
              '₹${widget.bill.taxAmount.toStringAsFixed(2)}',
            ),
            const Divider(),
            _buildChargeItem(
              'Total Amount',
              '₹${widget.bill.totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeItem(
      String label,
      String amount, {
        bool isTotal = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.teal : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Total Amount Due',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${widget.bill.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is a predicted amount based on your usage',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Compare with Actual Bill',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _showComparison,
                  onChanged: (value) {
                    setState(() {
                      _showComparison = value;
                    });
                  },
                  activeColor: Colors.teal,
                ),
              ],
            ),
            if (_showComparison) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _actualBillController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Enter your actual bill amount',
                  hintText: 'e.g. 2500.50',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.compare_arrows),
                    onPressed: _compareWithActualBill,
                  ),
                ),
              ),
              if (_actualBillAmount != null) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildComparisonItem(
                      'Predicted Bill',
                      '₹${widget.bill.totalAmount.toStringAsFixed(2)}',
                      Icons.analytics,
                      Colors.blue,
                    ),
                    _buildComparisonItem(
                      'Actual Bill',
                      '₹${_actualBillAmount!.toStringAsFixed(2)}',
                      Icons.receipt,
                      Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _differenceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _differenceColor.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Difference: $_differencePercentage%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _differenceColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _actualBillAmount! > widget.bill.totalAmount
                            ? 'Your actual bill is higher than our prediction'
                            : _actualBillAmount! < widget.bill.totalAmount
                            ? 'Your actual bill is lower than our prediction'
                            : 'Our prediction matches your actual bill',
                        style: TextStyle(
                          fontSize: 14,
                          color: _differenceColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}