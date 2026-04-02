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
            // header cu animatie fade in
            const SizedBox(height: 20),
            Center(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, double opacity, child) {
                  return Opacity(opacity: opacity, child: child);
                },
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE8EAF6), Color(0xFFE3F2FD)],
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.person_outline, size: 48, color: Color(0xFF5C6BC0)),
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
            ),

            const SizedBox(height: 48),

            // animatie slide pentru fiecare rand
            _AnimatedRow(
              delay: 0,
              child: _InfoRow(
                icon: Icons.numbers_outlined,
                label: "idnp",
                value: "2900315843217",
                iconColor: const Color(0xFF5C6BC0),
              ),
            ),
            const SizedBox(height: 20),
            _AnimatedRow(
              delay: 100,
              child: _InfoRow(
                icon: Icons.credit_card_outlined,
                label: "insurance",
                value: "INS-2024-78432",
                iconColor: const Color(0xFF42A5F5),
              ),
            ),

            const SizedBox(height: 40),

            // sectiune medicala cu animatie
            _AnimatedRow(
              delay: 200,
              child: Text(
                "medical",
                style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500, letterSpacing: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            _AnimatedRow(
              delay: 250,
              child: _InfoRow(
                icon: Icons.bloodtype_outlined,
                label: "blood type",
                value: "A+",
                iconColor: const Color(0xFFEF5350),
              ),
            ),
            const SizedBox(height: 20),
            
            // allergies
            _AnimatedRow(
              delay: 300,
              child: _SectionLabel(label: "allergies"),
            ),
            const SizedBox(height: 12),
            _AnimatedRow(
              delay: 350,
              child: Wrap(
                spacing: 10,
                children: const [
                  _MinimalChip(text: "penicillin", chipColor: Color(0xFFFFF3E0), textColor: Color(0xFFE65100)),
                  _MinimalChip(text: "peanuts", chipColor: Color(0xFFFFEBEE), textColor: Color(0xFFC62828)),
                ],
              ),
            ),

            const SizedBox(height: 28),
            
            // conditions
            _AnimatedRow(
              delay: 400,
              child: _SectionLabel(label: "conditions"),
            ),
            const SizedBox(height: 12),
            _AnimatedRow(
              delay: 450,
              child: Column(
                children: const [
                  _ConditionItem(text: "type 2 diabetes • 2021", dotColor: Color(0xFFEF5350)),
                  SizedBox(height: 10),
                  _ConditionItem(text: "hypertension • 2023", dotColor: Color(0xFF42A5F5)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // emergency contact cu efect de hover
            _AnimatedRow(
              delay: 500,
              child: Text(
                "emergency",
                style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500, letterSpacing: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            _AnimatedRow(
              delay: 550,
              child: _EmergencyContactCard(),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// animatie la scroll
class _AnimatedRow extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedRow({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = const Color(0xFF9E9E9E),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
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
  final Color chipColor;
  final Color textColor;

  const _MinimalChip({
    required this.text,
    this.chipColor = const Color(0xFFF5F5F5),
    this.textColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textColor),
      ),
    );
  }
}

class _ConditionItem extends StatelessWidget {
  final String text;
  final Color dotColor;

  const _ConditionItem({required this.text, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      ],
    );
  }
}

class _EmergencyContactCard extends StatefulWidget {
  const _EmergencyContactCard();

  @override
  State<_EmergencyContactCard> createState() => _EmergencyContactCardState();
}

class _EmergencyContactCardState extends State<_EmergencyContactCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _isHovered ? const Color(0xFF5C6BC0) : Colors.grey[200]!,
              width: _isHovered ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, size: 22, color: _isHovered ? const Color(0xFF5C6BC0) : Colors.grey[500]),
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
            Icon(Icons.phone_outlined, size: 20, color: _isHovered ? const Color(0xFF5C6BC0) : Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
