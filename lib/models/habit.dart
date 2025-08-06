class Habit {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final int targetDays;
  final String category;
  final Color color;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.completedDates,
    required this.targetDays,
    required this.category,
    required this.color,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      completedDates: (json['completedDates'] as List)
          .map((date) => DateTime.parse(date))
          .toList(),
      targetDays: json['targetDays'],
      category: json['category'],
      color: Color(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedDates': completedDates.map((date) => date.toIso8601String()).toList(),
      'targetDays': targetDays,
      'category': category,
      'color': color.value,
    };
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    
    final sortedDates = List<DateTime>.from(completedDates)..sort();
    final today = DateTime.now();
    int streak = 0;
    
    for (int i = sortedDates.length - 1; i >= 0; i--) {
      final date = sortedDates[i];
      final daysDifference = today.difference(date).inDays;
      
      if (daysDifference == streak) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((date) => 
        date.year == today.year && 
        date.month == today.month && 
        date.day == today.day);
  }

  double get completionRate {
    if (targetDays == 0) return 0.0;
    return completedDates.length / targetDays;
  }
}