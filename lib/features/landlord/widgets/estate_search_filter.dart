import 'package:flutter/material.dart';

class EstateSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedLocation;
  final List<Map<String, dynamic>> estates;
  final VoidCallback onSearchChanged;
  final ValueChanged<String> onLocationChanged;

  const EstateSearchFilter({
    super.key,
    required this.searchController,
    required this.selectedLocation,
    required this.estates,
    required this.onSearchChanged,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
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
              onChanged: (value) => onSearchChanged(),
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
                          .map((e) => e["location"]?.toString() ?? "")
                          .where((location) => location.isNotEmpty)
                          .toSet(),
                    ]
                    .map(
                      (location) => DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) {
                onLocationChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
