import 'dart:ui';

import 'package:flutter/material.dart';

class InvoiceForm extends StatelessWidget {
  final String? estate;
  final String? selectedTenant;
  final String? selectedProperty;
  final String? invoiceType;
  final int amount;
  final DateTime? dueDate;
  final String description;
  final List<String> propertyOptions;
  final List<String> tenantOptions;
  final ValueChanged<String?> onTenantChanged;
  final ValueChanged<String?> onPropertyChanged;
  final ValueChanged<String?> onInvoiceTypeChanged;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onDatePicker;

  const InvoiceForm({
    super.key,
    this.estate,
    this.selectedTenant,
    this.selectedProperty,
    this.invoiceType,
    required this.amount,
    this.dueDate,
    required this.description,
    required this.propertyOptions,
    required this.tenantOptions,
    required this.onTenantChanged,
    required this.onPropertyChanged,
    required this.onInvoiceTypeChanged,
    required this.onAmountChanged,
    required this.onDescriptionChanged,
    required this.onDatePicker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invoice Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ModernDropdownField(
                label: 'Estate',
                value: estate,
                items: estate != null ? [estate!] : [],
                onChanged: null,
                icon: Icons.apartment,
                enabled: false,
              ),
              const SizedBox(height: 16),
              ModernDropdownField(
                label: 'Tenant *',
                value: selectedTenant,
                items: tenantOptions,
                onChanged: onTenantChanged,
                icon: Icons.person,
                hint: 'Select tenant',
              ),
              const SizedBox(height: 16),
              ModernDropdownField(
                label: 'Property (Optional)',
                value: selectedProperty,
                items: propertyOptions,
                onChanged: onPropertyChanged,
                icon: Icons.home,
                hint: 'Select property',
              ),
              const SizedBox(height: 16),
              ModernDropdownField(
                label: 'Invoice Type *',
                value: invoiceType,
                items: const [
                  'Rent',
                  'Deposit',
                  'Utilities',
                  'Maintenance',
                  'Other',
                ],
                onChanged: onInvoiceTypeChanged,
                icon: Icons.category,
                hint: 'Select invoice type',
              ),
              const SizedBox(height: 16),
              ModernTextField(
                label: 'Amount (UGX) *',
                keyboardType: TextInputType.number,
                onChanged: onAmountChanged,
                icon: Icons.payments,
                hint: 'Enter amount',
              ),
              const SizedBox(height: 16),
              ModernDateField(
                label: 'Due Date *',
                date: dueDate,
                onTap: onDatePicker,
              ),
              if (amount > 0) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3FE0F6).withOpacity(0.2),
                        const Color(0xFF1DE9B6).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        'UGX ${_formatAmount(amount)}',
                        style: const TextStyle(
                          color: Color(0xFF3FE0F6),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ModernTextField(
                label: 'Description (Optional)',
                maxLines: 3,
                onChanged: onDescriptionChanged,
                icon: Icons.description,
                hint: 'Enter invoice description...',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class ModernDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final IconData icon;
  final String? hint;
  final bool enabled;

  const ModernDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
    required this.icon,
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232B3E).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF3FE0F6), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
            ),
            dropdownColor: const Color(0xFF232B3E),
            style: const TextStyle(color: Colors.white),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          ),
        ),
      ],
    );
  }
}

class ModernTextField extends StatelessWidget {
  final String label;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final String? hint;
  final int maxLines;

  const ModernTextField({
    super.key,
    required this.label,
    this.keyboardType,
    required this.onChanged,
    required this.icon,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232B3E).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextFormField(
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF3FE0F6), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class ModernDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const ModernDateField({
    super.key,
    required this.label,
    this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF232B3E).withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF3FE0F6),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  date != null
                      ? "${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}"
                      : 'Select due date',
                  style: TextStyle(
                    color: date != null ? Colors.white : Colors.white54,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
