import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:justpay/features/landlord/estate_details_page.dart';
import 'package:justpay/features/landlord/widgets/estate_summary_card.dart';

import 'package:justpay/features/landlord/widgets/estate_search_filter.dart';
import 'package:justpay/features/landlord/widgets/estate_card.dart';
import 'package:justpay/features/landlord/widgets/create_estate_dialog.dart';

class LandlordEstatesTab extends StatefulWidget {
  const LandlordEstatesTab({super.key});

  @override
  State<LandlordEstatesTab> createState() => _LandlordEstatesTabState();
}

class _LandlordEstatesTabState extends State<LandlordEstatesTab> {
  final TextEditingController _searchController = TextEditingController();
  String selectedLocation = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: _fetchCounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final counts = snapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('estates').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No estates found',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final estates = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            final filteredEstates = _filterEstates(estates);

            return Column(
              children: [
                // Summary Cards
                EstateSummaryCards(counts: counts),

                // Search and Filter
                EstateSearchFilter(
                  searchController: _searchController,
                  selectedLocation: selectedLocation,
                  estates: estates,
                  onSearchChanged: () => setState(() {}),
                  onLocationChanged: (location) =>
                      setState(() => selectedLocation = location),
                ),

                // Estate List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredEstates.length,
                    itemBuilder: (context, index) {
                      return EstateCard(
                        estate: filteredEstates[index],
                        onTap: () =>
                            _navigateToEstateDetails(filteredEstates[index]),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterEstates(
    List<Map<String, dynamic>> estates,
  ) {
    return estates.where((estate) {
      final matchesLocation =
          selectedLocation == "All" ||
          (estate["location"] ?? "") == selectedLocation;

      final matchesSearch =
          _searchController.text.isEmpty ||
          (estate["name"]?.toLowerCase() ?? "").contains(
            _searchController.text.toLowerCase(),
          );

      return matchesLocation && matchesSearch;
    }).toList();
  }

  void _navigateToEstateDetails(Map<String, dynamic> estate) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EstateDetailsPage(estate: estate)),
    );
  }

  Future<List<int>> _fetchCounts() async {
    final estatesSnap = await FirebaseFirestore.instance
        .collection('estates')
        .get();
    final propertiesSnap = await FirebaseFirestore.instance
        .collection('properties')
        .get();
    final tenantsSnap = await FirebaseFirestore.instance
        .collection('tenants')
        .get();
    return [estatesSnap.size, propertiesSnap.size, tenantsSnap.size];
  }
}
