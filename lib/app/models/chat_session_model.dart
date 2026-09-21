enum MessageRole { user, assistant }

class ChatMessageAction {
  final String type; // 'create_plan', etc.
  final Map<String, dynamic> data;
  bool isDone;

  ChatMessageAction({
    required this.type,
    required this.data,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        'isDone': isDone,
      };

  factory ChatMessageAction.fromJson(Map<String, dynamic> json) =>
      ChatMessageAction(
        type: json['type'] as String? ?? '',
        data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
        isDone: json['isDone'] as bool? ?? false,
      );
}

class ChatMessage {
  final String id;
  final String text;
  final MessageRole role;
  final DateTime time;
  final bool isLoading;
  ChatMessageAction? action;

  ChatMessage({
    String? id,
    required this.text,
    required this.role,
    DateTime? time,
    this.isLoading = false,
    this.action,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        time = time ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'role': role.name,
        'time': time.toIso8601String(),
        'action': action?.toJson(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String?,
        text: json['text'] as String? ?? '',
        role: (json['role'] as String? ?? 'assistant') == 'user'
            ? MessageRole.user
            : MessageRole.assistant,
        time: json['time'] != null
            ? DateTime.tryParse(json['time'] as String) ?? DateTime.now()
            : DateTime.now(),
        action: json['action'] != null
            ? ChatMessageAction.fromJson(
                Map<String, dynamic>.from(json['action'] as Map))
            : null,
      );
}

class ChatSessionModel {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  dynamic patientId;
  String? patientName;
  List<ChatMessage> messages;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.patientId,
    this.patientName,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'patientId': patientId,
        'patientName': patientName,
        'messages': messages
            .where((m) => !m.isLoading && m.text.isNotEmpty)
            .map((m) => m.toJson())
            .toList(),
      };

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      ChatSessionModel(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Discussion',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        patientId: json['patientId'],
        patientName: json['patientName'] as String?,
        messages: (json['messages'] as List<dynamic>? ?? [])
            .map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList(),
      );

  String get previewText {
    if (messages.isEmpty) return 'Aucun message';
    final last = messages.lastWhere((m) => m.text.isNotEmpty, orElse: () => messages.last);
    return last.text.replaceAll(RegExp(r'\n+'), ' ').trim();
  }
}
