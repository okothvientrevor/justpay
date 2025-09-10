import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstateCard extends StatelessWidget {
  final Map<String, dynamic> estate;
  final VoidCallback onTap;

  const EstateCard({super.key, required this.estate, required this.onTap});

  Future<List<int>> _fetchEstateCounts(String estateName) async {
    final propertiesSnap = await FirebaseFirestore.instance
        .collection('properties')
        .where('estate', isEqualTo: estateName)
        .get();
    final tenantsSnap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('estate', isEqualTo: estateName)
        .get();
    return [propertiesSnap.size, tenantsSnap.size];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<int>>(
      future: _fetchEstateCounts(estate["name"] ?? ""),
      builder: (context, snapshot) {
        final propertyCount = snapshot.data?[0] ?? 0;
        final tenantCount = snapshot.data?[1] ?? 0;

        return GestureDetector(
          onTap: onTap,
          child: Card(
            color: const Color(0xFF232B3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estate name and status
                  EstateHeader(estate: estate, theme: theme),
                  const SizedBox(height: 4),

                  // Location
                  EstateLocation(estate: estate),
                  const SizedBox(height: 8),

                  // Stats
                  EstateStats(
                    propertyCount: propertyCount,
                    tenantCount: tenantCount,
                    estate: estate,
                  ),

                  // Quick actions
                  EstateActions(estate: estate),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class EstateHeader extends StatelessWidget {
  final Map<String, dynamic> estate;
  final ThemeData theme;

  const EstateHeader({super.key, required this.estate, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: (estate["active"] ?? true)
                ? const Color(0xFF1DE9B6)
                : Colors.grey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            (estate["active"] ?? true) ? "Active" : "Inactive",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class EstateLocation extends StatelessWidget {
  final Map<String, dynamic> estate;

  const EstateLocation({super.key, required this.estate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Color(0xFF3FE0F6), size: 15),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            estate["address"] ?? estate["location"] ?? "",
            style: const TextStyle(color: Color(0xFF3FE0F6), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class EstateStats extends StatelessWidget {
  final int propertyCount;
  final int tenantCount;
  final Map<String, dynamic> estate;

  const EstateStats({
    super.key,
    required this.propertyCount,
    required this.tenantCount,
    required this.estate,
  });

  @override
  Widget build(BuildContext context) {
    final occupancy = estate["occupancy"] as double? ?? 1.0;
    final occupancyPercentage = (occupancy * 100).toStringAsFixed(0);
    final isFullyOccupied = occupancy == 1.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(Icons.home, color: Colors.white70, size: 15),
          const SizedBox(width: 2),
          Text(
            "$propertyCount Properties",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.people, color: Colors.white70, size: 15),
          const SizedBox(width: 2),
          Text(
            "$tenantCount Tenants",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.pie_chart,
            color: isFullyOccupied ? Colors.green : Colors.orange,
            size: 15,
          ),
          const SizedBox(width: 2),
          Text(
            "$occupancyPercentage% Occupied",
            style: TextStyle(
              color: isFullyOccupied ? Colors.green : Colors.orange,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class EstateActions extends StatelessWidget {
  final Map<String, dynamic> estate;

  const EstateActions({super.key, required this.estate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
    );
  }
}
