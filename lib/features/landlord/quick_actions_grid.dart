import 'package:flutter/material.dart';
import 'create_invoice_page.dart';
import 'add_payment_page.dart';
import 'maintenance_page.dart';

class QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: "Quick Actions", icon: Icons.flash_on),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            QuickActionCard(
              icon: Icons.receipt_long_outlined,
              title: "Create Invoice",
              subtitle: "Generate invoices",
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateInvoicePage(),
                ),
              ),
            ),
            QuickActionCard(
              icon: Icons.add_circle_outline,
              title: "Add Payment",
              subtitle: "Record payments",
              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPaymentPage()),
              ),
            ),
            QuickActionCard(
              icon: Icons.build_outlined,
              title: "Maintenance",
              subtitle: "Manage tasks",
              colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenancePage(),
                ),
              ),
            ),
            QuickActionCard(
              icon: Icons.analytics_outlined,
              title: "Reports",
              subtitle: "View analytics",
              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  const QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: colors.first, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({required this.title, required this.icon, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3FE0F6), Color(0xFF1E88E5)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
