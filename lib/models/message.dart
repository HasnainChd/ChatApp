import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  String? senderID;
  String? content;
  MessageType? messageType;
  Timestamp? sentAt;

  Message({
    required this.senderID,
    required this.content,
    required this.messageType,
    required this.sentAt,
  });

  // From JSON constructor
  Message.fromJson(Map<String, dynamic> json) {
    senderID = json['senderID'] ?? 'Unknown Sender'; // Handle null
    content = json['content'] ?? ' '; // Handle null
    sentAt = json['sentAt'] ?? Timestamp.now(); // Handle null, default to now
    messageType = json['messageType'] != null
        ? MessageType.values.byName(json['messageType'])
        : MessageType.Text; // Default to Text if null
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'senderID': senderID,
      'content': content,
      'sentAt': sentAt,
      'messageType': messageType?.name,
    };
  }
}
