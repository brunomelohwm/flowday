enum Priority { none, low, medium, high }

enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final Priority priority;
  final TaskStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    this.status = TaskStatus.todo,
    this.createdAt,
    this.updatedAt,
    this.startDate,
    this.endDate,
  });

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    Priority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
