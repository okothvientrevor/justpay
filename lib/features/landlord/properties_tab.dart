import 'package:flutter/material.dart';

class LandlordPropertiesTab extends StatefulWidget {
  const LandlordPropertiesTab({super.key});

  @override
  State<LandlordPropertiesTab> createState() => _LandlordPropertiesTabState();
}

class _LandlordPropertiesTabState extends State<LandlordPropertiesTab> {
  bool gridView = true;
  String selectedEstate = "All";
  String selectedType = "All";
  String selectedStatus = "All";

  // Dummy property data
  final List<Map<String, dynamic>> properties = [
    {
      "photo": null,
      "address": "Apt 3B, Lisa Sass gata 18",
      "unit": "3B",
      "type": "Apartment",
      "rent": 1200,
      "status": "Occupied",
      "rooms": 3,
      "sqft": 120,
      "parking": true,
      "tenant": "John Doe",
    },
    {
      "photo": null,
      "address": "Flat 65, Dunbridge House",
      "unit": "65",
      "type": "Apartment",
      "rent": 950,
      "status": "Vacant",
      "rooms": 2,
      "sqft": 90,
      "parking": false,
      "tenant": null,
    },
    // ...add more properties as needed...
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: const Color(0xFF181F2A),
      child: Column(
        children: [
          // Filter and view toggle bar (modern, compact, scrollable if needed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterDropdown(
                    value: selectedEstate,
                    items: ["All", "Lisa Sass gata 18", "Dunbridge House"],
                    onChanged: (v) {
                      if (v != null) setState(() => selectedEstate = v);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterDropdown(
                    value: selectedType,
                    items: ["All", "Apartment", "House", "Commercial"],
                    onChanged: (v) {
                      if (v != null) setState(() => selectedType = v);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterDropdown(
                    value: selectedStatus,
                    items: ["All", "Occupied", "Vacant"],
                    onChanged: (v) {
                      if (v != null) setState(() => selectedStatus = v);
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      gridView
                          ? Icons.grid_view_rounded
                          : Icons.view_agenda_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => gridView = !gridView),
                    tooltip: gridView ? "List View" : "Grid View",
                  ),
                ],
              ),
            ),
          ),
          // Properties grid/list
          Expanded(
            child: gridView
                ? GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: properties.length,
                    itemBuilder: (context, i) {
                      final p = properties[i];
                      if ((selectedEstate != "All" &&
                              !p["address"].contains(selectedEstate)) ||
                          (selectedType != "All" &&
                              p["type"] != selectedType) ||
                          (selectedStatus != "All" &&
                              p["status"] != selectedStatus)) {
                        return const SizedBox.shrink();
                      }
                      return _PropertyCardModern(property: p);
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: properties.length,
                    itemBuilder: (context, i) {
                      final p = properties[i];
                      if ((selectedEstate != "All" &&
                              !p["address"].contains(selectedEstate)) ||
                          (selectedType != "All" &&
                              p["type"] != selectedType) ||
                          (selectedStatus != "All" &&
                              p["status"] != selectedStatus)) {
                        return const SizedBox.shrink();
                      }
                      return _PropertyCardModern(property: p);
                    },
                  ),
          ),
          // Add Property button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FE0F6),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text("Add Property"),
                onPressed: () {
                  // TODO: Open property creation form
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF232B3E),
          style: const TextStyle(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
          isExpanded: false,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PropertyCardModern extends StatelessWidget {
  final Map<String, dynamic> property;
  const _PropertyCardModern({required this.property});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isVacant = property["status"] == "Vacant";
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232B3E),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(10), // Slightly less padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property photo
                Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    image: property["photo"] != null
                        ? DecorationImage(
                            image: NetworkImage(property["photo"]),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: property["photo"] == null
                      ? const Center(
                          child: Icon(
                            Icons.photo,
                            color: Colors.white54,
                            size: 24,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property["address"],
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
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isVacant ? Colors.orange[100] : Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isVacant ? "Vacant" : "Available",
                        style: TextStyle(
                          color: isVacant
                              ? Colors.orange[900]
                              : Colors.blue[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "${property["type"]} • Unit ${property["unit"]}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.meeting_room, color: Colors.white54, size: 13),
                    Flexible(
                      child: Text(
                        "${property["rooms"]} rooms",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.square_foot, color: Colors.white54, size: 13),
                    Flexible(
                      child: Text(
                        "${property["sqft"]} m²",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.white54, size: 13),
                    Flexible(
                      child: Text(
                        "UGX ${property["rent"]}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.people, color: Colors.white54, size: 13),
                    Flexible(
                      child: Text(
                        property["tenant"] != null ? "1 tenants" : "0 tenants",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Actions row, no Spacer, shrink to fit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF3FE0F6),
                        size: 18,
                      ),
                      tooltip: "View Details",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        // TODO: View property details
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.build,
                        color: Color(0xFF3FE0F6),
                        size: 18,
                      ),
                      tooltip: "Schedule Maintenance",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        // TODO: Schedule maintenance
                      },
                    ),
                    if (property["tenant"] != null)
                      IconButton(
                        icon: const Icon(
                          Icons.person,
                          color: Color(0xFF3FE0F6),
                          size: 18,
                        ),
                        tooltip: "Contact Tenant",
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          // TODO: Contact tenant
                        },
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
}
