import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill.dart';
import '../models/skill_category.dart';
import '../models/skill_status.dart';
import '../models/github_repository.dart';

class CareerGoal {
  final String id;
  final String title;
  final String description;
  final String targetRole;
  final String industry;
  final List<String> requiredSkills;
  final List<String> recommendedSkills;
  final int targetSalary;
  final String experienceLevel;
  final DateTime targetDate;
  final DateTime createdAt;
  final bool isActive;
  final double progress; // 0.0 to 1.0
  final String? notes;

  CareerGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetRole,
    required this.industry,
    required this.requiredSkills,
    required this.recommendedSkills,
    required this.targetSalary,
    required this.experienceLevel,
    required this.targetDate,
    required this.createdAt,
    this.isActive = true,
    this.progress = 0.0,
    this.notes,
  });

  CareerGoal copyWith({
    String? id,
    String? title,
    String? description,
    String? targetRole,
    String? industry,
    List<String>? requiredSkills,
    List<String>? recommendedSkills,
    int? targetSalary,
    String? experienceLevel,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isActive,
    double? progress,
    String? notes,
  }) {
    return CareerGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetRole: targetRole ?? this.targetRole,
      industry: industry ?? this.industry,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      recommendedSkills: recommendedSkills ?? this.recommendedSkills,
      targetSalary: targetSalary ?? this.targetSalary,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      progress: progress ?? this.progress,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetRole': targetRole,
      'industry': industry,
      'requiredSkills': requiredSkills,
      'recommendedSkills': recommendedSkills,
      'targetSalary': targetSalary,
      'experienceLevel': experienceLevel,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'progress': progress,
      'notes': notes,
    };
  }

  factory CareerGoal.fromJson(Map<String, dynamic> json) {
    return CareerGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetRole: json['targetRole'],
      industry: json['industry'],
      requiredSkills: List<String>.from(json['requiredSkills']),
      recommendedSkills: List<String>.from(json['recommendedSkills']),
      targetSalary: json['targetSalary'],
      experienceLevel: json['experienceLevel'],
      targetDate: DateTime.parse(json['targetDate']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      progress: (json['progress'] ?? 0.0).toDouble(),
      notes: json['notes'],
    );
  }
}

class SkillGap {
  final String skill;
  final String category;
  final String importance; // High, Medium, Low
  final String currentLevel; // Beginner, Intermediate, Advanced
  final String targetLevel;
  final int estimatedHours;
  final List<String> resources;

  SkillGap({
    required this.skill,
    required this.category,
    required this.importance,
    required this.currentLevel,
    required this.targetLevel,
    required this.estimatedHours,
    required this.resources,
  });

  Map<String, dynamic> toJson() {
    return {
      'skill': skill,
      'category': category,
      'importance': importance,
      'currentLevel': currentLevel,
      'targetLevel': targetLevel,
      'estimatedHours': estimatedHours,
      'resources': resources,
    };
  }

  factory SkillGap.fromJson(Map<String, dynamic> json) {
    return SkillGap(
      skill: json['skill'],
      category: json['category'],
      importance: json['importance'],
      currentLevel: json['currentLevel'],
      targetLevel: json['targetLevel'],
      estimatedHours: json['estimatedHours'],
      resources: List<String>.from(json['resources']),
    );
  }
}

class CareerGoalsService extends ChangeNotifier {
  static const String _careerGoalsKey = 'career_goals';
  static const String _skillGapsKey = 'skill_gaps';

  List<CareerGoal> _careerGoals = [];
  List<SkillGap> _skillGaps = [];

  // Getters
  List<CareerGoal> get careerGoals => _careerGoals;
  List<CareerGoal> get activeGoals => _careerGoals.where((goal) => goal.isActive).toList();
  List<SkillGap> get skillGaps => _skillGaps;

  /// Initialize the career goals service
  Future<void> init() async {
    await _loadCareerGoals();
    await _loadSkillGaps();
  }

