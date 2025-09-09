enum LeaseStatus { active, expired, terminated, pending }

class Lease {
  final String id;
  final String propertyId;
  final String tenantId;
  final DateTime startDate;
  final DateTime endDate;
  final double rentAmount;
  final double depositAmount;
  final int noticePeriodDays;
  final bool autoRenew;
  final LeaseStatus status;

  Lease({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    required this.depositAmount,
    required this.noticePeriodDays,
    required this.autoRenew,
    required this.status,
  });
}
