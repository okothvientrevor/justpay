import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecentActivitiesPage extends StatelessWidget {
  const RecentActivitiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181F2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Recent Activities',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recent_activities')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final activities = snapshot.data!.docs;
          if (activities.isEmpty) {
            return const Center(
              child: Text(
                'No recent activities.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: activities.length,
            itemBuilder: (context, i) {
              final data = activities[i].data() as Map<String, dynamic>;
              return Card(
                color: const Color(0xFF232B3E).withOpacity(0.7),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(
                    _getActivityIcon(data['type']),
                    color: _getActivityColor(data['type']),
                  ),
                  title: Text(
                    data['desc'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _formatTime(data['time']),
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case "payment":
        return const Color(0xFF38EF7D);
      case "maintenance":
        return const Color(0xFFFFE66D);
      case "inquiry":
        return const Color(0xFF3FE0F6);
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case "payment":
        return Icons.attach_money;
      case "maintenance":
        return Icons.build;
      case "inquiry":
        return Icons.question_answer;
      default:
        return Icons.info;
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    final dt = DateTime.tryParse(isoTime);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else {
      return dt.toLocal().toString().split(' ')[0];
    }
  }
}
