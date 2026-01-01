import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final int value;
  final bool danger;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: danger ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: danger ? Border.all(color: Colors.red) : null,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: danger ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
