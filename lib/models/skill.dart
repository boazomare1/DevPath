import 'package:hive/hive.dart';
import 'skill_status.dart';
import 'skill_category.dart';
import 'skill_project.dart';

part 'skill.g.dart';

@HiveType(typeId: 0)
class Skill extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final SkillCategory category;

  @HiveField(4)
  final SkillStatus status;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final List<String> resources;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final int priority; // 1-5, where 5 is highest priority

  @HiveField(10)
  final List<String> tags;

  @HiveField(11)
  final List<SkillProject>? projects;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.status = SkillStatus.notStarted,
    this.notes,
    this.resources = const [],
    required this.createdAt,
    this.completedAt,
    this.priority = 3,
    this.tags = const [],
    this.projects,
  });

  Skill copyWith({
    String? id,
    String? name,
    String? description,
    SkillCategory? category,
    SkillStatus? status,
    String? notes,
    List<String>? resources,
    DateTime? createdAt,
    DateTime? completedAt,
    int? priority,
    List<String>? tags,
    List<SkillProject>? projects,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      resources: resources ?? this.resources,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      projects: projects ?? this.projects,
    );
  }

  bool get isCompleted => status == SkillStatus.completed;
  bool get isInProgress => status == SkillStatus.inProgress;
  bool get isNotStarted => status == SkillStatus.notStarted;

  @override
  String toString() {
    return 'Skill(id: $id, name: $name, status: $status, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Skill && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
