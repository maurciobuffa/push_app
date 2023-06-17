class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final DateTime sentDate;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  PushMessage({
    required this.messageId,
    required this.title,
    required this.body,
    required this.sentDate,
    this.data,
    this.imageUrl,
  });

  @override
  String toString() {
    return '''
  Push Message -
  id: $messageId
  Title: $title
  Body: $body
  Send Date: $sentDate
  Data: $data
  Image URL: $imageUrl
''';
  }
}
