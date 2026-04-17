import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AIChatScreen extends StatefulWidget {
  final String initialMessage;

  const AIChatScreen({super.key, required this.initialMessage});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final AIService _ai = AIService();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    sendMessage(widget.initialMessage);
  }

  Future<void> sendMessage(String text) async {
    setState(() {
      messages.add({"role": "user", "text": text});
    });

    final reply = await _ai.askAI(text);

    setState(() {
      messages.add({"role": "ai", "text": reply});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Doctor")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages.map((msg) {
                return ListTile(
                  title: Text(msg["text"]!),
                  tileColor: msg["role"] == "user"
                      ? Colors.blue.shade50
                      : Colors.green.shade50,
                );
              }).toList(),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(controller: _controller),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  sendMessage(_controller.text);
                  _controller.clear();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}