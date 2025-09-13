import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePropertyPage extends StatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  State<CreatePropertyPage> createState() => _CreatePropertyPageState();
}

class _CreatePropertyPageState extends State<CreatePropertyPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedEstate;
  String? propertyType;
  String address = '';
  String unit = '';
  int rooms = 1;
  int rent = 0;
  int sqft = 0;
  String status = 'Available';
  String description = '';
  List<String> tenants = [];
  bool loading = false;
  List<String> estateOptions = [];
  List<String> tenantOptions = [];

  @override
  void initState() {
    super.initState();
    _loadEstates();
    _loadTenants();
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

  Future<void> _loadTenants() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tenants')
        .get();
    setState(() {
      tenantOptions = snapshot.docs
          .map((doc) => doc.data()['name'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    });
  }

  Future<void> _createProperty() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final property = {
      'estate': selectedEstate,
      'type': propertyType,
      'address': address,
      'unit': unit,
      'rooms': rooms,
      'rent': rent,
      'sqft': sqft,
      'status': status,
      'description': description,
      'tenants': tenants,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('properties').add(property);
    setState(() => loading = false);
    Navigator.of(context).pop();
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Color _getStatusColor(String statusValue) {
    switch (statusValue) {
      case 'Available':
        return Colors.green;
      case 'Vacant':
        return Colors.orange;
      case 'Occupied':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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
          'Add New Property',
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
                            Icons.home_work_rounded,
                            color: Color(0xFF3FE0F6),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Create a new property listing for your estate or portfolio.',
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

                  // Basic Information
                  _buildSection('Basic Information', [
                    _buildModernDropdown<String>(
                      label: 'Estate (Optional)',
                      value: selectedEstate == null ? '' : selectedEstate,
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('No estate'),
                        ),
                        ...estateOptions.map(
                          (e) => DropdownMenuItem(value: e, child: Text(e)),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => selectedEstate = v == '' ? null : v),
                    ),
                    _buildModernDropdown<String>(
                      label: 'Property Type',
                      value: propertyType,
                      items: ['Apartment', 'House', 'Commercial']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => propertyType = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    _buildModernTextField(
                      label: 'Address',
                      hint: 'Enter property address',
                      onChanged: (v) => address = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      suffixIcon: Icon(
                        Icons.location_on_rounded,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    _buildModernTextField(
                      label: 'Unit',
                      hint: 'Unit number/name',
                      onChanged: (v) => unit = v,
                    ),
                  ]),

                  // Property Details
                  _buildSection('Property Details', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            label: 'Number of Rooms',
                            onChanged: (v) => rooms = int.tryParse(v) ?? 1,
                            keyboardType: TextInputType.number,
                            initialValue: rooms.toString(),
                            suffixIcon: Icon(
                              Icons.bed_rounded,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernTextField(
                            label: 'Rent Amount',
                            onChanged: (v) => rent = int.tryParse(v) ?? 0,
                            keyboardType: TextInputType.number,
                            initialValue: rent.toString(),
                            suffixIcon: Icon(
                              Icons.attach_money_rounded,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildModernTextField(
                      label: 'Floor Area (sq ft)',
                      hint: 'Optional',
                      onChanged: (v) => sqft = int.tryParse(v) ?? 0,
                      keyboardType: TextInputType.number,
                      suffixIcon: Icon(
                        Icons.square_foot_rounded,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    _buildModernDropdown<String>(
                      label: 'Status',
                      value: status,
                      items: ['Available', 'Vacant', 'Occupied']
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(e),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(e),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => status = v ?? 'Available'),
                    ),
                  ]),

                  // Additional Information
                  _buildSection('Additional Information', [
                    _buildModernTextField(
                      label: 'Description',
                      hint: 'Optional property description',
                      onChanged: (v) => description = v,
                      maxLines: 3,
                    ),
                    _buildModernDropdown<String>(
                      label: 'Tenant (Optional)',
                      value: tenants.isNotEmpty ? tenants.first : null,
                      items: tenantOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          tenants = v != null ? [v] : [];
                        });
                      },
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
                            onPressed: loading ? null : _createProperty,
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
                                    'Add Property',
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
