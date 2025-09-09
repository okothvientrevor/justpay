import 'package:flutter/material.dart';

class LandlordProfileTab extends StatelessWidget {
  const LandlordProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // User Profile Section
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF3FE0F6),
                child: Icon(Icons.person, size: 48, color: Colors.black),
              ),
              const SizedBox(height: 12),
              Text(
                "Farouk Mwanje",
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "farouk@email.com",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "+256 700 000000",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Business Information
        Card(
          color: const Color(0xFF232B3E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Icon(Icons.business, color: Color(0xFF3FE0F6)),
            title: const Text(
              "Business Info",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Manage your organization details",
              style: TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 16),
        // Menu Sections
        _ProfileMenuSection(
          title: "Reports & Documents",
          items: [
            _ProfileMenuItem(
              icon: Icons.bar_chart,
              label: "Financial Reports & Analytics",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.receipt_long,
              label: "Tax Documentation",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.shield,
              label: "Insurance Management",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.folder,
              label: "Legal Documents Library",
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ProfileMenuSection(
          title: "Settings & Preferences",
          items: [
            _ProfileMenuItem(
              icon: Icons.settings,
              label: "App Settings & Notifications",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.support_agent,
              label: "Support & Help Center",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.privacy_tip,
              label: "Privacy & Security",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.dashboard_customize,
              label: "Dashboard Customization",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.file_download,
              label: "Backup & Data Export",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.language,
              label: "Multi-language Support",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.brightness_6,
              label: "Dark/Light Theme",
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ProfileMenuSection(
          title: "Integrations & Team",
          items: [
            _ProfileMenuItem(
              icon: Icons.sync,
              label: "Integration Settings",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.group,
              label: "Team Management",
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<_ProfileMenuItem> items;
  const _ProfileMenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF232B3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF3FE0F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}