  /// Load career goals from storage
  Future<void> _loadCareerGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString(_careerGoalsKey);
      if (goalsJson != null) {
        final goalsData = jsonDecode(goalsJson) as List;
        _careerGoals = goalsData.map((goal) => CareerGoal.fromJson(goal)).toList();
      }
    } catch (e) {
      debugPrint('Error loading career goals: $e');
    }
  }

  /// Load skill gaps from storage
  Future<void> _loadSkillGaps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gapsJson = prefs.getString(_skillGapsKey);
      if (gapsJson != null) {
        final gapsData = jsonDecode(gapsJson) as List;
        _skillGaps = gapsData.map((gap) => SkillGap.fromJson(gap)).toList();
      }
    } catch (e) {
      debugPrint('Error loading skill gaps: $e');
    }
  }

  /// Create a new career goal
  Future<CareerGoal> createCareerGoal({
    required String title,
    required String description,
    required String targetRole,
    required String industry,
    required int targetSalary,
    required String experienceLevel,
    required DateTime targetDate,
    String? notes,
  }) async {
    final now = DateTime.now();
    final goalId = 'goal_${now.millisecondsSinceEpoch}';

    // Get role-specific skills
    final roleSkills = _getRoleSkills(targetRole);
    
    final goal = CareerGoal(
      id: goalId,
      title: title,
      description: description,
      targetRole: targetRole,
      industry: industry,
      requiredSkills: roleSkills['required'] ?? [],
      recommendedSkills: roleSkills['recommended'] ?? [],
      targetSalary: targetSalary,
      experienceLevel: experienceLevel,
      targetDate: targetDate,
      createdAt: now,
      notes: notes,
    );

    _careerGoals.add(goal);
    await _saveCareerGoals();
    notifyListeners();

    return goal;
  }

  /// Get role-specific skills
  Map<String, List<String>> _getRoleSkills(String targetRole) {
    final roleSkills = {
      'Frontend Developer': {
        'required': ['HTML', 'CSS', 'JavaScript', 'React', 'Git'],
        'recommended': ['TypeScript', 'Vue.js', 'Angular', 'SASS', 'Webpack'],
      },
      'Backend Developer': {
        'required': ['Node.js', 'Python', 'SQL', 'REST API', 'Git'],
        'recommended': ['Docker', 'AWS', 'MongoDB', 'GraphQL', 'Linux'],
      },
      'Full Stack Developer': {
        'required': ['HTML', 'CSS', 'JavaScript', 'Node.js', 'SQL', 'Git'],
        'recommended': ['React', 'Python', 'Docker', 'AWS', 'TypeScript'],
      },
      'Mobile Developer': {
        'required': ['React Native', 'JavaScript', 'Git', 'iOS/Android'],
        'recommended': ['Flutter', 'Swift', 'Kotlin', 'Firebase', 'Redux'],
      },
      'DevOps Engineer': {
        'required': ['Docker', 'AWS', 'Linux', 'CI/CD', 'Git'],
        'recommended': ['Kubernetes', 'Terraform', 'Python', 'Monitoring', 'Security'],
      },
      'Data Scientist': {
        'required': ['Python', 'SQL', 'Machine Learning', 'Statistics', 'Git'],
        'recommended': ['R', 'TensorFlow', 'Pandas', 'Jupyter', 'AWS'],
      },
      'UI/UX Designer': {
        'required': ['Figma', 'Adobe XD', 'User Research', 'Prototyping', 'Design Systems'],
        'recommended': ['Sketch', 'InVision', 'HTML/CSS', 'JavaScript', 'Accessibility'],
      },
    };

    return roleSkills[targetRole] ?? {
      'required': ['Git', 'Problem Solving', 'Communication'],
      'recommended': ['Project Management', 'Teamwork', 'Continuous Learning'],
    };
  }

  /// Update career goal progress
  Future<void> updateGoalProgress(String goalId, double progress) async {
    final index = _careerGoals.indexWhere((goal) => goal.id == goalId);
    if (index != -1) {
      _careerGoals[index] = _careerGoals[index].copyWith(progress: progress);
      await _saveCareerGoals();
      notifyListeners();
    }
  }

  /// Calculate skill gaps for a career goal
  Future<List<SkillGap>> calculateSkillGaps(
    String goalId,
    List<Skill> currentSkills,
  ) async {
    final goal = _careerGoals.firstWhere((g) => g.id == goalId);
    final gaps = <SkillGap>[];

    // Analyze required skills
    for (final requiredSkill in goal.requiredSkills) {
        final currentSkill = currentSkills.firstWhere(
          (skill) => skill.name.toLowerCase() == requiredSkill.toLowerCase(),
          orElse: () => Skill(
            id: '',
            name: requiredSkill,
            category: SkillCategory.programmingLanguages,
            status: SkillStatus.notStarted,
            description: '',
            notes: '',
            createdAt: DateTime.now(),
          ),
        );

      final currentLevel = _mapSkillStatusToLevel(currentSkill.status);
      final targetLevel = _getTargetLevelForRole(goal.targetRole, requiredSkill);

      if (currentLevel != targetLevel) {
        gaps.add(SkillGap(
          skill: requiredSkill,
          category: _getSkillCategory(requiredSkill),
          importance: 'High',
          currentLevel: currentLevel,
          targetLevel: targetLevel,
          estimatedHours: _estimateHoursToLevel(currentLevel, targetLevel),
          resources: _getResourcesForSkill(requiredSkill),
        ));
      }
    }

    // Analyze recommended skills
    for (final recommendedSkill in goal.recommendedSkills) {
        final currentSkill = currentSkills.firstWhere(
          (skill) => skill.name.toLowerCase() == recommendedSkill.toLowerCase(),
          orElse: () => Skill(
            id: '',
            name: recommendedSkill,
            category: SkillCategory.programmingLanguages,
            status: SkillStatus.notStarted,
            description: '',
            notes: '',
            createdAt: DateTime.now(),
          ),
        );

      final currentLevel = _mapSkillStatusToLevel(currentSkill.status);
      final targetLevel = _getTargetLevelForRole(goal.targetRole, recommendedSkill);

      if (currentLevel != targetLevel) {
        gaps.add(SkillGap(
          skill: recommendedSkill,
          category: _getSkillCategory(recommendedSkill),
          importance: 'Medium',
          currentLevel: currentLevel,
          targetLevel: targetLevel,
          estimatedHours: _estimateHoursToLevel(currentLevel, targetLevel),
          resources: _getResourcesForSkill(recommendedSkill),
        ));
      }
    }

    _skillGaps = gaps;
    await _saveSkillGaps();
    notifyListeners();

    return gaps;
  }

  /// Map skill status to level
  String _mapSkillStatusToLevel(SkillStatus status) {
    switch (status) {
      case SkillStatus.notStarted:
        return 'Beginner';
      case SkillStatus.inProgress:
        return 'Intermediate';
      case SkillStatus.completed:
        return 'Advanced';
    }
  }

  /// Get target level for a skill in a role
  String _getTargetLevelForRole(String role, String skill) {
    // This is a simplified mapping - in a real app, this would be more sophisticated
    final highLevelSkills = {
      'Frontend Developer': ['React', 'JavaScript', 'CSS'],
      'Backend Developer': ['Node.js', 'Python', 'SQL'],
      'Full Stack Developer': ['JavaScript', 'Node.js', 'React'],
    };

    final roleSkills = highLevelSkills[role] ?? [];
    return roleSkills.contains(skill) ? 'Advanced' : 'Intermediate';
  }

  /// Get skill category
  String _getSkillCategory(String skill) {
    final categories = {
      'HTML': 'Web Development',
      'CSS': 'Web Development',
      'JavaScript': 'Programming',
      'React': 'Frontend Framework',
      'Node.js': 'Backend Development',
      'Python': 'Programming',
      'SQL': 'Database',
      'Git': 'Version Control',
    };

    return categories[skill] ?? 'Other';
  }

  /// Estimate hours to reach target level
  int _estimateHoursToLevel(String currentLevel, String targetLevel) {
    final levelHours = {
      'Beginner': 0,
      'Intermediate': 40,
      'Advanced': 100,
    };

    final currentHours = levelHours[currentLevel] ?? 0;
    final targetHours = levelHours[targetLevel] ?? 0;

    return (targetHours - currentHours).clamp(0, 200);
  }

  /// Get resources for a skill
  List<String> _getResourcesForSkill(String skill) {
    final resources = {
      'HTML': ['MDN Web Docs', 'W3Schools HTML Tutorial', 'HTML5 Doctor'],
      'CSS': ['MDN CSS Guide', 'CSS-Tricks', 'Flexbox Froggy'],
      'JavaScript': ['JavaScript.info', 'Eloquent JavaScript', 'MDN JavaScript'],
      'React': ['React Docs', 'React Tutorial', 'React Router'],
      'Node.js': ['Node.js Docs', 'Express.js Guide', 'Node.js Best Practices'],
      'Python': ['Python.org Tutorial', 'Real Python', 'Python Crash Course'],
      'SQL': ['SQL Tutorial', 'PostgreSQL Docs', 'SQLBolt'],
      'Git': ['Git Handbook', 'Atlassian Git Tutorial', 'GitHub Docs'],
    };

    return resources[skill] ?? ['Online Tutorials', 'Documentation', 'Practice Projects'];
  }

  /// Delete a career goal
  Future<void> deleteCareerGoal(String goalId) async {
    _careerGoals.removeWhere((goal) => goal.id == goalId);
    await _saveCareerGoals();
    notifyListeners();
  }

  /// Archive a career goal
  Future<void> archiveCareerGoal(String goalId) async {
    final index = _careerGoals.indexWhere((goal) => goal.id == goalId);
    if (index != -1) {
      _careerGoals[index] = _careerGoals[index].copyWith(isActive: false);
      await _saveCareerGoals();
      notifyListeners();
    }
  }

  /// Save career goals to storage
  Future<void> _saveCareerGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = _careerGoals.map((goal) => goal.toJson()).toList();
      await prefs.setString(_careerGoalsKey, jsonEncode(goalsJson));
    } catch (e) {
      debugPrint('Error saving career goals: $e');
    }
  }

  /// Save skill gaps to storage
  Future<void> _saveSkillGaps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gapsJson = _skillGaps.map((gap) => gap.toJson()).toList();
      await prefs.setString(_skillGapsKey, jsonEncode(gapsJson));
    } catch (e) {
      debugPrint('Error saving skill gaps: $e');
    }
  }

  /// Get available target roles
  static List<String> getAvailableRoles() {
    return [
      'Frontend Developer',
      'Backend Developer',
      'Full Stack Developer',
      'Mobile Developer',
      'DevOps Engineer',
      'Data Scientist',
      'UI/UX Designer',
      'Product Manager',
      'Technical Writer',
      'QA Engineer',
    ];
  }

  /// Get available industries
  static List<String> getAvailableIndustries() {
    return [
      'Technology',
      'Finance',
      'Healthcare',
      'E-commerce',
      'Education',
      'Gaming',
      'Media',
      'Government',
      'Non-profit',
      'Other',
    ];
  }

  /// Get available experience levels
  static List<String> getAvailableExperienceLevels() {
    return [
      'Entry Level (0-2 years)',
      'Mid Level (2-5 years)',
      'Senior Level (5-10 years)',
      'Lead/Principal (10+ years)',
    ];
  }
}