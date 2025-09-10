import 'package:flutter/material.dart';

class CreateEstateDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onEstateCreated;

  const CreateEstateDialog({super.key, required this.onEstateCreated});

  @override
  State<CreateEstateDialog> createState() => _CreateEstateDialogState();
}

class _CreateEstateDialogState extends State<CreateEstateDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF181F2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              DialogHeader(onClose: () => Navigator.of(context).pop()),

              const SizedBox(height: 6),

              // Description
              const DialogDescription(),

              const SizedBox(height: 18),

              // Form Fields
              EstateNameField(
                onChanged: (value) => setState(() => name = value),
              ),

              const SizedBox(height: 12),

              EstateAddressField(
                onChanged: (value) => setState(() => address = value),
              ),

              const SizedBox(height: 12),

              EstateDescriptionField(
                onChanged: (value) => setState(() => description = value),
              ),

              const SizedBox(height: 18),

              // Action Buttons
              DialogActions(
                onCancel: () => Navigator.of(context).pop(),
                onCreate: () => _createEstate(),
                formKey: _formKey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createEstate() async {
    if (_formKey.currentState!.validate()) {
      final newEstate = {
        "name": name,
        "address": address,
        "desc": description,
        "properties": 0,
        "tenants": 0,
        "active": true,
      };
      await widget.onEstateCreated(newEstate);
      Navigator.of(context).pop();
    }
  }
}

class DialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const DialogHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.apartment, color: Color(0xFF3FE0F6)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            "Create New Estate",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class DialogDescription extends StatelessWidget {
  const DialogDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Fill in the details below to create a new estate for managing properties and tenants.",
      style: TextStyle(color: Colors.white70, fontSize: 13),
    );
  }
}

class EstateNameField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const EstateNameField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Estate Name *",
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF232B3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: "Enter estate name",
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      onChanged: onChanged,
    );
  }
}

class EstateAddressField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const EstateAddressField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Address",
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF232B3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: "Enter estate address",
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
    );
  }
}

class EstateDescriptionField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const EstateDescriptionField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Description",
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF232B3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: "Enter estate description (optional)",
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
    );
  }
}

class DialogActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onCreate;
  final GlobalKey<FormState> formKey;

  const DialogActions({
    super.key,
    required this.onCancel,
    required this.onCreate,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onPressed: onCancel,
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
            onPressed: onCreate,
            child: const Text("Create Estate"),
          ),
        ),
      ],
    );
  }
}
