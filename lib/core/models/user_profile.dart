enum UserRole { landlord, school, tenant, parent, student, admin }

class UserProfile {
  final String id;
  final String email;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? organizationId;
  final Map<String, dynamic>? metadata;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.organizationId,
    this.metadata,
  });
}
