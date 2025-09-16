import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PropertyDetailsPage extends StatelessWidget {
  final Map<String, dynamic> property;
  const PropertyDetailsPage({required this.property, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String address = property['address'] ?? '';
    String type = (property['type'] ?? 'apartment').toString().toLowerCase();
    const allowedTypes = ['apartment', 'house', 'commercial'];
    if (!allowedTypes.contains(type)) type = 'apartment';
    String unit = property['unit']?.toString() ?? '';
    String rooms = property['rooms']?.toString() ?? '';
    String sqft = property['sqft']?.toString() ?? '';
    String rent = property['rent']?.toString() ?? '';
    String status = property['status'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          property['address'] ?? 'Property Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF3FE0F6)),
            tooltip: 'Edit Property',
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text(
                      'Edit Property',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: TextEditingController(text: address),
                            decoration: InputDecoration(
                              labelText: 'Address',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => address = v,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: type,
                            dropdownColor: const Color(0xFF1E293B),
                            decoration: InputDecoration(
                              labelText: 'Type',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            items: allowedTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value[0].toUpperCase() + value.substring(1),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => type = v ?? 'apartment',
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: TextEditingController(text: unit),
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => unit = v,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: TextEditingController(text: rooms),
                            decoration: InputDecoration(
                              labelText: 'Rooms',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => rooms = v,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: TextEditingController(text: sqft),
                            decoration: InputDecoration(
                              labelText: 'Size (m²)',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => sqft = v,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: TextEditingController(text: rent),
                            decoration: InputDecoration(
                              labelText: 'Rent',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => rent = v,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: TextEditingController(text: status),
                            decoration: InputDecoration(
                              labelText: 'Status',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => status = v,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3FE0F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final docSnap = await FirebaseFirestore.instance
                              .collection('properties')
                              .where('address', isEqualTo: property['address'])
                              .get();
                          if (docSnap.docs.isNotEmpty) {
                            await docSnap.docs.first.reference.update({
                              'address': address,
                              'type': type,
                              'unit': unit,
                              'rooms': rooms,
                              'sqft': sqft,
                              'rent': rent,
                              'status': status,
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['address'] ?? '',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Type: ${property['type'] ?? ''}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    "Unit: ${property['unit'] ?? ''}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    "Rooms: ${property['rooms'] ?? ''}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    "Size: ${property['sqft'] ?? ''} m²",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    "Rent: UGX ${property['rent'] ?? ''}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Status: ${property['status'] ?? ''}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tenants',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('tenants')
                .where('property', isEqualTo: property['address'])
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: Color(0xFF3FE0F6)),
                );
              final tenants = snapshot.data!.docs;
              if (tenants.isEmpty)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No tenants',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                );
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tenants.length,
                itemBuilder: (context, index) {
                  final data = tenants[index].data() as Map<String, dynamic>;
                  return Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Color(0xFF3FE0F6),
                      ),
                      title: Text(
                        data['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        data['phone'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('payments')
                .where('property', isEqualTo: property['address'])
                .orderBy('createdAt', descending: true)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: Color(0xFF3FE0F6)),
                );
              final payments = snapshot.data!.docs;
              if (payments.isEmpty)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No payments',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                );
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final data = payments[index].data() as Map<String, dynamic>;
                  DateTime? date;
                  if (data['createdAt'] is Timestamp) {
                    date = (data['createdAt'] as Timestamp).toDate();
                  } else if (data['createdAt'] is String) {
                    date = DateTime.tryParse(data['createdAt']);
                  } else {
                    date = null;
                  }
                  final tenantName =
                      data['tenantName'] ?? data['tenant'] ?? 'Unknown';
                  return Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.attach_money,
                        color: Color(0xFF38EF7D),
                      ),
                      title: Text(
                        "UGX ${data['amount'] ?? ''}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tenant: $tenantName',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            date != null
                                ? DateFormat('MMM dd, yyyy').format(date)
                                : '',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        data['paymentType'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
