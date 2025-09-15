import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void _navigateToCreateEstate() async {
    final created = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateEstatePage()));
    if (created == true) {
      setState(() {}); // Refresh Estates tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> _pages = const [
      LandlordHomeTab(),
      LandlordEstatesTab(),
      LandlordPropertiesTab(),
      LandlordTenantsTab(),
      LandlordProfileTab(email: ''),
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
                    onPressed: _navigateToCreateEstate,
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

class CreateEstatePage extends StatefulWidget {
  const CreateEstatePage({Key? key}) : super(key: key);

  @override
  State<CreateEstatePage> createState() => _CreateEstatePageState();
}

class _CreateEstatePageState extends State<CreateEstatePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String description = '';

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181F2A),
        elevation: 0,
        title: const Text(
          "Create New Estate",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Fill in the details below to create a new estate for managing properties and tenants.",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Estate Name *",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF232B3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Enter estate name",
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onChanged: (v) => setState(() => name = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Address",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF232B3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Enter estate address",
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => address = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF232B3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Enter estate description (optional)",
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => description = v),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF232B3E)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3FE0F6),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _loading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _loading = true);
                                final newEstate = {
                                  "name": name,
                                  "address": address,
                                  "desc": description,
                                  "properties": 0,
                                  "tenants": 0,
                                  "active": true,
                                };
                                await FirebaseFirestore.instance
                                    .collection('estates')
                                    .add(newEstate);
                                setState(() => _loading = false);
                                Navigator.of(context).pop(true);
                              }
                            },
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Create Estate"),
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
