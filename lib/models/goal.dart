class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final bool isCompleted;
  final int priority;
  final String category;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.isCompleted,
    required this.priority,
    required this.category,
  });

  // JSON serialization
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetDate: DateTime.parse(json['targetDate']),
      isCompleted: json['isCompleted'],
      priority: json['priority'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'category': category,
    };
  }
}