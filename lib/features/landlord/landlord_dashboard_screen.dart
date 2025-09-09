import 'package:flutter/material.dart';
import 'estates_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'properties_tab.dart';
import 'tenants_tab.dart';

class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() =>
      _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  int _selectedIndex = 0;

  // Dummy data for estates
  final estates = [
    {
      "name": "Farouk Mwanje kavuma",
      "address": "Lisa Sass gata 18",
      "properties": 3,
      "tenants": 4,
      "active": true,
    },
    {
      "name": "Mwanjefarouk's Org",
      "address": "Lisa Sass gata 18",
      "properties": 1,
      "tenants": 1,
      "active": true,
    },
    {
      "name": "Here",
      "address": "Lisa Sass gata 18",
      "properties": 1,
      "tenants": 1,
      "active": true,
    },
    {
      "name": "Farouk Mwanje kavuma",
      "address":
          "Västra Andersgårdsgatan 7A Göteborg, Flat 65, Dunbridge House",
      "properties": 1,
      "tenants": 1,
      "active": true,
      "desc": "hhhhhhhhhhhhhh",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> _pages = const [
      LandlordHomeTab(),
      LandlordEstatesTab(),
      LandlordPropertiesTab(),
      LandlordTenantsTab(),
      LandlordProfileTab(),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF181F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181F2A),
        elevation: 0,
        title: Text(
          _selectedIndex == 0
              ? "Dashboard"
              : _selectedIndex == 1
              ? "My Estates"
              : _selectedIndex == 2
              ? "Properties"
              : _selectedIndex == 3
              ? "Tenants"
              : "Profile",
          style: theme.textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF3FE0F6),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _selectedIndex == 1
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3FE0F6),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text("Create Estate"),
                  ),
                ),
              ]
            : null,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF232B3E),
        selectedItemColor: const Color(0xFF3FE0F6),
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: "Estates",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Properties"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Tenants"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstateCard extends StatelessWidget {
  final Map<String, dynamic> estate;
  const _EstateCard({required this.estate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  estate["name"] ?? "",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DE9B6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (estate["address"] != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF3FE0F6),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  estate["address"],
                  style: const TextStyle(
                    color: Color(0xFF3FE0F6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          if (estate["desc"] != null) ...[
            const SizedBox(height: 4),
            Text(
              estate["desc"],
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.home, color: Colors.white70, size: 18),
              const SizedBox(width: 4),
              Text(
                "${estate["properties"]} Properties",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.people, color: Colors.white70, size: 18),
              const SizedBox(width: 4),
              Text(
                "${estate["tenants"]} Tenants",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              // TODO: Navigate to estate details
            },
            child: Row(
              children: [
                const Icon(
                  Icons.show_chart,
                  color: Color(0xFF3FE0F6),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  "View Details",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF3FE0F6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
