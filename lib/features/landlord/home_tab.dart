import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class LandlordHomeTab extends StatefulWidget {
  const LandlordHomeTab({super.key});

  @override
  State<LandlordHomeTab> createState() => _LandlordHomeTabState();
}

class _LandlordHomeTabState extends State<LandlordHomeTab> {
  final String userName = "Farouk Mwanje";
  final double portfolioValue = 1200000;
  final double monthlyRevenue = 18500;
  final double occupancyRate = 0.92;
  final int pendingMaintenance = 3;
  final List<double> revenueTrend = [
    12000,
    13500,
    15000,
    17000,
    18500,
    20000,
    21000,
  ];
  final List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"];
  final String weather = "Sunny";
  final int temperature = 27;
  final List<Map<String, String>> recentActivity = [
    {
      "type": "payment",
      "desc": "Tenant John Doe paid \$1,200 rent",
      "time": "2h ago",
    },
    {
      "type": "maintenance",
      "desc": "New maintenance request for AC repair",
      "time": "5h ago",
    },
    {
      "type": "inquiry",
      "desc": "New inquiry from Jane Smith",
      "time": "1d ago",
    },
  ];
  final List<Map<String, String>> events = [
    {"title": "Lease Renewal - Apt 3B", "date": "2024-07-10"},
    {"title": "Property Inspection", "date": "2024-07-12"},
  ];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    // TODO: Refresh data from backend
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _WelcomeHeader(),
          const SizedBox(height: 18),
          _loading ? const _StatsSkeleton() : const _StatsRow(),
          const SizedBox(height: 8),
          _loading ? const _StatsSkeleton() : const _StatsRow2(),
          const SizedBox(height: 14),
          _QuickActionsRow(
            onCreateInvoice: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateInvoicePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _loading
              ? const _GraphSkeleton()
              : _RevenueLineChart(data: revenueTrend, labels: months),
          const SizedBox(height: 16),
          const _UpcomingEventsSection(),
          const SizedBox(height: 16),
          const _RecentActivitySection(),
        ],
      ),
    );
  }
}

// --- WIDGETS SPLIT OUT BELOW ---

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final String userName = "Farouk Mwanje";
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF3FE0F6),
          child: Text(
            userName[0],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, $userName",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DateFormat(
                  'EEEE, MMM d, yyyy – hh:mm a',
                ).format(DateTime.now()),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        2,
        (i) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == 0 ? 12 : 0),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final double portfolioValue = 1200000;
    final double monthlyRevenue = 18500;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet,
            label: "Portfolio Value",
            value: "\$${portfolioValue.toStringAsFixed(0)}",
            color: const Color(0xFF3B5AFE),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up,
            label: "Monthly Revenue",
            value: "\$${monthlyRevenue.toStringAsFixed(0)}",
            color: const Color(0xFF00C853),
          ),
        ),
      ],
    );
  }
}

class _StatsRow2 extends StatelessWidget {
  const _StatsRow2();

