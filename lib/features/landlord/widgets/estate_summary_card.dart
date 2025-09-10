import 'package:flutter/material.dart';

class EstateSummaryCards extends StatelessWidget {
  final List<int> counts;

  const EstateSummaryCards({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: SummaryCard(
                icon: Icons.apartment,
                label: "Estates",
                value: "${counts[0]}",
                color: const Color(0xFF3B5AFE),
                labelAbove: true,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: SummaryCard(
                icon: Icons.home,
                label: "Properties",
                value: "${counts[1]}",
                color: const Color(0xFF00C853),
                labelAbove: true,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: SummaryCard(
                icon: Icons.people,
                label: "Tenants",
                value: "${counts[2]}",
                color: const Color(0xFF8E24AA),
                labelAbove: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool labelAbove;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.labelAbove = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(12),
      child: labelAbove
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 18,
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
