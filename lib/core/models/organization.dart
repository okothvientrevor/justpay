class Organization {
  final String id;
  final String name;
  final String type; // 'property_management' or 'school'
  final String slug;
  final String? logoUrl;
  final String primaryColor;
  final String secondaryColor;
  final OrganizationSettings settings;

  Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.slug,
    this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.settings,
  });
}

class OrganizationSettings {
  // Define organization settings fields here
  // ...add fields as needed...
}
