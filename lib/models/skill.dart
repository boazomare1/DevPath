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

  @HiveField(12)
  final DateTime updatedAt;

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
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get isCompleted => status == SkillStatus.completed;
  bool get isInProgress => status == SkillStatus.inProgress;
  bool get isNotStarted => status == SkillStatus.notStarted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.index,
      'status': status.index,
      'notes': notes,
      'resources': resources,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority,
      'tags': tags,
      'projects': projects?.map((p) => p.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: SkillCategory.values[json['category']],
      status: SkillStatus.values[json['status']],
      notes: json['notes'],
      resources: List<String>.from(json['resources'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      priority: json['priority'] ?? 3,
      tags: List<String>.from(json['tags'] ?? []),
      projects: json['projects'] != null 
          ? (json['projects'] as List).map((p) => SkillProject.fromJson(p)).toList()
          : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

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
