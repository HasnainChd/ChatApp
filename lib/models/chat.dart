import 'message.dart';

class Chat {
  String? id;
  List<String>? participants;
  List<Message>? messages;

  Chat({
    required this.id,
    required this.participants,
    required this.messages,
  });

  // From JSON constructor
  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 'Unknown Chat ID'; // Handle null
    participants = List<String>.from(json['participants'] ?? []); // Handle null
    messages = (json['messages'] as List<dynamic>?)
        ?.map((m) => Message.fromJson(m as Map<String, dynamic>))
        .toList() ?? []; // Handle null
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'messages': messages?.map((m) => m.toJson()).toList(),
    };
  }
}
