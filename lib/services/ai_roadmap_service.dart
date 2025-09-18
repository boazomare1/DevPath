import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/skill.dart';
import '../models/skill_category.dart';
import '../models/github_repository.dart';

class LearningPath {
  final String id;
  final String title;
  final String description;
  final String targetRole;
  final List<LearningStep> steps;
  final int estimatedDuration; // in weeks
  final String difficulty; // Beginner, Intermediate, Advanced
  final DateTime createdAt;
  final bool isCompleted;
  final double progress; // 0.0 to 1.0

  LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.targetRole,
    required this.steps,
    required this.estimatedDuration,
    required this.difficulty,
    required this.createdAt,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  LearningPath copyWith({
    String? id,
    String? title,
    String? description,
    String? targetRole,
    List<LearningStep>? steps,
    int? estimatedDuration,
    String? difficulty,
    DateTime? createdAt,
    bool? isCompleted,
    double? progress,
  }) {
    return LearningPath(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetRole: targetRole ?? this.targetRole,
      steps: steps ?? this.steps,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetRole': targetRole,
      'steps': steps.map((step) => step.toJson()).toList(),
      'estimatedDuration': estimatedDuration,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetRole: json['targetRole'],
      steps:
          (json['steps'] as List)
              .map((step) => LearningStep.fromJson(step))
              .toList(),
      estimatedDuration: json['estimatedDuration'],
      difficulty: json['difficulty'],
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }
}

class LearningStep {
  final String id;
  final String title;
  final String description;
  final String skillCategory;
  final List<String> skills;
  final List<String> resources;
  final int estimatedHours;
  final String difficulty;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? notes;

  LearningStep({
    required this.id,
    required this.title,
    required this.description,
    required this.skillCategory,
    required this.skills,
    required this.resources,
    required this.estimatedHours,
    required this.difficulty,
    this.isCompleted = false,
    this.completedAt,
    this.notes,
  });

