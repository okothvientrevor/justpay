import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_header.dart';
import 'stats_grid.dart';
import 'quick_actions_grid.dart';
import 'revenue_chart.dart';
import 'upcoming_events_section.dart';
import 'recent_activity_section.dart';
import 'skeletons.dart';

class LandlordHomeTab extends StatefulWidget {
  const LandlordHomeTab({super.key});

  @override
  State<LandlordHomeTab> createState() => _LandlordHomeTabState();
}

class _LandlordHomeTabState extends State<LandlordHomeTab>
    with TickerProviderStateMixin {
  String userName = "";
  double portfolioValue = 0;
  double monthlyRevenue = 0;
  List<double> revenueTrend = [];
  final double occupancyRate = 0.92;
  final int pendingMaintenance = 3;
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
  List<Map<String, String>> events = [];

  bool _loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<String> months = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchPortfolioValue();
    _fetchMonthlyRevenueAndTrend();
    _fetchUpcomingEvents();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
  }

  Future<void> _fetchPortfolioValue() async {
    double total = 0;
    final properties = await FirebaseFirestore.instance
        .collection('properties')
        .get();
    for (var doc in properties.docs) {
      final rent = doc.data()['rent'] ?? 0;
      if (rent is int || rent is double) {
        total += rent.toDouble();
      } else if (rent is String) {
        total += double.tryParse(rent) ?? 0;
      }
    }
    setState(() {
      portfolioValue = total;
    });
  }

  Future<void> _fetchMonthlyRevenueAndTrend() async {
    final now = DateTime.now();
    final paymentsSnap = await FirebaseFirestore.instance
        .collection('payments')
        .get();
    double currentMonthTotal = 0;
    List<double> monthlyTotals = List.filled(7, 0);
    List<String> monthsLabels = [];
    for (int i = 6; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthsLabels.add(DateFormat('MMM').format(month));
      double monthTotal = 0;
      for (var doc in paymentsSnap.docs) {
        final data = doc.data();
        final createdAt = DateTime.tryParse(data['createdAt'] ?? '') ?? now;
        if (createdAt.year == month.year && createdAt.month == month.month) {
          monthTotal += (data['amount'] is num
              ? data['amount'].toDouble()
              : double.tryParse(data['amount'].toString()) ?? 0);
        }
      }
      monthlyTotals[6 - i] = monthTotal;
      if (i == 0) currentMonthTotal = monthTotal;
    }
    setState(() {
      monthlyRevenue = currentMonthTotal;
      revenueTrend = monthlyTotals;
      months = monthsLabels;
    });
  }

  Future<void> _fetchUpcomingEvents() async {
    final now = DateTime.now();
    final snap = await FirebaseFirestore.instance.collection('tasks').get();
    final List<Map<String, String>> upcoming = [];
    for (var doc in snap.docs) {
      final data = doc.data();
      DateTime? eventDate;
      if (data['dueDate'] != null) {
        eventDate = DateTime.tryParse(data['dueDate'].toString());
      } else if (data['createdAt'] is String) {
        eventDate = DateTime.tryParse(data['createdAt']);
      } else if (data['createdAt'] is Timestamp) {
        eventDate = (data['createdAt'] as Timestamp).toDate();
      }
      if (eventDate != null && eventDate.isAfter(now)) {
        upcoming.add({
          'title': data['description'] ?? 'Task',
          'date': DateFormat('yyyy-MM-dd').format(eventDate),
        });
      }
    }
    setState(() {
      events = upcoming;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1F2E), Color(0xFF0F1419)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF3FE0F6),
          backgroundColor: const Color(0xFF232B3E),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 99, // Reduced height
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A1F2E), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        8,
                      ), // Less top padding
                      child: WelcomeHeader(),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _loading
                                ? const StatsSkeleton()
                                : StatsGrid(
                                    portfolioValue: portfolioValue,
                                    monthlyRevenue: monthlyRevenue,
                                    occupancyRate: occupancyRate,
                                    pendingMaintenance: pendingMaintenance,
                                  ),
                            const SizedBox(height: 24),
                            QuickActionsGrid(),
                            const SizedBox(height: 24),
                            SectionHeader(
                              title: "Revenue Trend",
                              icon: Icons.trending_up,
                            ),
                            const SizedBox(height: 12),
                            _loading
                                ? const GraphSkeleton()
                                : RevenueChart(
                                    data: revenueTrend,
                                    labels: months,
                                  ),
                            const SizedBox(height: 24),
                            UpcomingEventsSection(),
                            const SizedBox(height: 16),
                            RecentActivitySection(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
