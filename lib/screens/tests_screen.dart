import 'package:flutter/material.dart';

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("lab results", style: TextStyle(fontWeight: FontWeight.w300)),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "last 3 months",
              style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w300, letterSpacing: 0.5),
            ),
            const SizedBox(height: 24),
            TestCard(
              title: "glucose",
              subtitle: "morning, before coffee",
              value: "128",
              unit: "mg/dL",
              status: "too high",
              minValue: 70,
              maxValue: 100,
              barColor: Colors.red,
              note: "you had sweets yesterday",
            ),
            const SizedBox(height: 16),
            TestCard(
              title: "hemoglobin",
              subtitle: "3-month average",
              value: "6.8",
              unit: "%",
              status: "elevated",
              minValue: 4,
              maxValue: 5.6,
              barColor: Colors.orange,
              note: "slowly improving 🍃",
            ),
            const SizedBox(height: 16),
            TestCard(
              title: "cholesterol",
              subtitle: "total",
              value: "195",
              unit: "mg/dL",
              status: "good",
              minValue: 0,
              maxValue: 200,
              barColor: Colors.green,
              note: "keep it up",
            ),
            const SizedBox(height: 16),
            TestCard(
              title: "vitamin D",
              subtitle: "sunshine on a plate",
              value: "32",
              unit: "ng/mL",
              status: "low",
              minValue: 30,
              maxValue: 100,
              barColor: Colors.amber,
              note: "20min outside daily",
            ),
          ],
        ),
      ),
    );
  }
}

class TestCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String unit;
  final String status;
  final double minValue;
  final double maxValue;
  final Color barColor;
  final String note;

  const TestCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
    required this.status,
    required this.minValue,
    required this.maxValue,
    required this.barColor,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    double numericValue = double.tryParse(value) ?? minValue;
    double progress = (numericValue - minValue) / (maxValue - minValue);
    progress = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: -0.3)),
              const SizedBox(width: 6),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w300)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, letterSpacing: -1)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: barColor, fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: Colors.grey[200],
              color: barColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${minValue.toStringAsFixed(0)}", style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              Text("${maxValue.toStringAsFixed(0)}", style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 12),
          Text(note, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
