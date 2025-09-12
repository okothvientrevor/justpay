import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'invoice_widgets/modern_app_bar.dart';
import 'invoice_widgets/invoice_header.dart';
import 'invoice_widgets/invoice_form.dart';
import 'invoice_widgets/invoice_actions.dart';
import 'invoice_pdf_preview_page.dart';

class CreateInvoicePage extends StatefulWidget {
  final String? estate;
  const CreateInvoicePage({Key? key, this.estate}) : super(key: key);

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage>
    with TickerProviderStateMixin {
  String? selectedProperty;
  String? selectedTenant;
  String? invoiceType;
  int amount = 0;
  DateTime? dueDate;
  String description = '';
  List<String> propertyOptions = [];
  List<String> tenantOptions = [];
  bool loading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadPropertiesAndTenants();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      initialDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3FE0F6),
              onPrimary: Colors.black,
              surface: Color(0xFF232B3E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => dueDate = picked);
  }

  Future<void> _createInvoice() async {
    if (selectedTenant == null ||
        invoiceType == null ||
        amount <= 0 ||
        dueDate == null) {
      _showErrorSnackbar('Please fill in all required fields');
      return;
    }

    setState(() => loading = true);
    try {
      final invoice = {
        'estate': widget.estate,
        'property': selectedProperty,
        'tenant': selectedTenant,
        'invoiceType': invoiceType,
        'amount': amount,
        'dueDate': dueDate?.toIso8601String(),
        'description': description,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await FirebaseFirestore.instance.collection('invoices').add(invoice);
      setState(() => loading = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InvoicePdfPreviewPage(invoice: invoice),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Failed to create invoice. Please try again.');
      setState(() => loading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [Color(0xFF1A2332), Color(0xFF0A0E1A)],
              ),
            ),
          ),
          // Floating orbs
          Positioned(
            top: -50,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3FE0F6).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const ModernAppBar(),
                ),
                // Main Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Column(
                              children: [
                                const InvoiceHeader(),
                                const SizedBox(height: 30),
                                InvoiceForm(
                                  estate: widget.estate,
                                  selectedTenant: selectedTenant,
                                  selectedProperty: selectedProperty,
                                  invoiceType: invoiceType,
                                  amount: amount,
                                  dueDate: dueDate,
                                  description: description,
                                  propertyOptions: propertyOptions,
                                  tenantOptions: tenantOptions,
                                  onTenantChanged: (value) =>
                                      setState(() => selectedTenant = value),
                                  onPropertyChanged: (value) =>
                                      setState(() => selectedProperty = value),
                                  onInvoiceTypeChanged: (value) =>
                                      setState(() => invoiceType = value),
                                  onAmountChanged: (value) => setState(
                                    () => amount = int.tryParse(value) ?? 0,
                                  ),
                                  onDescriptionChanged: (value) =>
                                      setState(() => description = value),
                                  onDatePicker: _pickDueDate,
                                ),
                                const SizedBox(height: 30),
                                InvoiceActions(
                                  loading: loading,
                                  amount: amount,
                                  onCancel: () => Navigator.of(context).pop(),
                                  onCreate: _createInvoice,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
