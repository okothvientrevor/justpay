import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TenantDetailsPage extends StatelessWidget {
  final Map<String, dynamic> tenant;
  const TenantDetailsPage({required this.tenant, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181F2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          tenant['name'] ?? 'Tenant Details',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF3FE0F6)),
            tooltip: 'Edit Tenant',
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  String name = tenant['name'] ?? '';
                  String contact = tenant['contact'] ?? '';
                  String email = tenant['email'] ?? '';
                  String emergency = tenant['emergency'] ?? '';
                  String property = tenant['property'] ?? '';
                  String rent = tenant['rent']?.toString() ?? '';
                  String leaseStart = tenant['leaseStart'] ?? '';
                  String leaseEnd = tenant['leaseEnd'] ?? '';
                  return AlertDialog(
                    backgroundColor: const Color(0xFF232B3E),
                    title: const Text(
                      'Edit Tenant',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: TextEditingController(text: name),
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => name = v,
                          ),
                          TextField(
                            controller: TextEditingController(text: contact),
                            decoration: const InputDecoration(
                              labelText: 'Contact',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => contact = v,
                          ),
                          TextField(
                            controller: TextEditingController(text: email),
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => email = v,
                          ),
                          TextField(
                            controller: TextEditingController(text: emergency),
                            decoration: const InputDecoration(
                              labelText: 'Emergency',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => emergency = v,
                          ),
                          TextField(
                            controller: TextEditingController(text: property),
                            decoration: const InputDecoration(
                              labelText: 'Property',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => property = v,
                          ),
                          TextField(
                            controller: TextEditingController(text: rent),
                            decoration: const InputDecoration(
                              labelText: 'Rent',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => rent = v,
                          ),
                          TextField(
                            controller: TextEditingController(text: leaseStart),
                            decoration: const InputDecoration(
                              labelText: 'Lease Start',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => leaseStart = v,
                          ),
                          TextField(
                            controller: TextEditingController(text: leaseEnd),
                            decoration: const InputDecoration(
                              labelText: 'Lease End',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (v) => leaseEnd = v,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3FE0F6),
                        ),
                        onPressed: () async {
                          final docSnap = await FirebaseFirestore.instance
                              .collection('tenants')
                              .where('name', isEqualTo: tenant['name'])
                              .get();
                          if (docSnap.docs.isNotEmpty) {
                            await docSnap.docs.first.reference.update({
                              'name': name,
                              'contact': contact,
                              'email': email,
                              'emergency': emergency,
                              'property': property,
                              'rent': rent,
                              'leaseStart': leaseStart,
                              'leaseEnd': leaseEnd,
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
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
            color: const Color(0xFF232B3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenant['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact: ${tenant['contact'] ?? ''}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Email: ${tenant['email'] ?? ''}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Emergency: ${tenant['emergency'] ?? ''}',
                    style: const TextStyle(color: Colors.orange),
                  ),
                  Text(
                    'Property: ${tenant['property'] ?? ''}',
                    style: const TextStyle(color: Color(0xFF3FE0F6)),
                  ),
                  Text(
                    'Rent: UGX ${tenant['rent'] ?? ''}/mo',
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                  Text(
                    'Lease: ${tenant['leaseStart'] ?? '-'} - ${tenant['leaseEnd'] ?? '-'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Payment History
          const Text(
            'Payment History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('payments')
                .where('tenant', isEqualTo: tenant['name'])
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              final payments = snapshot.data!.docs;
              if (payments.isEmpty) {
                // Try tenantName field if no results
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('payments')
                      .where('tenantName', isEqualTo: tenant['name'])
                      .get(),
                  builder: (context, snap2) {
                    if (!snap2.hasData)
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      );
                    final payments2 = snap2.data!.docs;
                    if (payments2.isEmpty)
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No payments',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    return Column(
                      children: payments2.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        DateTime? date;
                        if (data['createdAt'] is Timestamp) {
                          date = (data['createdAt'] as Timestamp).toDate();
                        } else if (data['createdAt'] is String) {
                          date = DateTime.tryParse(data['createdAt']);
                        }
                        return Card(
                          color: const Color(0xFF232B3E),
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
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              date != null
                                  ? DateFormat('MMM dd, yyyy').format(date)
                                  : '',
                              style: const TextStyle(color: Colors.white54),
                            ),
                            trailing: Text(
                              data['paymentType'] ?? '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              }
              return Column(
                children: payments.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  DateTime? date;
                  if (data['createdAt'] is Timestamp) {
                    date = (data['createdAt'] as Timestamp).toDate();
                  } else if (data['createdAt'] is String) {
                    date = DateTime.tryParse(data['createdAt']);
                  }
                  return Card(
                    color: const Color(0xFF232B3E),
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
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        date != null
                            ? DateFormat('MMM dd, yyyy').format(date)
                            : '',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: Text(
                        data['paymentType'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          // Maintenance/Requests
          const Text(
            'Requests',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('tasks')
                .where('tenant', isEqualTo: tenant['name'])
                .orderBy('createdAt', descending: true)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              final requests = snapshot.data!.docs;
              if (requests.isEmpty)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No requests',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              return Column(
                children: requests.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  DateTime? date;
                  if (data['createdAt'] is Timestamp) {
                    date = (data['createdAt'] as Timestamp).toDate();
                  } else if (data['createdAt'] is String) {
                    date = DateTime.tryParse(data['createdAt']);
                  }
                  return Card(
                    color: const Color(0xFF232B3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.build,
                        color: Color(0xFF3FE0F6),
                      ),
                      title: Text(
                        data['description'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        date != null
                            ? DateFormat('MMM dd, yyyy').format(date)
                            : '',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: Text(
                        data['status'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          // Contact options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FE0F6),
                ),
                icon: const Icon(Icons.phone, color: Colors.black),
                label: const Text(
                  'Call',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  // TODO: Implement call
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FE0F6),
                ),
                icon: const Icon(Icons.email, color: Colors.black),
                label: const Text(
                  'Email',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  // TODO: Implement email
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
