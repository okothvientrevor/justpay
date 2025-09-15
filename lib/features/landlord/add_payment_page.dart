import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({Key? key}) : super(key: key);

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  String? selectedTenant;
  String? selectedProperty;
  String? paymentMethod;
  String? amount;
  String? description;

  final List<String> tenants = ["John Doe", "Jane Smith"];
  final List<String> properties = ["Lisa Sass gata 18", "Dunbridge House"];
  final List<String> paymentMethods = ["Cash", "Bank Transfer", "Mobile Money"];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (selectedTenant == null ||
        selectedProperty == null ||
        amount == null ||
        amount!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await FirebaseFirestore.instance.collection('payments').add({
      'tenant': selectedTenant,
      'property': selectedProperty,
      'paymentMethod': paymentMethod,
      'amount': double.tryParse(amount ?? '') ?? 0,
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
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
