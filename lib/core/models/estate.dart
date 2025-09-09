import 'property.dart';

class Estate {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String landlordId;
  final List<Property> properties;
  final int totalTenants;
  final double occupancyRate;

  Estate({
    required this.id,
    required this.name,
    this.description,
    this.address,
    required this.landlordId,
    required this.properties,
    required this.totalTenants,
    required this.occupancyRate,
  });
}
