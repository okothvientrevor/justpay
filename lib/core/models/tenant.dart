enum TenantStatus { active, inactive, pending, terminated }

class Tenant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String tenantId;
  final String propertyId;
  final double rentAmount;
  final DateTime? leaseStart;
  final DateTime? leaseEnd;
  final TenantStatus status;

  Tenant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.tenantId,
    required this.propertyId,
    required this.rentAmount,
    this.leaseStart,
    this.leaseEnd,
    required this.status,
  });
}
