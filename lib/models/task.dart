import 'dart:convert';

enum Priority { none, low, medium, high }

enum Status { todo, inProgress, done }

class Task {
  final String id;
  final String title;
  final String description;
  // final Status status;
  final Priority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime? endDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.startDate,
    this.endDate,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    // Status? status,
    Priority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      // status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      // 'status': status,
      'priority': priority.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    DateTime ts(dynamic v) =>
        v is int ? DateTime.fromMillisecondsSinceEpoch(v) : DateTime.now();
    return Task(
      id: map['id'] is String ? map['id'] : '',
      title: map['title'] as String,
      description: map['description'] as String,
      // status: map['status'] as Status,
      priority: map['priority'] is int
          ? Priority.values[map['priority'] as int]
          : Priority.values.firstWhere(
              (e) => e.name == map['priority'],
              orElse: () => Priority.none,
            ),
      createdAt: ts(map['createdAt']),
      updatedAt: ts(map['updatedAt']),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      startDate: ts(map['StartDate']),
      endDate: ts(map['endDate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
