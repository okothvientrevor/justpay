import 'package:justpay/core/models/tenant.dart';

enum PropertyStatus { vacant, occupied, maintenance }

class Property {
  final String id;
  final String name;
  final String propertyNumber;
  final String estateId;
  final double rentAmount;
  final int bedrooms;
  final int bathrooms;
  final PropertyStatus status;
  final Tenant? currentTenant;

  Property({
    required this.id,
    required this.name,
    required this.propertyNumber,
    required this.estateId,
    required this.rentAmount,
    required this.bedrooms,
    required this.bathrooms,
    required this.status,
    this.currentTenant,
  });
}
