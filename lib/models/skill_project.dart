import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'skill_project.g.dart';

@HiveType(typeId: 3)
class SkillProject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String difficulty; // Beginner, Intermediate, Advanced
  @HiveField(4)
  final bool isCompleted;
  @HiveField(5)
  final DateTime? completedAt;
  @HiveField(6)
  final List<String> requirements;
  @HiveField(7)
  final String? notes;
  @HiveField(8)
  final int estimatedHours;

  SkillProject({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.isCompleted = false,
    this.completedAt,
    this.requirements = const [],
    this.notes,
    this.estimatedHours = 0,
  });

  SkillProject copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? requirements,
    String? notes,
    int? estimatedHours,
  }) {
    return SkillProject(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      requirements: requirements ?? this.requirements,
      notes: notes ?? this.notes,
      estimatedHours: estimatedHours ?? this.estimatedHours,
    );
  }

  @override
  String toString() {
    return 'SkillProject(id: $id, title: $title, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkillProject && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
