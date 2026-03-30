import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { none, low, medium, high }

enum Status { todo, inProgress, done }

class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final Priority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime? endDate;

  Task({
    required this.id,
    required this.userId,
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
    String? userId,
    String? title,
    String? description,
    Priority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
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
      'userId': userId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, {String? id}) {
    Timestamp? ts(dynamic value) {
      if (value is Timestamp) return value;
      return null;
    }

    return Task(
      id: id ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] != null
          ? Priority.values.firstWhere(
              (e) => e.name == map['priority'],
              orElse: () => Priority.none,
            )
          : Priority.none,
      createdAt: ts(map['createdAt'])?.toDate() ?? DateTime.now(),
      updatedAt: ts(map['updatedAt'])?.toDate() ?? DateTime.now(),
      dueDate: ts(map['dueDate'])?.toDate(),
      startDate: ts(map['startDate'])?.toDate(),
      endDate: ts(map['endDate'])?.toDate(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source, {String? id}) =>
      Task.fromMap(json.decode(source), id: id);
}
