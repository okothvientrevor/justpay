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
    );
    if (picked != null) setState(() => leaseStart = picked);
  }

  Future<void> _pickLeaseEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: leaseEnd ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => leaseEnd = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Tenant'),
        backgroundColor: const Color(0xFF181F2A),
      ),
      backgroundColor: const Color(0xFF181F2A),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF232B3E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter the tenant's details. All fields marked with * are required.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'First Name *',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF232B3E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (v) => firstName = v,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Last Name *',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF232B3E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (v) => lastName = v,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Phone Number *',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF232B3E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: '+256 7XX XXX XXX',
                            hintStyle: const TextStyle(color: Colors.white54),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (v) => phone = v,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email (Optional)',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF232B3E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'tenant@example.com',
                            hintStyle: const TextStyle(color: Colors.white54),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (v) => email = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedEstate,
                    items:
                        [
                          const DropdownMenuItem(
                            value: 'None',
                            child: Text('None'),
                          ),
                        ] +
                        estateOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedEstate = v;
                        selectedProperty = null;
                        _updatePropertyOptions();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Estate',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: const Color(0xFF232B3E),
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (selectedEstate != null &&
                      selectedEstate != '' &&
                      selectedEstate != 'None') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedProperty,
                      items:
                          [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Select a property'),
                            ),
                          ] +
                          propertyOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => selectedProperty = v),
                      decoration: InputDecoration(
                        labelText: 'Property',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF232B3E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: const Color(0xFF232B3E),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Unit Number (Optional)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'e.g., Apt 101, Unit A',
                      hintStyle: const TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => unit = v,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Monthly Rent (UGX)',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF232B3E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => rent = int.tryParse(v) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Security Deposit (UGX)',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF232B3E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => deposit = int.tryParse(v) ?? 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickLeaseStart,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Lease Start Date',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF232B3E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            child: Text(
                              leaseStart != null
                                  ? "${leaseStart!.day.toString().padLeft(2, '0')}/${leaseStart!.month.toString().padLeft(2, '0')}/${leaseStart!.year}"
                                  : 'Select date',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _pickLeaseEnd,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Lease End Date',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF232B3E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            child: Text(
                              leaseEnd != null
                                  ? "${leaseEnd!.day.toString().padLeft(2, '0')}/${leaseEnd!.month.toString().padLeft(2, '0')}/${leaseEnd!.year}"
                                  : 'Select date',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Additional Notes (Optional)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Any additional information about the tenant',
                      hintStyle: const TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    onChanged: (v) => notes = v,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF232B3E)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3FE0F6),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: loading ? null : _onboardTenant,
                          child: loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Onboard Tenant"),
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
