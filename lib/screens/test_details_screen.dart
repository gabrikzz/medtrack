import 'package:flutter/material.dart';
import '../models/test_model.dart';
import 'ai_chat_screen.dart';

class TestDetailsScreen extends StatelessWidget {
  final TestModel test;

  const TestDetailsScreen({super.key, required this.test});

  bool isAbnormal(dynamic value, dynamic min, dynamic max) {
    return value < min || value > max;
  }

  @override
  Widget build(BuildContext context) {
    final results = test.results;

    return Scaffold(
      appBar: AppBar(title: Text(test.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: results.entries.map((entry) {
          final data = entry.value;

          final value = data['value'];
          final min = data['min'];
          final max = data['max'];

          final abnormal = isAbnormal(value, min, max);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: abnormal ? Colors.red.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 6),

                Text("Value: $value"),
                Text("Normal: $min - $max"),

                if (abnormal)
                  const Text(
                    "⚠️ Out of range",
                    style: TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AIChatScreen(
                          initialMessage:
                              "Explain this result: ${entry.key} = $value (normal $min-$max)",
                        ),
                      ),
                    );
                  },
                  child: const Text("Explain this"),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}