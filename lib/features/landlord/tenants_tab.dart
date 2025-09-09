import 'package:flutter/material.dart';

class LandlordTenantsTab extends StatefulWidget {
  const LandlordTenantsTab({super.key});

  @override
  State<LandlordTenantsTab> createState() => _LandlordTenantsTabState();
}

class _LandlordTenantsTabState extends State<LandlordTenantsTab> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy tenant data
  final List<Map<String, dynamic>> tenants = [
    {
      "name": "John Doe",
      "photo": null,
      "property": "Apt 3B, Lisa Sass gata 18",
      "leaseStart": "2024-01-01",
      "leaseEnd": "2024-12-31",
      "rent": 1200,
      "paymentStatus": "Paid",
      "contact": "+256 700 111111",
      "email": "john.doe@email.com",
      "emergency": "Jane Doe (+256 700 222222)",
    },
    {
      "name": "Jane Smith",
      "photo": null,
      "property": "Flat 65, Dunbridge House",
      "leaseStart": "2024-03-01",
      "leaseEnd": "2025-02-28",
      "rent": 950,
      "paymentStatus": "Overdue",
      "contact": "+256 700 333333",
      "email": "jane.smith@email.com",
      "emergency": "John Smith (+256 700 444444)",
    },
    // ...add more tenants as needed...
  ];

  String selectedEstate = "All";
  String selectedStatus = "All";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: const Color(0xFF181F2A),
      child: Column(
        children: [
          // Title and search bar (always visible, minimal spacing)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF232B3E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search tenants...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          // Filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedEstate,
                      dropdownColor: const Color(0xFF232B3E),
                      style: const TextStyle(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      isExpanded: true,
                      items: ["All", "Lisa Sass gata 18", "Dunbridge House"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => selectedEstate = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      dropdownColor: const Color(0xFF232B3E),
                      style: const TextStyle(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      isExpanded: true,
                      items: ["All", "Paid", "Overdue"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => selectedStatus = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tenant List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              itemCount: tenants.length,
              itemBuilder: (context, i) {
                final t = tenants[i];
                // Filter logic (simple demo)
                if ((selectedEstate != "All" &&
                        !t["property"].contains(selectedEstate)) ||
                    (selectedStatus != "All" &&
                        t["paymentStatus"] != selectedStatus) ||
                    (_searchController.text.isNotEmpty &&
                        !t["name"].toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        ))) {
                  return const SizedBox.shrink();
                }
                return _TenantCardModern(tenant: t);
              },
            ),
          ),
          // Quick onboarding and communication actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3FE0F6),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.person_add),
                    label: const Text("Onboard Tenant"),
                    onPressed: () {
                      // TODO: Start onboarding workflow
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF232B3E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.message),
                    label: const Text("Message Center"),
                    onPressed: () {
                      // TODO: Open communication center
                    },
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

class _TenantCardModern extends StatelessWidget {
  final Map<String, dynamic> tenant;
  const _TenantCardModern({required this.tenant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3E),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF3FE0F6),
              child: tenant["photo"] == null
                  ? Text(
                      tenant["name"][0],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tenant["name"],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          // TODO: Show tenant actions menu
                        },
                      ),
                    ],
                  ),
                  Text(
                    tenant["property"],
                    style: const TextStyle(
                      color: Color(0xFF3FE0F6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white54,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Lease: ${tenant["leaseStart"]} - ${tenant["leaseEnd"]}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Colors.white54,
                        size: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "Rent: \$${tenant["rent"]}/mo",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _PaymentStatusIndicatorModern(
                        status: tenant["paymentStatus"],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white54, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          tenant["contact"],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.email, color: Colors.white54, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          tenant["email"],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "Emergency: ${tenant["emergency"]}",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _TenantActionButton(
                        icon: Icons.payments,
                        label: "Payment History",
                        onTap: () {},
                      ),
                      _TenantActionButton(
                        icon: Icons.report,
                        label: "Requests",
                        onTap: () {},
                      ),
                      _TenantActionButton(
                        icon: Icons.assignment,
                        label: "Lease",
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentStatusIndicatorModern extends StatelessWidget {
  final String status;
  const _PaymentStatusIndicatorModern({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = status == "Paid"
        ? Colors.green
        : status == "Overdue"
        ? Colors.red
        : Colors.orange;
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TenantActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TenantActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF3FE0F6), size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFB39DDB),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
