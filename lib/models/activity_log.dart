class ActivityLog {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final int timestamp;
  final String type; // invoice, product, customer, payment, system, warning, export, backup, return
  final String? tabTarget;

  ActivityLog({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.timestamp,
    this.type = 'system',
    this.tabTarget,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      type: json['type']?.toString() ?? 'system',
      tabTarget: json['tabTarget']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'timestamp': timestamp,
      'type': type,
      if (tabTarget != null) 'tabTarget': tabTarget,
    };
  }
}
