import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({Key? key}) : super(key: key);

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  String? selectedEstate;
  String? selectedTenant;
  String? selectedProperty;
  String? paymentMethod;
  String? paymentType;
  String? amount;
  String? description;

  List<String> estates = [];
  List<String> properties = [];
  List<String> tenants = [];
  final List<String> paymentMethods = ["Cash", "Bank Transfer", "Mobile Money"];
  final List<String> paymentTypes = [
    "Rent",
    "Deposit",
    "Utilities",
    "Maintenance",
    "Other",
  ];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEstates();
  }

  Future<void> _loadEstates() async {
    final estatesSnap = await FirebaseFirestore.instance
        .collection('estates')
        .get();
    if (!mounted) return;
    setState(() {
      estates = estatesSnap.docs
          .map((doc) => doc.data()['name'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    });
  }

  Future<void> _loadPropertiesAndTenants() async {
    if (selectedEstate == null) return;
    final propertiesSnap = await FirebaseFirestore.instance
        .collection('properties')
        .where('estate', isEqualTo: selectedEstate)
        .get();
    final tenantsSnap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('estate', isEqualTo: selectedEstate)
        .get();
    if (!mounted) return;
    setState(() {
      properties = propertiesSnap.docs
          .map((doc) => doc.data()['address'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      tenants = tenantsSnap.docs
          .map((doc) => doc.data()['name'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      selectedProperty = null;
      selectedTenant = null;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (selectedEstate == null ||
        selectedTenant == null ||
        selectedProperty == null ||
        amount == null ||
        amount!.isEmpty ||
        paymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final paymentData = {
      'estate': selectedEstate,
      'tenant': selectedTenant,
      'property': selectedProperty,
      'paymentMethod': paymentMethod,
      'paymentType': paymentType,
      'amount': double.tryParse(amount ?? '') ?? 0,
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await FirebaseFirestore.instance.collection('payments').add(paymentData);
    // Save to recent activities
    final activityDesc =
        'Tenant $selectedTenant has paid UGX ${amount ?? "0"} for $paymentType';
    await FirebaseFirestore.instance.collection('recent_activities').add({
      'tenant': selectedTenant,
      'estate': selectedEstate,
      'property': selectedProperty,
      'type': 'payment',
      'desc': activityDesc,
      'amount': double.tryParse(amount ?? '') ?? 0,
      'time': DateTime.now().toIso8601String(),
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181F2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Payment",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Record a new payment received from the tenant. Optionally, add a description and select the payment method.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 18),
            // Select Estate
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Estate",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedEstate,
              items: estates
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF232B3E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "Choose an estate",
                hintStyle: const TextStyle(color: Colors.white54),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              dropdownColor: const Color(0xFF232B3E),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) {
                setState(() => selectedEstate = v);
                _loadPropertiesAndTenants();
              },
            ),
            const SizedBox(height: 16),
            // Select Property
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Property",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedProperty,
              items: properties
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF232B3E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "Choose a property",
                hintStyle: const TextStyle(color: Colors.white54),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              dropdownColor: const Color(0xFF232B3E),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => selectedProperty = v),
            ),
            const SizedBox(height: 16),
            // Select Tenant
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Tenant",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedTenant,
              items: tenants
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF232B3E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "Choose a tenant",
                hintStyle: const TextStyle(color: Colors.white54),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              dropdownColor: const Color(0xFF232B3E),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => selectedTenant = v),
            ),
            const SizedBox(height: 16),
            // Payment Details
            Row(
              children: [
                const Icon(Icons.attach_money, color: Color(0xFF3FE0F6)),
                const SizedBox(width: 8),
                const Text(
                  "Payment Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter amount",
                      hintStyle: const TextStyle(color: Colors.white54),
                      labelText: "Amount (UGX)",
                      labelStyle: const TextStyle(color: Colors.white54),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (v) => setState(() => amount = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: paymentMethod,
                    items: paymentMethods
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Select payment method",
                      hintStyle: const TextStyle(color: Colors.white54),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    dropdownColor: const Color(0xFF232B3E),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => setState(() => paymentMethod = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Payment Type
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment Type",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: paymentType,
              items: paymentTypes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF232B3E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "Select payment type",
                hintStyle: const TextStyle(color: Colors.white54),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              dropdownColor: const Color(0xFF232B3E),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => paymentType = v),
            ),
            const SizedBox(height: 16),
            // Description
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Description (Optional)",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF232B3E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "Enter payment description",
                hintStyle: const TextStyle(color: Colors.white54),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (v) => setState(() => description = v),
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
                    onPressed: _savePayment,
                    child: const Text("Record Payment"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
