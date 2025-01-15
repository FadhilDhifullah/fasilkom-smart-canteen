class NotificationModel {
  final String title;
  final String body;
  final String timestamp;

  NotificationModel({
    required this.title,
    required this.body,
    required this.timestamp,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data) {
    return NotificationModel(
      title: data['title'] ?? 'Notifikasi',
      body: data['body'] ?? '',
      timestamp: data['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
    };
  }
}
