import 'dart:convert';

enum Priority { low, medium, high }

enum Status { todo, inProgress, done }

class Task {
  final String id;
  final String title;
  final String description;

  // final Status status;
  // final Priority priority;

  // final DateTime createdAt;
  // final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,

    // required this.status,
    // required this.priority,

    // required this.createdAt,
    // required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,

    // Status? status,
    // Priority? priority,

    // DateTime? createdAt,
    // DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,

      // status: status ?? this.status,
      // priority: priority ?? this.priority,

      // createdAt: createdAt ?? this.createdAt,
      // updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,

      // 'status': status,
      // 'priority': priority,

      // 'createdAt': createdAt.millisecondsSinceEpoch,
      // 'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,

      // status: map['status'] as Status,
      // priority: map['priority'] as Priority,

      // createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      // updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  // @override
  // String toString() {
  //   return 'Task(id: $id, title: $title, status: $status, priority: $priority)';
  // }
}
