import 'package:flutter/material.dart';

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Results"),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TestCard(
              title: "Glucose (Fasting)",
              value: "128 mg/dL",
              status: "High",
              minValue: 70,
              maxValue: 100,
              barColor: Colors.red,
            ),
            const SizedBox(height: 16),
            TestCard(
              title: "HbA1c",
              value: "6.8 %",
              status: "High",
              minValue: 4,
              maxValue: 5.6,
              barColor: Colors.red,
            ),
            const SizedBox(height: 16),
            TestCard(
              title: "Cholesterol (Total)",
              value: "195 mg/dL",
              status: "Normal",
              minValue: 0,
              maxValue: 200,
              barColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class TestCard extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final double minValue;
  final double maxValue;
  final Color barColor;

  const TestCard({
    super.key,
    required this.title,
    required this.value,
    required this.status,
    required this.minValue,
    required this.maxValue,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    double progress = ((double.tryParse(value.split(' ')[0]) ?? minValue) - minValue) / (maxValue - minValue);
    progress = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: barColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: barColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${minValue.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text("${maxValue.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
