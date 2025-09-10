import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_invoice_page.dart';
import 'create_property_page.dart';
import 'onboard_tenant_page.dart';

class EstateDetailsPage extends StatefulWidget {
  final Map<String, dynamic> estate;
  const EstateDetailsPage({required this.estate, Key? key}) : super(key: key);

  @override
  State<EstateDetailsPage> createState() => _EstateDetailsPageState();
}

class _EstateDetailsPageState extends State<EstateDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>>? _properties;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeController.forward();
    _slideController.forward();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    final propertiesSnap = await FirebaseFirestore.instance
        .collection('properties')
        .where('estate', isEqualTo: widget.estate['name'])
        .get();
    setState(() {
      _properties = propertiesSnap.docs.map((doc) => doc.data()).toList();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        body: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [Color(0xFF1A2332), Color(0xFF0A0E1A)],
                ),
              ),
            ),
            // Floating orbs for visual interest
            Positioned(
              top: 100,
              right: -50,
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
            // Main Content
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 380,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        color: const Color(0xFF181F2A),
                        onSelected: (value) {
                          if (value == 'invoice') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CreateInvoicePage(
                                  estate: widget.estate['name'],
                                ),
                              ),
                            );
                          } else if (value == 'property') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreatePropertyPage(),
                              ),
                            );
                          } else if (value == 'tenant') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OnboardTenantPage(),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'invoice',
                            child: Text(
                              'Create Invoice',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'property',
                            child: Text(
                              'Add Property',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'tenant',
                            child: Text(
                              'Add Tenant',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: EstateHeader(estate: widget.estate),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarHeaderDelegate(
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const ModernTabBar(),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            children: [
                              VacantPropertiesTab(
                                estate: widget.estate,
                                properties: _properties ?? [],
                              ),
                              ExpiringLeasesTab(
                                estate: widget.estate,
                                properties: _properties ?? [],
                              ),
                              MaintenanceAlertsTab(
                                estate: widget.estate,
                                properties: _properties ?? [],
                              ),
                              PropertiesTab(
                                estate: widget.estate,
                                properties: _properties ?? [],
                              ),
                            ],
                          ),
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

class EstateHeader extends StatelessWidget {
  final Map<String, dynamic> estate;
  const EstateHeader({super.key, required this.estate});

  Future<Map<String, dynamic>> _fetchEstateStats() async {
    final propertiesSnap = await FirebaseFirestore.instance
        .collection('properties')
        .where('estate', isEqualTo: estate['name'])
        .get();
    final properties = propertiesSnap.docs.map((doc) => doc.data()).toList();
    final totalProperties = properties.length;
    final occupied = properties.where((p) {
      final tenants = p['tenants'];
      if (tenants is int) {
        return tenants > 0;
      } else if (tenants is List) {
        return tenants.isNotEmpty;
      } else {
        return false;
      }
    }).length;
    final monthlyRevenue = properties.fold<int>(
      0,
      (sum, p) => sum + (p['rent'] as int? ?? 0),
    );
    final occupancyRate = totalProperties > 0
        ? occupied / totalProperties
        : 0.0;
    return {
      'totalProperties': totalProperties,
      'occupied': occupied,
      'monthlyRevenue': monthlyRevenue,
      'occupancyRate': occupancyRate,
      'properties': properties,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchEstateStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final totalProperties = stats?['totalProperties'] ?? 0;
        final occupied = stats?['occupied'] ?? 0;
        final monthlyRevenue = stats?['monthlyRevenue'] ?? 0;
        final occupancyRate = stats?['occupancyRate'] ?? 0.0;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estate Name with gradient text
              Row(
                children: [
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF3FE0F6), Color(0xFF1DE9B6)],
                      ).createShader(bounds),
                      child: Text(
                        estate['name'] ?? 'Estate Name',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 8),
              // Location with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3FE0F6).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFF3FE0F6),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      estate['address'] ?? estate['location'] ?? 'No address',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.4,
                children: [
                  ModernStatCard(
                    label: 'Total Properties',
                    value: totalProperties.toString(),
                    icon: Icons.apartment,
                    gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  ModernStatCard(
                    label: 'Occupied',
                    value: occupied.toString(),
                    icon: Icons.home,
                    gradient: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                  ),
                  ModernStatCard(
                    label: 'Occupancy Rate',
                    value: '${(occupancyRate * 100).toStringAsFixed(0)}%',
                    icon: Icons.pie_chart,
                    gradient: const [Color(0xFFf093fb), Color(0xFFf5576c)],
                  ),
                  ModernStatCard(
                    label: 'Monthly Revenue',
                    value: 'UGX${_formatNumber(monthlyRevenue.toString())}',
                    icon: Icons.payments,
                    gradient: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
                  ),
                ],
              ),
              const SizedBox(height: 8), // reduced space after stats grid
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(String number) {
    final numValue = int.tryParse(number) ?? 0;
    if (numValue >= 1000000) {
      final millions = numValue / 1000000;
      return millions % 1 == 0
          ? '${millions.toStringAsFixed(0)}M'
          : '${millions.toStringAsFixed(1)}M';
    } else if (numValue >= 1000) {
      final thousands = numValue / 1000;
      return thousands % 1 == 0
          ? '${thousands.toStringAsFixed(0)}K'
          : '${thousands.toStringAsFixed(1)}K';
    }
    return number;
  }
}

class ModernStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const ModernStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient.map((color) => color.withOpacity(0.8)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ModernTabBar extends StatelessWidget {
  const ModernTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF3FE0F6), Color(0xFF1DE9B6)],
        ),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      tabs: const [
        Tab(text: 'Vacant'),
        Tab(text: 'Expiring'),
        Tab(text: 'Maintenance'),
        Tab(text: 'Properties'),
      ],
    );
  }
}

