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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Property'),
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
                    'Create a new property listing for your estate or portfolio.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: selectedEstate == null ? '' : selectedEstate,
                    items:
                        [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('No estate'),
                          ),
                        ] +
                        estateOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) =>
                        setState(() => selectedEstate = v == '' ? null : v),
                    decoration: InputDecoration(
                      labelText: 'Estate (optional)',
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: propertyType,
                    items: ['Apartment', 'House', 'Commercial']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => propertyType = v),
                    decoration: InputDecoration(
                      labelText: 'Property Type',
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
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter property address',
                      hintStyle: const TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => address = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Unit number/name',
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
                            labelText: 'Number of Rooms',
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
                          initialValue: rooms.toString(),
                          onChanged: (v) => rooms = int.tryParse(v) ?? 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Rent Amount',
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
                          initialValue: rent.toString(),
                          onChanged: (v) => rent = int.tryParse(v) ?? 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Floor Area (sq ft)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Optional',
                      hintStyle: const TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => sqft = int.tryParse(v) ?? 0,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: ['Available', 'Vacant', 'Occupied']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => status = v ?? 'Available'),
                    decoration: InputDecoration(
                      labelText: 'Status',
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
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Optional property description',
                      hintStyle: const TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    onChanged: (v) => description = v,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tenants.isNotEmpty ? tenants.first : null,
                    items: tenantOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        tenants = v != null ? [v] : [];
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Tenant (optional)',
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
                          onPressed: loading ? null : _createProperty,
                          child: loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Add Property"),
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
