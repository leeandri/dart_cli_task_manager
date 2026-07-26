enum Priority { low, medium, high }

abstract class Task {
  final String id;
  final String title;
  final Priority priority;
  final DateTime? deadline;
  bool completed;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': priority == Priority.high ? 'urgent' : 'simple',
      'id': id,
      'title': title,
      'priority': priority.name,
      'deadline': deadline?.toIso8601String(),
      'completed': completed,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final priority = Priority.values.byName(json['priority'] as String);

    if (priority == Priority.high || json['type'] == 'urgent') {
      return UrgentTask.fromJson(json);
    } else {
      return SimpleTask.fromJson(json);
    }
  }
}

class SimpleTask extends Task {
  SimpleTask({
    required super.id,
    required super.title,
    super.priority = Priority.medium,
    super.deadline,
    super.completed,
  });

  factory SimpleTask.fromJson(Map<String, dynamic> json) {
    return SimpleTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: Priority.values.byName(json['priority'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      completed: json['completed'] as bool,
    );
  }
}

class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    super.priority = Priority.high,
    super.deadline,
    super.completed,
  });

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: Priority.values.byName(json['priority'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      completed: json['completed'] as bool,
    );
  }
}
