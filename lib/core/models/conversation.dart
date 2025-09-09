import 'message.dart';

class Conversation {
  final String id;
  final List<String> participantIds;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;

  Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.unreadCount,
    required this.lastActivity,
  });
}