// Tab Content Widgets
class VacantPropertiesTab extends StatelessWidget {
  final Map<String, dynamic> estate;
  final List<Map<String, dynamic>> properties;
  const VacantPropertiesTab({
    super.key,
    required this.estate,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final vacantProperties = properties.where((p) {
      final tenants = p['tenants'];
      if (tenants is int) {
        return tenants == 0;
      } else if (tenants is List) {
        return tenants.isEmpty;
      } else {
        return false;
      }
    }).toList();

    if (vacantProperties.isEmpty) {
      return _buildEmptyState(
        icon: Icons.home_outlined,
        title: 'No Vacant Properties',
        subtitle: 'All properties in ${estate['name']} are currently occupied',
        color: const Color(0xFF00C853),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: vacantProperties.length,
      itemBuilder: (context, i) {
        final p = vacantProperties[i];
        return Card(
          color: const Color(0xFF181F2A),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(
              p['address'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'UGX${p['rent'] ?? 0} • ${p['rooms'] ?? 0} rooms',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }
}

class ExpiringLeasesTab extends StatelessWidget {
  final Map<String, dynamic> estate;
  final List<Map<String, dynamic>> properties;
  const ExpiringLeasesTab({
    super.key,
    required this.estate,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final expiringLeases = properties.where((p) {
      final leaseEndDate = p['leaseEndDate'] as Timestamp?;
      if (leaseEndDate == null) return false;
      final now = DateTime.now();
      final difference = leaseEndDate.toDate().difference(now);
      return difference.inDays <= 30 && difference.inDays >= 0;
    }).toList();

    if (expiringLeases.isEmpty) {
      return _buildEmptyState(
        icon: Icons.schedule,
        title: 'No Expiring Leases',
        subtitle: 'All leases are current with no immediate expirations',
        color: const Color(0xFF3FE0F6),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: expiringLeases.length,
      itemBuilder: (context, i) {
        final p = expiringLeases[i];
        return Card(
          color: const Color(0xFF181F2A),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(
              p['address'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'UGX${p['rent'] ?? 0} • ${p['rooms'] ?? 0} rooms',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }
}

class MaintenanceAlertsTab extends StatelessWidget {
  final Map<String, dynamic> estate;
  final List<Map<String, dynamic>> properties;
  const MaintenanceAlertsTab({
    super.key,
    required this.estate,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final maintenanceAlerts = properties.where((p) {
      final maintenanceNeeded = p['maintenanceNeeded'] as bool?;
      return maintenanceNeeded == true;
    }).toList();

    if (maintenanceAlerts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.build,
        title: 'No Maintenance Alerts',
        subtitle: 'All systems are running smoothly',
        color: const Color(0xFF1DE9B6),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: maintenanceAlerts.length,
      itemBuilder: (context, i) {
        final p = maintenanceAlerts[i];
        return Card(
          color: const Color(0xFF181F2A),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(
              p['address'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'UGX${p['rent'] ?? 0} • ${p['rooms'] ?? 0} rooms',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }
}

class PropertiesTab extends StatelessWidget {
  final Map<String, dynamic> estate;
  final List<Map<String, dynamic>> properties;
  const PropertiesTab({
    super.key,
    required this.estate,
    required this.properties,
  });

  bool _isOccupied(dynamic tenants) {
    if (tenants is int) {
      return tenants > 0;
    } else if (tenants is List) {
      return tenants.isNotEmpty;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return _buildEmptyState(
        icon: Icons.apartment,
        title: 'Properties Overview',
        subtitle: 'Manage all properties in ${estate['name']}',
        color: const Color(0xFF8E24AA),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: properties.length,
      itemBuilder: (context, i) {
        final p = properties[i];
        final occupied = _isOccupied(p['tenants']);
        return Card(
          color: const Color(0xFF181F2A),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(
              p['address'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'UGX${p['rent'] ?? 0} • ${p['rooms'] ?? 0} rooms',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Text(
              occupied ? 'Occupied' : 'Vacant',
              style: TextStyle(color: occupied ? Colors.green : Colors.orange),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildEmptyState({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: const Color(0xFF1A2332).withOpacity(0.5),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: color),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    ),
  );
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabBarHeaderDelegate({required this.child});

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