  @override
  Widget build(BuildContext context) {
    final double occupancyRate = 0.92;
    final int pendingMaintenance = 3;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.pie_chart,
            label: "Occupancy",
            value: "${(occupancyRate * 100).toStringAsFixed(0)}%",
            color: const Color(0xFF8E24AA),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.build,
            label: "Pending Maint.",
            value: "$pendingMaintenance",
            color: const Color(0xFFFFB300),
          ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onCreateInvoice;
  const _QuickActionsRow({required this.onCreateInvoice});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: _QuickActionButton(
            icon: Icons.receipt_long,
            label: "Create Invoice",
            onTap: onCreateInvoice,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _QuickActionButton(
            icon: Icons.build,
            label: "Add Maintenance",
            onTap: () {},
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _QuickActionButton(
            icon: Icons.bar_chart,
            label: "View Reports",
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _GraphSkeleton extends StatelessWidget {
  const _GraphSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _UpcomingEventsSection extends StatelessWidget {
  const _UpcomingEventsSection();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> events = [
      {"title": "Lease Renewal - Apt 3B", "date": "2024-07-10"},
      {"title": "Property Inspection", "date": "2024-07-12"},
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Events",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ...events.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Color(0xFF3FE0F6), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      e["title"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    e["date"]!,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> recentActivity = [
      {
        "type": "payment",
        "desc": "Tenant John Doe paid \$1,200 rent",
        "time": "2h ago",
      },
      {
        "type": "maintenance",
        "desc": "New maintenance request for AC repair",
        "time": "5h ago",
      },
      {
        "type": "inquiry",
        "desc": "New inquiry from Jane Smith",
        "time": "1d ago",
      },
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ...recentActivity.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    a["type"] == "payment"
                        ? Icons.attach_money
                        : a["type"] == "maintenance"
                        ? Icons.build
                        : Icons.info,
                    color: const Color(0xFF3FE0F6),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      a["desc"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    a["time"]!,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RevenueLineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const _RevenueLineChart({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final chartHeight = 50.0;
    final chartWidth = MediaQuery.of(context).size.width - 56; // padding + card

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: chartHeight,
          width: chartWidth,
          child: CustomPaint(
            painter: _LineChartPainter(data, maxVal, minVal, chartHeight),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            labels.length,
            (i) => Expanded(
              child: Text(
                labels[i],
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxVal;
  final double minVal;
  final double height;

  _LineChartPainter(this.data, this.maxVal, this.minVal, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3FE0F6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFF3FE0F6)
      ..style = PaintingStyle.fill;

    final n = data.length;
    if (n < 2) return;

    final dx = size.width / (n - 1);
    final points = <Offset>[];

    for (int i = 0; i < n; i++) {
      final x = i * dx;
      final y =
          height -
          ((data[i] - minVal) / (maxVal - minVal + 1) * (height - 10)) -
          5;
      points.add(Offset(x, y));
    }

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw points
    for (final p in points) {
      canvas.drawCircle(p, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF232B3E),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      icon: Icon(icon, color: const Color(0xFF3FE0F6)),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({Key? key}) : super(key: key);

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  String? selectedEstate;
  String? selectedTenant;
  String? invoiceType;
  String? dueDate;
  String? amount;
  String? description;

  final List<String> estates = ["Lisa Sass gata 18", "Dunbridge House"];
  final List<String> tenants = ["John Doe", "Jane Smith"];
  final List<String> invoiceTypes = [
    "Monthly Rent",
    "Deposit",
    "Utility Bill",
    "Other",
  ];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
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
          "Create Tenant Invoice",
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
              "Generate a professional invoice with payment link, QR code, and sharing options for tenant payments.",
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
              onChanged: (v) => setState(() => selectedEstate = v),
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
            const SizedBox(height: 18),
            // Invoice Details
            Row(
              children: [
                const Icon(Icons.info, color: Color(0xFF3FE0F6)),
                const SizedBox(width: 8),
                const Text(
                  "Invoice Details",
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
                  child: DropdownButtonFormField<String>(
                    value: invoiceType,
                    items: invoiceTypes
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
                      hintText: "Select invoice type",
                      hintStyle: const TextStyle(color: Colors.white54),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    dropdownColor: const Color(0xFF232B3E),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => setState(() => invoiceType = v),
                  ),
                ),
                const SizedBox(width: 12),
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
                  child: TextFormField(
                    controller: _dateController,
                    style: const TextStyle(color: Colors.white),
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF232B3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "dd/mm/yyyy",
                      hintStyle: const TextStyle(color: Colors.white54),
                      labelText: "Due Date",
                      labelStyle: const TextStyle(color: Colors.white54),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 1),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        _dateController.text = DateFormat(
                          'dd/MM/yyyy',
                        ).format(picked);
                        setState(() => dueDate = _dateController.text);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181F2A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF3FE0F6),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    "USh ${amount ?? "0"}",
                    style: const TextStyle(
                      color: Color(0xFF3FE0F6),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
                hintText:
                    "Enter invoice description (e.g., Monthly rent for January 2024)",
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
                    onPressed: () {
                      // TODO: Create invoice and payment link
                      Navigator.of(context).pop();
                    },
                    child: const Text("Create Invoice & Payment Link"),
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
