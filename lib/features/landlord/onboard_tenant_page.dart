import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardTenantPage extends StatefulWidget {
  const OnboardTenantPage({super.key});

  @override
  State<OnboardTenantPage> createState() => _OnboardTenantPageState();
}

class _OnboardTenantPageState extends State<OnboardTenantPage> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String phone = '';
  String email = '';
  String? selectedEstate;
  String? selectedProperty;
  String unit = '';
  List<Map<String, dynamic>> allProperties = [];
  List<String> estateOptions = [];
  List<String> propertyOptions = [];
  String notes = '';
  bool loading = false;
  int rent = 0;
  int deposit = 0;
  DateTime? leaseStart;
  DateTime? leaseEnd;

  @override
  void initState() {
    super.initState();
    _loadEstates();
    _loadProperties();
  }

  Future<void> _loadEstates() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('estates')
        .get();
    setState(() {
      estateOptions = snapshot.docs
          .map((doc) => doc.data()['name'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    });
  }

  Future<void> _loadProperties() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('properties')
        .get();
    setState(() {
      allProperties = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _updatePropertyOptions();
    });
  }

  void _updatePropertyOptions() {
    if (selectedEstate == null ||
        selectedEstate == '' ||
        selectedEstate == 'None') {
      propertyOptions = [];
    } else {
      propertyOptions = allProperties
          .where((p) => (p['estate'] ?? '') == selectedEstate)
          .map((p) => p['address'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  Future<void> _onboardTenant() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final tenant = {
      'name': '$firstName $lastName',
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'estate': selectedEstate,
      'property': selectedProperty,
      'unit': unit,
      'rent': rent,
      'deposit': deposit,
      'leaseStart': leaseStart?.toIso8601String(),
      'leaseEnd': leaseEnd?.toIso8601String(),
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('tenants').add(tenant);
    setState(() => loading = false);
    Navigator.of(context).pop();
  }

  Future<void> _pickLeaseStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: leaseStart ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3FE0F6),
              surface: Color(0xFF1A1F2E),
              background: Color(0xFF0F1419),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => leaseStart = picked);
  }

  Future<void> _pickLeaseEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: leaseEnd ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3FE0F6),
              surface: Color(0xFF1A1F2E),
              background: Color(0xFF0F1419),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => leaseEnd = picked);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    String? hint,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? initialValue,
    int maxLines = 1,
    Widget? suffixIcon,
    bool required = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Color(0xFF3FE0F6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            validator: validator,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF3FE0F6),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
    bool required = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Color(0xFF3FE0F6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            dropdownColor: const Color(0xFF1A1F2E),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF3FE0F6),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool required = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Color(0xFF3FE0F6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      date != null
                          ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
                          : 'Select date',
                      style: TextStyle(
                        color: date != null
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add New Tenant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3FE0F6).withOpacity(0.1),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3FE0F6).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3FE0F6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: Color(0xFF3FE0F6),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            "Enter the tenant's details. Fields marked with * are required.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information
                  _buildSection('Personal Information', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            label: 'First Name',
                            hint: 'Enter first name',
                            onChanged: (v) => firstName = v,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                            required: true,
                            suffixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernTextField(
                            label: 'Last Name',
                            hint: 'Enter last name',
                            onChanged: (v) => lastName = v,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            label: 'Phone Number',
                            hint: '+256 7XX XXX XXX',
                            onChanged: (v) => phone = v,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                            required: true,
                            keyboardType: TextInputType.phone,
                            suffixIcon: Icon(
                              Icons.phone_rounded,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernTextField(
                            label: 'Email',
                            hint: 'tenant@example.com',
                            onChanged: (v) => email = v,
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: Icon(
                              Icons.email_rounded,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),

                  // Property Assignment
                  _buildSection('Property Assignment', [
                    _buildModernDropdown<String>(
                      label: 'Estate',
                      value: selectedEstate,
                      items: [
                        const DropdownMenuItem(
                          value: 'None',
                          child: Text('None'),
                        ),
                        ...estateOptions.map(
                          (e) => DropdownMenuItem(value: e, child: Text(e)),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          selectedEstate = v;
                          selectedProperty = null;
                          _updatePropertyOptions();
                        });
                      },
                    ),
                    if (selectedEstate != null &&
                        selectedEstate != '' &&
                        selectedEstate != 'None')
                      _buildModernDropdown<String>(
                        label: 'Property',
                        value: selectedProperty,
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Select a property'),
                          ),
                          ...propertyOptions.map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          ),
                        ],
                        onChanged: (v) => setState(() => selectedProperty = v),
                      ),
                    _buildModernTextField(
                      label: 'Unit Number',
                      hint: 'e.g., Apt 101, Unit A',
                      onChanged: (v) => unit = v,
                      suffixIcon: Icon(
                        Icons.home_rounded,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ]),

                  // Financial Information
                  _buildSection('Financial Information', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            label: 'Monthly Rent (UGX)',
                            hint: '0',
                            onChanged: (v) => rent = int.tryParse(v) ?? 0,
                            keyboardType: TextInputType.number,
                            suffixIcon: Icon(
                              Icons.attach_money_rounded,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernTextField(
                            label: 'Security Deposit (UGX)',
                            hint: '0',
                            onChanged: (v) => deposit = int.tryParse(v) ?? 0,
                            keyboardType: TextInputType.number,
                            suffixIcon: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),

                  // Lease Information
                  _buildSection('Lease Information', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePicker(
                            label: 'Lease Start Date',
                            date: leaseStart,
                            onTap: _pickLeaseStart,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDatePicker(
                            label: 'Lease End Date',
                            date: leaseEnd,
                            onTap: _pickLeaseEnd,
                          ),
                        ),
                      ],
                    ),
                    _buildModernTextField(
                      label: 'Additional Notes',
                      hint: 'Any additional information about the tenant',
                      onChanged: (v) => notes = v,
                      maxLines: 3,
                      suffixIcon: Icon(
                        Icons.notes_rounded,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ]),

                  // Action Buttons
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3FE0F6), Color(0xFF2DD4BF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3FE0F6).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: loading ? null : _onboardTenant,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Onboard Tenant',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
