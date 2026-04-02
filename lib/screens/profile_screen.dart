import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "profile",
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
        ),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header - minimalist
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: const CircleAvatar(
                      radius: 48,
                      backgroundColor: Color(0xFFF5F5F5),
                      child: Icon(Icons.person_outline, size: 48, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "maria popescu",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "born 15.03.1990",
                    style: TextStyle(fontSize: 13, color: Colors.grey[400], fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // id & insurance - clean rows
            _InfoRow(
              icon: Icons.numbers_outlined,
              label: "idnp",
              value: "2900315843217",
            ),
            const SizedBox(height: 20),
            _InfoRow(
              icon: Icons.credit_card_outlined,
              label: "insurance",
              value: "INS-2024-78432",
            ),

            const SizedBox(height: 40),

            // medical section
            Text(
              "medical",
              style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500, letterSpacing: 0.8),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.bloodtype_outlined,
              label: "blood type",
              value: "A+",
            ),
            const SizedBox(height: 20),
            
            // allergies
            _SectionLabel(label: "allergies"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: const [
                _MinimalChip(text: "penicillin"),
                _MinimalChip(text: "peanuts"),
              ],
            ),

            const SizedBox(height: 28),
            
            // conditions
            _SectionLabel(label: "conditions"),
            const SizedBox(height: 12),
            const _ConditionItem(text: "type 2 diabetes • 2021"),
            const SizedBox(height: 10),
            const _ConditionItem(text: "hypertension • 2023"),

            const SizedBox(height: 40),

            // emergency contact
            Text(
              "emergency",
              style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500, letterSpacing: 0.8),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 22, color: Colors.grey[500]),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("ion popescu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                        SizedBox(height: 4),
                        Text("father", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Icon(Icons.phone_outlined, size: 20, color: Colors.grey[500]),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }
}

class _MinimalChip extends StatelessWidget {
  final String text;

  const _MinimalChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class _ConditionItem extends StatelessWidget {
  final String text;

  const _ConditionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 3, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26)),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      ],
    );
  }
}
