enum Priority { low, medium, high }

/// Abstract base representation of a task entity.
abstract class Task {
  final String id;
  final String title;
  final Priority priority;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson();

  String getSummary();

  // Polymorphic factory reconstructs correct Task sub-type from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'urgent') {
      return UrgentTask.fromJson(json);
    }
    return SimpleTask.fromJson(json);
  }
}

class SimpleTask extends Task {
  SimpleTask({
    required super.id,
    required super.title,
    required super.priority,
    super.isCompleted,
    super.createdAt,
  });

  @override
  String getSummary() => '[Simple] $title (Priority: ${priority.name})';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'simple',
    'id': id,
    'title': title,
    'priority': priority.name,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SimpleTask.fromJson(Map<String, dynamic> json) {
    return SimpleTask(
      id: json['id'],
      title: json['title'],
      priority: Priority.values.byName(json['priority']),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Represents an urgent task with a mandatory due deadline.
class UrgentTask extends Task {
  final DateTime deadline;

  UrgentTask({
    required super.id,
    required super.title,
    required super.priority,
    required this.deadline,
    super.isCompleted,
    super.createdAt,
  });

  @override
  String getSummary() =>
      '[URGENT] $title (Due: ${deadline.toIso8601String().split('T').first})';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'urgent',
    'id': id,
    'title': title,
    'priority': priority.name,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'deadline': deadline.toIso8601String(),
  };

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'],
      title: json['title'],
      priority: Priority.values.byName(json['priority']),
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
