enum MessageSenderType { landlord, school, tenant, parent, student, admin }

enum MessageReceiverType { landlord, school, tenant, parent, student, admin }

class MessageAttachment {
  // Define attachment fields here
  // ...add fields as needed...
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final MessageSenderType senderType;
  final MessageReceiverType receiverType;
  final String subject;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  final List<MessageAttachment>? attachments;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderType,
    required this.receiverType,
    required this.subject,
    required this.content,
    required this.createdAt,
    this.readAt,
    this.attachments,
  });
}