  LearningStep copyWith({
    String? id,
    String? title,
    String? description,
    String? skillCategory,
    List<String>? skills,
    List<String>? resources,
    int? estimatedHours,
    String? difficulty,
    bool? isCompleted,
    DateTime? completedAt,
    String? notes,
  }) {
    return LearningStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      skillCategory: skillCategory ?? this.skillCategory,
      skills: skills ?? this.skills,
      resources: resources ?? this.resources,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'skillCategory': skillCategory,
      'skills': skills,
      'resources': resources,
      'estimatedHours': estimatedHours,
      'difficulty': difficulty,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory LearningStep.fromJson(Map<String, dynamic> json) {
    return LearningStep(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      skillCategory: json['skillCategory'],
      skills: List<String>.from(json['skills']),
      resources: List<String>.from(json['resources']),
      estimatedHours: json['estimatedHours'],
      difficulty: json['difficulty'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      notes: json['notes'],
    );
  }
}

class AIRoadmapService extends ChangeNotifier {
  static const String _apiKey =
      'your-openai-api-key'; // Replace with actual API key
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  List<LearningPath> _learningPaths = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<LearningPath> get learningPaths => _learningPaths;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Generate a personalized learning path based on user's skills and goals
  Future<LearningPath?> generateLearningPath({
    required String targetRole,
    required List<Skill> currentSkills,
    required List<GitHubRepository> repositories,
    String experienceLevel = 'Beginner',
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // For now, we'll create a mock learning path
      // In a real implementation, you would call the AI API
      final learningPath = _createMockLearningPath(
        targetRole: targetRole,
        currentSkills: currentSkills,
        repositories: repositories,
        experienceLevel: experienceLevel,
      );

      _learningPaths.add(learningPath);
      notifyListeners();
      return learningPath;
    } catch (e) {
      _errorMessage = 'Failed to generate learning path: $e';
      debugPrint('Error generating learning path: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Create a mock learning path (replace with actual AI API call)
  LearningPath _createMockLearningPath({
    required String targetRole,
    required List<Skill> currentSkills,
    required List<GitHubRepository> repositories,
    required String experienceLevel,
  }) {
    final now = DateTime.now();
    final pathId = 'path_${now.millisecondsSinceEpoch}';

    // Analyze current skills and repositories to determine learning steps
    final steps = _generateLearningSteps(
      targetRole: targetRole,
      currentSkills: currentSkills,
      repositories: repositories,
      experienceLevel: experienceLevel,
    );

    return LearningPath(
      id: pathId,
      title: 'Become a $targetRole',
      description:
          'A personalized learning path to become a $targetRole based on your current skills and projects.',
      targetRole: targetRole,
      steps: steps,
      estimatedDuration: _calculateEstimatedDuration(steps),
      difficulty: experienceLevel,
      createdAt: now,
    );
  }

  /// Generate learning steps based on target role and current skills
  List<LearningStep> _generateLearningSteps({
    required String targetRole,
    required List<Skill> currentSkills,
    required List<GitHubRepository> repositories,
    required String experienceLevel,
  }) {
    final steps = <LearningStep>[];
    final now = DateTime.now();

    // Define common learning steps based on target role
    final roleSteps = _getRoleBasedSteps(targetRole, experienceLevel);

    for (int i = 0; i < roleSteps.length; i++) {
      final step = roleSteps[i];
      final stepId = 'step_${now.millisecondsSinceEpoch}_$i';

      steps.add(
        LearningStep(
          id: stepId,
          title: step['title'],
          description: step['description'],
          skillCategory: step['category'],
          skills: List<String>.from(step['skills']),
          resources: List<String>.from(step['resources']),
          estimatedHours: step['hours'],
          difficulty: step['difficulty'],
        ),
      );
    }

    return steps;
  }

  /// Get role-based learning steps
  List<Map<String, dynamic>> _getRoleBasedSteps(
    String targetRole,
    String experienceLevel,
  ) {
    final Map<String, List<Map<String, dynamic>>> roleSteps = {
      'Frontend Developer': [
        {
          'title': 'Master HTML & CSS Fundamentals',
          'description': 'Learn the building blocks of web development',
          'category': 'Web Development',
          'skills': ['HTML', 'CSS', 'Responsive Design'],
          'resources': ['MDN Web Docs', 'CSS Grid Guide', 'Flexbox Tutorial'],
          'hours': 40,
          'difficulty': 'Beginner',
        },
        {
          'title': 'JavaScript Deep Dive',
          'description': 'Master modern JavaScript and ES6+ features',
          'category': 'Programming',
          'skills': ['JavaScript', 'ES6+', 'DOM Manipulation'],
          'resources': [
            'JavaScript.info',
            'Eloquent JavaScript',
            'MDN JavaScript',
          ],
          'hours': 60,
          'difficulty': 'Intermediate',
        },
        {
          'title': 'React Framework Mastery',
          'description': 'Build dynamic user interfaces with React',
          'category': 'Frontend Framework',
          'skills': ['React', 'JSX', 'Hooks', 'State Management'],
          'resources': ['React Docs', 'React Tutorial', 'Redux Guide'],
          'hours': 80,
          'difficulty': 'Intermediate',
        },
        {
          'title': 'Advanced Frontend Tools',
          'description': 'Learn modern build tools and testing',
          'category': 'Tools & Testing',
          'skills': ['Webpack', 'Jest', 'TypeScript', 'Git'],
          'resources': ['Webpack Guide', 'Jest Docs', 'TypeScript Handbook'],
          'hours': 50,
          'difficulty': 'Advanced',
        },
      ],
      'Backend Developer': [
        {
          'title': 'Server-Side Programming',
          'description': 'Learn backend programming fundamentals',
          'category': 'Backend Development',
          'skills': ['Node.js', 'Python', 'Java', 'C#'],
          'resources': ['Node.js Docs', 'Python Tutorial', 'Java Guide'],
          'hours': 70,
          'difficulty': 'Intermediate',
        },
        {
          'title': 'Database Design & Management',
          'description': 'Master database concepts and SQL',
          'category': 'Database',
          'skills': ['SQL', 'PostgreSQL', 'MongoDB', 'Database Design'],
          'resources': [
            'SQL Tutorial',
            'PostgreSQL Docs',
            'MongoDB University',
          ],
          'hours': 60,
          'difficulty': 'Intermediate',
        },
        {
          'title': 'API Development',
          'description': 'Build RESTful and GraphQL APIs',
          'category': 'API Development',
          'skills': ['REST API', 'GraphQL', 'Express.js', 'FastAPI'],
          'resources': ['REST API Guide', 'GraphQL Docs', 'Express.js Guide'],
          'hours': 50,
          'difficulty': 'Intermediate',
        },
        {
          'title': 'DevOps & Deployment',
          'description': 'Learn deployment and infrastructure',
          'category': 'DevOps',
          'skills': ['Docker', 'AWS', 'CI/CD', 'Linux'],
          'resources': ['Docker Docs', 'AWS Tutorial', 'GitHub Actions'],
          'hours': 40,
          'difficulty': 'Advanced',
        },
      ],
      'Full Stack Developer': [
        {
          'title': 'Frontend Fundamentals',
          'description': 'Master HTML, CSS, and JavaScript',
          'category': 'Frontend',
          'skills': ['HTML', 'CSS', 'JavaScript', 'Responsive Design'],
          'resources': ['MDN Web Docs', 'JavaScript.info', 'CSS Grid'],
          'hours': 60,
          'difficulty': 'Beginner',
        },
        {
          'title': 'Backend Development',
          'description': 'Learn server-side programming and databases',
          'category': 'Backend',
          'skills': ['Node.js', 'Python', 'SQL', 'REST API'],
          'resources': ['Node.js Docs', 'Python Tutorial', 'SQL Guide'],
          'hours': 80,
          'difficulty': 'Intermediate',
        },
        {
          'title': 'Full Stack Integration',
          'description': 'Connect frontend and backend seamlessly',
          'category': 'Integration',
          'skills': ['API Integration', 'Authentication', 'State Management'],
          'resources': ['API Integration Guide', 'JWT Tutorial', 'Redux Docs'],
          'hours': 50,
          'difficulty': 'Intermediate',
        },
        {
          'title': 'Advanced Full Stack',
          'description': 'Master advanced full stack concepts',
          'category': 'Advanced',
          'skills': ['Microservices', 'Docker', 'Testing', 'Performance'],
          'resources': ['Microservices Guide', 'Docker Docs', 'Testing Guide'],
          'hours': 70,
          'difficulty': 'Advanced',
        },
      ],
    };

    return roleSteps[targetRole] ?? roleSteps['Full Stack Developer']!;
  }

  /// Calculate estimated duration based on steps
  int _calculateEstimatedDuration(List<LearningStep> steps) {
    final totalHours = steps.fold(0, (sum, step) => sum + step.estimatedHours);
    return (totalHours / 20).ceil(); // Assuming 20 hours per week
  }

  /// Update learning path progress
  Future<void> updateProgress(String pathId, double progress) async {
    final index = _learningPaths.indexWhere((path) => path.id == pathId);
    if (index != -1) {
      _learningPaths[index] = _learningPaths[index].copyWith(
        progress: progress,
      );
      notifyListeners();
    }
  }

  /// Mark a learning step as completed
  Future<void> completeStep(String pathId, String stepId) async {
    final pathIndex = _learningPaths.indexWhere((path) => path.id == pathId);
    if (pathIndex != -1) {
      final stepIndex = _learningPaths[pathIndex].steps.indexWhere(
        (step) => step.id == stepId,
      );
      if (stepIndex != -1) {
        final updatedSteps = List<LearningStep>.from(
          _learningPaths[pathIndex].steps,
        );
        updatedSteps[stepIndex] = updatedSteps[stepIndex].copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );

        _learningPaths[pathIndex] = _learningPaths[pathIndex].copyWith(
          steps: updatedSteps,
          progress: _calculatePathProgress(updatedSteps),
        );

        notifyListeners();
      }
    }
  }

  /// Calculate overall path progress
  double _calculatePathProgress(List<LearningStep> steps) {
    if (steps.isEmpty) return 0.0;
    final completedSteps = steps.where((step) => step.isCompleted).length;
    return completedSteps / steps.length;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
