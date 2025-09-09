import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LandlordEstatesTab extends StatefulWidget {
  const LandlordEstatesTab({super.key});

  @override
  State<LandlordEstatesTab> createState() => _LandlordEstatesTabState();
}

class _LandlordEstatesTabState extends State<LandlordEstatesTab> {
  final TextEditingController _searchController = TextEditingController();
  String selectedLocation = "All";

  // Dummy data
  final List<Map<String, dynamic>> estates = [
    {
      "name": "Farouk Mwanje kavuma",
      "location": "Lisa Sass gata 18",
      "properties": 3,
      "tenants": 4,
      "rent": 3200,
      "occupancy": 1.0,
      "active": true,
    },
    {
      "name": "Mwanjefarouk's Org",
      "location": "Lisa Sass gata 18",
      "properties": 1,
      "tenants": 1,
      "rent": 950,
      "occupancy": 1.0,
      "active": true,
    },
    {
      "name": "Here",
      "location": "Lisa Sass gata 18",
      "properties": 1,
      "tenants": 1,
      "rent": 950,
      "occupancy": 1.0,
      "active": true,
    },
    {
      "name": "Farouk Mwanje kavuma",
      "location": "Västra Andersgårdsgatan 7A Göteborg",
      "properties": 1,
      "tenants": 1,
      "rent": 1200,
      "occupancy": 1.0,
      "active": true,
    },
  ];

  void _showCreateEstateDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          _CreateEstateDialog(onEstateCreated: _addEstateToList),
    );
  }

  Future<void> _addEstateToList(Map<String, dynamic> newEstate) async {
    // Add to Firestore
    await FirebaseFirestore.instance.collection('estates').add(newEstate);
    setState(() {
      estates.add(newEstate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int totalEstates = estates.length;
    int totalProperties = estates.fold(
      0,
      (sum, e) => sum + (e["properties"] as int),
    );
    int totalTenants = estates.fold(0, (sum, e) => sum + (e["tenants"] as int));

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: _SummaryCard(
                    icon: Icons.apartment,
                    label: "Estates",
                    value: "$totalEstates",
                    color: const Color(0xFF3B5AFE),
                    labelAbove: true,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: _SummaryCard(
                    icon: Icons.home,
                    label: "Properties",
                    value: "$totalProperties",
                    color: const Color(0xFF00C853),
                    labelAbove: true,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: _SummaryCard(
                    icon: Icons.people,
                    label: "Tenants",
                    value: "$totalTenants",
                    color: const Color(0xFF8E24AA),
                    labelAbove: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Search and filter
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search estates...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF232B3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedLocation,
                dropdownColor: const Color(0xFF232B3E),
                style: const TextStyle(color: Colors.white),
                items:
                    [
                          "All",
                          ...estates
                              .map((e) => e["location"].toString())
                              .toSet(),
                        ]
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => selectedLocation = v);
                },
              ),
            ],
          ),
        ),
        // Estate List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: estates.length,
            itemBuilder: (context, i) {
              final e = estates[i];
              if ((selectedLocation != "All" &&
                      e["location"] != selectedLocation) ||
                  (_searchController.text.isNotEmpty &&
                      !e["name"].toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      ))) {
                return const SizedBox.shrink();
              }
              return _EstateCard(estate: e);
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool labelAbove;

  const _SummaryCard({
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
                      child: Icon(icon, color: Colors.white, size: 24),
                      radius: 18,
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

class _EstateCard extends StatelessWidget {
  final Map<String, dynamic> estate;
  const _EstateCard({required this.estate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: const Color(0xFF232B3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estate name and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    estate["name"] ?? "",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: estate["active"]
                        ? const Color(0xFF1DE9B6)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    estate["active"] ? "Active" : "Inactive",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF3FE0F6),
                  size: 15,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    estate["location"],
                    style: const TextStyle(
                      color: Color(0xFF3FE0F6),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.home, color: Colors.white70, size: 15),
                  const SizedBox(width: 2),
                  Text(
                    "${estate["properties"]} Properties",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.people, color: Colors.white70, size: 15),
                  const SizedBox(width: 2),
                  Text(
                    "${estate["tenants"]} Tenants",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.attach_money, color: Colors.white70, size: 15),
                  const SizedBox(width: 2),
                  Text(
                    "\$${estate["rent"]}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.pie_chart,
                    color: estate["occupancy"] == 1.0
                        ? Colors.green
                        : Colors.orange,
                    size: 15,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    "${(estate["occupancy"] * 100).toStringAsFixed(0)}% Occupied",
                    style: TextStyle(
                      color: estate["occupancy"] == 1.0
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Quick actions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3FE0F6),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 13),
                      minimumSize: const Size(0, 36),
                    ),
                    icon: const Icon(Icons.grid_view, size: 18),
                    label: const Text("Properties"),
                    onPressed: () {
                      // TODO: Show property grid for this estate
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF232B3E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 13),
                      minimumSize: const Size(0, 36),
                    ),
                    icon: const Icon(Icons.people, size: 18),
                    label: const Text("Tenants"),
                    onPressed: () {
                      // TODO: Show tenants for this estate
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF3FE0F6),
                      size: 20,
                    ),
                    tooltip: "Estate Details",
                    onPressed: () {
                      // TODO: Show estate detail view
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateEstateDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onEstateCreated;
  const _CreateEstateDialog({required this.onEstateCreated});

  @override
  State<_CreateEstateDialog> createState() => _CreateEstateDialogState();
}

class _CreateEstateDialogState extends State<_CreateEstateDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF181F2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.apartment, color: Color(0xFF3FE0F6)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Create New Estate",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final newEstate = {
                            "name": name,
                            "address": address,
                            "desc": description,
                            "properties": 0,
                            "tenants": 0,
                            "active": true,
                          };
                          await widget.onEstateCreated(newEstate);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text("Create Estate"),
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
