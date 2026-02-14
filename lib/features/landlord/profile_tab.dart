import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:justpay/features/landlord/app_settings_page.dart';
import 'package:justpay/features/landlord/integration_settings_page.dart';
import 'package:justpay/features/landlord/support_page.dart';
import 'package:justpay/features/landlord/team_management_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/payment_service.dart';
import '../../services/storage_service_fallback.dart';

class LandlordProfileTab extends StatefulWidget {
  final String email;
  const LandlordProfileTab({super.key, required this.email});

  @override
  State<LandlordProfileTab> createState() => _LandlordProfileTabState();
}

class _LandlordProfileTabState extends State<LandlordProfileTab> {
  String name = "Landlord";
  String phone = "";
  bool _initialized = false;
  bool _isAccountVerified = false;
  Map<String, dynamic>? _landlordAccount;

  @override
  void initState() {
    super.initState();
    _initLocalProfile();
    _loadStripeAccountStatus();
  }

  Future<void> _initLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final localName = prefs.getString('landlord_name');
    final localPhone = prefs.getString('landlord_phone');
    setState(() {
      name = localName ?? name;
      phone = localPhone ?? phone;
      _initialized = true;
    });
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Replace 'userId' with actual user id
    final doc = await FirebaseFirestore.instance
        .collection('landlords')
        .doc('userId')
        .get();
    if (doc.exists) {
      setState(() {
        name = doc.data()?['name'] ?? "Landlord";
        phone = doc.data()?['phone'] ?? "";
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('landlord_name', name);
      await prefs.setString('landlord_phone', phone);
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3FE0F6),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('landlords')
                            .doc('userId')
                            .set({
                              'name': nameController.text,
                              'phone': phoneController.text,
                            }, SetOptions(merge: true));
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          'landlord_name',
                          nameController.text,
                        );
                        await prefs.setString(
                          'landlord_phone',
                          phoneController.text,
                        );
                        setState(() {
                          name = nameController.text;
                          phone = phoneController.text;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  Future<void> _loadStripeAccountStatus() async {
    final account = await StorageService.getLandlordAccount();
    final isVerified = await StorageService.isLandlordAccountVerified();

    setState(() {
      _landlordAccount = account;
      _isAccountVerified = isVerified;
    });
  }

  Future<void> _createStripeAccount() async {
    // Show form dialog to collect landlord details
    await _showStripeSetupDialog();
  }

  Future<void> _showStripeSetupDialog() async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController(text: widget.email);
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final businessNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Stripe Account'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: businessNameController,
                  decoration: const InputDecoration(
                    labelText: 'Business Name (Optional)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _processStripeAccountCreation(
                  emailController.text,
                  firstNameController.text,
                  lastNameController.text,
                  businessNameController.text,
                );
              }
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _processStripeAccountCreation(
    String email,
    String firstName,
    String lastName,
    String businessName,
  ) async {
    try {
      // Test backend connectivity first
      _showSuccessMessage('Testing backend connection...');
      final isConnected = await PaymentService.testBackendConnection();

      if (!isConnected) {
        _showErrorMessage(
          'Backend service is not available. Please check your internet connection or try again later.',
        );
        return;
      }

      // Save profile data
      final profileData = {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'businessName': businessName,
      };
      await StorageService.saveLandlordProfile(profileData);

      _showSuccessMessage('Creating Stripe account...');

      // Create Stripe account
      final account = await PaymentService.createLandlordAccount(
        email: email,
        firstName: firstName,
        lastName: lastName,
        businessName: businessName.isEmpty ? null : businessName,
      );

      if (account != null) {
        await StorageService.saveLandlordAccount(account);
        setState(() {
          _landlordAccount = account;
        });

        _showSuccessMessage(
          'Stripe account created! Please complete verification.',
        );
      } else {
        _showErrorMessage('Failed to create Stripe account. Please try again.');
      }
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  Future<void> _completeStripeOnboarding() async {
    if (_landlordAccount == null) return;

    try {
      final onboardingUrl = await PaymentService.getLandlordOnboardingLink(
        _landlordAccount!['accountId'],
      );

      if (onboardingUrl != null) {
        await launchUrl(
          Uri.parse(onboardingUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showErrorMessage('Failed to get onboarding link.');
      }
    } catch (e) {
      _showErrorMessage('Error opening onboarding: $e');
    }
  }

  Future<void> _checkStripeAccountStatus() async {
    if (_landlordAccount == null) return;

    try {
      final status = await PaymentService.getLandlordAccountStatus(
        _landlordAccount!['accountId'],
      );

      if (status != null) {
        await StorageService.saveLandlordAccount(status);
        setState(() {
          _landlordAccount = status;
          _isAccountVerified =
              status['chargesEnabled'] == true &&
              status['payoutsEnabled'] == true;
        });

        if (_isAccountVerified) {
          _showSuccessMessage(
            'Account verified! You can now receive payments.',
          );
        } else {
          _showErrorMessage(
            'Verification still pending. Please complete all required steps.',
          );
        }
      }
    } catch (e) {
      _showErrorMessage('Error checking account status: $e');
    }
  }

  Future<void> _openStripeDashboard() async {
    if (_landlordAccount == null) return;

    final dashboardUrl = await PaymentService.getLandlordDashboardLink(
      _landlordAccount!['accountId'],
    );

    if (dashboardUrl != null) {
      await launchUrl(
        Uri.parse(dashboardUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // User Profile Section
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF3FE0F6),
                      child: Icon(Icons.person, size: 48, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name.isNotEmpty ? name : "Landlord",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    // Text(
                    //   widget.email,
                    //   style: theme.textTheme.bodyMedium?.copyWith(
                    //     color: Colors.white70,
                    //   ),
                    // ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3FE0F6),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _showEditProfileDialog(context),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stripe verification status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isAccountVerified
                            ? Colors.green.withOpacity(0.2)
                            : _landlordAccount != null
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAccountVerified
                                ? Icons.check_circle
                                : _landlordAccount != null
                                ? Icons.pending
                                : Icons.error,
                            size: 16,
                            color: _isAccountVerified
                                ? Colors.green
                                : _landlordAccount != null
                                ? Colors.orange
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isAccountVerified
                                ? "Payments Enabled"
                                : _landlordAccount != null
                                ? "Verification Pending"
                                : "Setup Required",
                            style: TextStyle(
                              fontSize: 12,
                              color: _isAccountVerified
                                  ? Colors.green
                                  : _landlordAccount != null
                                  ? Colors.orange
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Payment Integration Section
              _ProfileMenuSection(
                title: "Payment Integration",
                items: [
                  if (_landlordAccount == null)
                    _ProfileMenuItem(
                      icon: Icons.account_balance,
                      label: "Setup Stripe Account",
                      onTap: _createStripeAccount,
                    ),
                  if (_landlordAccount != null && !_isAccountVerified)
                    _ProfileMenuItem(
                      icon: Icons.launch,
                      label: "Complete Stripe Verification",
                      onTap: _completeStripeOnboarding,
                    ),
                  if (_landlordAccount != null && !_isAccountVerified)
                    _ProfileMenuItem(
                      icon: Icons.refresh,
                      label: "Check Verification Status",
                      onTap: _checkStripeAccountStatus,
                    ),
                  if (_isAccountVerified)
                    _ProfileMenuItem(
                      icon: Icons.dashboard,
                      label: "View Stripe Dashboard",
                      onTap: _openStripeDashboard,
                    ),
                  if (_isAccountVerified)
                    _ProfileMenuItem(
                      icon: Icons.receipt,
                      label: "Create Invoice",
                      onTap: () {
                        // TODO: Navigate to create invoice page
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Essential Menu Sections
              _ProfileMenuSection(
                title: "Settings & Support",
                items: [
                  _ProfileMenuItem(
                    icon: Icons.settings,
                    label: "App Settings & Notifications",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AppSettingsPage(),
                      ),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.support_agent,
                    label: "Support & Help Center",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SupportPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileMenuSection(
                title: "Team & Integrations",
                items: [
                  _ProfileMenuItem(
                    icon: Icons.group,
                    label: "Team Management",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TeamManagementPage(),
                      ),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.sync,
                    label: "Integration Settings",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const IntegrationSettingsPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                // TODO: Navigate to login screen
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text(
                "Log Out",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<_ProfileMenuItem> items;
  const _ProfileMenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF232B3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF3FE0F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}
