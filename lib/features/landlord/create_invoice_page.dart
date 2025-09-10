import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateInvoicePage extends StatefulWidget {
  final String? estate;
  const CreateInvoicePage({Key? key, this.estate}) : super(key: key);

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  String? selectedProperty;
  String? selectedTenant;
  String? invoiceType;
  int amount = 0;
  DateTime? dueDate;
  String description = '';
  List<String> propertyOptions = [];
  List<String> tenantOptions = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadPropertiesAndTenants();
  }

  Future<void> _loadPropertiesAndTenants() async {
    if (widget.estate == null) return;
    final propertiesSnap = await FirebaseFirestore.instance
        .collection('properties')
        .where('estate', isEqualTo: widget.estate)
        .get();
    final tenantsSnap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('estate', isEqualTo: widget.estate)
        .get();
    setState(() {
      propertyOptions = propertiesSnap.docs
          .map((doc) => doc.data()['address'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      tenantOptions = tenantsSnap.docs
          .map((doc) => doc.data()['name'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => dueDate = picked);
  }

  Future<void> _createInvoice() async {
    if (selectedTenant == null ||
        invoiceType == null ||
        amount <= 0 ||
        dueDate == null)
      return;
    setState(() => loading = true);
    final invoice = {
      'estate': widget.estate,
      'property': selectedProperty,
      'tenant': selectedTenant,
      'invoiceType': invoiceType,
      'amount': amount,
      'dueDate': dueDate?.toIso8601String(),
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('invoices').add(invoice);
    setState(() => loading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tenant Invoice'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generate a professional invoice with payment link, QR code, and sharing options for tenant payments.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: widget.estate,
                  items: [
                    if (widget.estate != null)
                      DropdownMenuItem(
                        value: widget.estate,
                        child: Text(widget.estate!),
                      ),
                  ],
                  onChanged: null,
                  decoration: InputDecoration(
                    labelText: 'Select Estate',
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
                  value: selectedTenant,
                  items: tenantOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedTenant = v),
                  decoration: InputDecoration(
                    labelText: 'Select Tenant',
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
                  value: selectedProperty,
                  items: propertyOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedProperty = v),
                  decoration: InputDecoration(
                    labelText: 'Select Property (optional)',
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: invoiceType,
                        items: ['Rent', 'Deposit', 'Other']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => invoiceType = v),
                        decoration: InputDecoration(
                          labelText: 'Invoice Type',
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Amount (UGX)',
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
                        onChanged: (v) => amount = int.tryParse(v) ?? 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDueDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: Text(
                      dueDate != null
                          ? "${dueDate!.day.toString().padLeft(2, '0')}/${dueDate!.month.toString().padLeft(2, '0')}/${dueDate!.year}"
                          : 'dd/mm/yyyy',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'USh ${amount > 0 ? amount : 0}',
                    style: const TextStyle(
                      color: Color(0xFF3FE0F6),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF232B3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    hintText:
                        'Enter invoice description (e.g., Monthly rent for January 2024)',
                    hintStyle: const TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  onChanged: (v) => description = v,
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
                        onPressed: loading ? null : _createInvoice,
                        child: loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Create Invoice & Payment Link"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
