import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:justpay/features/landlord/app_settings_page.dart';
import 'package:justpay/features/landlord/integration_settings_page.dart';
import 'package:justpay/features/landlord/support_page.dart';
import 'package:justpay/features/landlord/team_management_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandlordProfileTab extends StatefulWidget {
  final String email;
  const LandlordProfileTab({super.key, required this.email});

  @override
  State<LandlordProfileTab> createState() => _LandlordProfileTabState();
}

class _LandlordProfileTabState extends State<LandlordProfileTab> {
  String name = "Landlord";
  String phone = "";
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initLocalProfile();
  }

  Future<void> _initLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final localName = prefs.getString('landlord_name');
    final localPhone = prefs.getString('landlord_phone');
    setState(() {
      name = localName ?? name;
      phone = localPhone ?? phone;
      _initialized = true;
    });
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Replace 'userId' with actual user id
    final doc = await FirebaseFirestore.instance
        .collection('landlords')
        .doc('userId')
        .get();
    if (doc.exists) {
      setState(() {
        name = doc.data()?['name'] ?? "Landlord";
        phone = doc.data()?['phone'] ?? "";
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('landlord_name', name);
      await prefs.setString('landlord_phone', phone);
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3FE0F6),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('landlords')
                            .doc('userId')
                            .set({
                              'name': nameController.text,
                              'phone': phoneController.text,
                            }, SetOptions(merge: true));
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          'landlord_name',
                          nameController.text,
                        );
                        await prefs.setString(
                          'landlord_phone',
                          phoneController.text,
                        );
                        setState(() {
                          name = nameController.text;
                          phone = phoneController.text;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
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
                      name.isNotEmpty ? name : "Landlord",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    // Text(
                    //   widget.email,
                    //   style: theme.textTheme.bodyMedium?.copyWith(
                    //     color: Colors.white70,
                    //   ),
                    // ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3FE0F6),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _showEditProfileDialog(context),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Essential Menu Sections
              _ProfileMenuSection(
                title: "Settings & Support",
                items: [
                  _ProfileMenuItem(
                    icon: Icons.settings,
                    label: "App Settings & Notifications",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AppSettingsPage(),
                      ),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.support_agent,
                    label: "Support & Help Center",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SupportPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileMenuSection(
                title: "Team & Integrations",
                items: [
                  _ProfileMenuItem(
                    icon: Icons.group,
                    label: "Team Management",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TeamManagementPage(),
                      ),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.sync,
                    label: "Integration Settings",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const IntegrationSettingsPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                // TODO: Navigate to login screen
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text(
                "Log Out",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
