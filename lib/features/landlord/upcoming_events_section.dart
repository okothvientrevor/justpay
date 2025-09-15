import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UpcomingEventsSection extends StatefulWidget {
  const UpcomingEventsSection({Key? key}) : super(key: key);

  @override
  State<UpcomingEventsSection> createState() => _UpcomingEventsSectionState();
}

class _UpcomingEventsSectionState extends State<UpcomingEventsSection> {
  List<Map<String, String>> events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final snap = await FirebaseFirestore.instance
        .collection('tasks')
        .where('completed', isEqualTo: false)
        .get();
    final List<Map<String, String>> upcoming = [];
    for (var doc in snap.docs) {
      final data = doc.data();
      String title = data['description'] ?? 'Task';
      String dateStr = '';
      if (data['dueDate'] != null) {
        final eventDate = DateTime.tryParse(data['dueDate'].toString());
        if (eventDate != null) {
          dateStr = DateFormat('yyyy-MM-dd').format(eventDate);
        }
      } else if (data['createdAt'] is String) {
        final eventDate = DateTime.tryParse(data['createdAt']);
        if (eventDate != null) {
          dateStr = DateFormat('yyyy-MM-dd').format(eventDate);
        }
      } else if (data['createdAt'] is Timestamp) {
        final eventDate = (data['createdAt'] as Timestamp).toDate();
        dateStr = DateFormat('yyyy-MM-dd').format(eventDate);
      }
      upcoming.add({
        'title': title,
        'date': dateStr,
      });
    }
    if (!mounted) return;
    setState(() {
      events = upcoming;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3E).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                color: const Color(0xFF3FE0F6),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Upcoming Events",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (events.isEmpty)
            const Text(
              "No upcoming events.",
              style: TextStyle(color: Colors.white54),
            )
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3FE0F6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event["title"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            event["date"]!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
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
