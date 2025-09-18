import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill.dart';
import '../models/skill_category.dart';
import '../models/skill_status.dart';
import '../models/github_repository.dart';

class Company {
  final String id;
  final String name;
  final String industry;
  final String description;
  final String logoUrl;
  final Map<String, List<String>> roleRequirements; // role -> skills
  final Map<String, int> salaryRanges; // role -> min salary
  final List<String> benefits;
  final String location;
  final String website;

  Company({
    required this.id,
    required this.name,
    required this.industry,
    required this.description,
    required this.logoUrl,
    required this.roleRequirements,
    required this.salaryRanges,
    required this.benefits,
    required this.location,
    required this.website,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'industry': industry,
      'description': description,
      'logoUrl': logoUrl,
      'roleRequirements': roleRequirements,
      'salaryRanges': salaryRanges,
      'benefits': benefits,
      'location': location,
      'website': website,
    };
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      industry: json['industry'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      roleRequirements: Map<String, List<String>>.from(
        (json['roleRequirements'] as Map).map(
          (key, value) =>
              MapEntry(key.toString(), List<String>.from(value as List)),
        ),
      ),
      salaryRanges: Map<String, int>.from(json['salaryRanges']),
      benefits: List<String>.from(json['benefits']),
      location: json['location'],
      website: json['website'],
    );
  }
}

class SkillGap {
  final String skillName;
  final String category;
  final String importance; // High, Medium, Low
  final int currentLevel; // 1-5
  final int targetLevel; // 1-5
  final int estimatedHours;
  final List<String> resources;
  final bool isRequired;
  final String priority; // Critical, High, Medium, Low

  SkillGap({
    required this.skillName,
    required this.category,
    required this.importance,
    required this.currentLevel,
    required this.targetLevel,
    required this.estimatedHours,
    required this.resources,
    required this.isRequired,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'skillName': skillName,
      'category': category,
      'importance': importance,
      'currentLevel': currentLevel,
      'targetLevel': targetLevel,
      'estimatedHours': estimatedHours,
      'resources': resources,
      'isRequired': isRequired,
      'priority': priority,
    };
  }

  factory SkillGap.fromJson(Map<String, dynamic> json) {
    return SkillGap(
      skillName: json['skillName'],
      category: json['category'],
      importance: json['importance'],
      currentLevel: json['currentLevel'],
      targetLevel: json['targetLevel'],
      estimatedHours: json['estimatedHours'],
      resources: List<String>.from(json['resources']),
      isRequired: json['isRequired'],
      priority: json['priority'],
    );
  }
}

class AIRecommendation {
  final String id;
  final String title;
  final String description;
  final String type; // Course, Project, Practice, Certification
  final int estimatedHours;
  final String difficulty;
  final List<String> skills;
  final String priority;
  final String reason;
  final List<String> resources;
  final bool isCompleted;

  AIRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.estimatedHours,
    required this.difficulty,
    required this.skills,
    required this.priority,
    required this.reason,
    required this.resources,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'estimatedHours': estimatedHours,
      'difficulty': difficulty,
      'skills': skills,
      'priority': priority,
      'reason': reason,
      'resources': resources,
      'isCompleted': isCompleted,
    };
  }

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      estimatedHours: json['estimatedHours'],
      difficulty: json['difficulty'],
      skills: List<String>.from(json['skills']),
      priority: json['priority'],
      reason: json['reason'],
      resources: List<String>.from(json['resources']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class EnhancedCareerGoal {
  final String id;
  final String title;
  final String description;
  final String targetRole;
  final String targetCompany;
  final String industry;
  final int targetSalary;
  final String experienceLevel;
  final DateTime targetDate;
  final List<String> requiredSkills;
  final List<String> recommendedSkills;
  final List<String> niceToHaveSkills;
  final Map<String, int> skillPriorities; // skill -> priority (1-5)
  final double progress;
  final double readinessPercentage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<SkillGap> skillGaps;
  final List<AIRecommendation> aiRecommendations;
  final String? notes;

  EnhancedCareerGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetRole,
    this.targetCompany = '',
    required this.industry,
    required this.targetSalary,
    required this.experienceLevel,
    required this.targetDate,
    required this.requiredSkills,
    required this.recommendedSkills,
    this.niceToHaveSkills = const [],
    this.skillPriorities = const {},
    this.progress = 0.0,
    this.readinessPercentage = 0.0,
    this.isActive = true,
    required this.createdAt,
    this.completedAt,
    this.skillGaps = const [],
    this.aiRecommendations = const [],
    this.notes,
  });

  EnhancedCareerGoal copyWith({
    String? id,
    String? title,
    String? description,
    String? targetRole,
    String? targetCompany,
    String? industry,
    int? targetSalary,
    String? experienceLevel,
    DateTime? targetDate,
    List<String>? requiredSkills,
    List<String>? recommendedSkills,
    List<String>? niceToHaveSkills,
    Map<String, int>? skillPriorities,
    double? progress,
    double? readinessPercentage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? completedAt,
    List<SkillGap>? skillGaps,
    List<AIRecommendation>? aiRecommendations,
    String? notes,
  }) {
    return EnhancedCareerGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetRole: targetRole ?? this.targetRole,
      targetCompany: targetCompany ?? this.targetCompany,
      industry: industry ?? this.industry,
      targetSalary: targetSalary ?? this.targetSalary,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      targetDate: targetDate ?? this.targetDate,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      recommendedSkills: recommendedSkills ?? this.recommendedSkills,
      niceToHaveSkills: niceToHaveSkills ?? this.niceToHaveSkills,
      skillPriorities: skillPriorities ?? this.skillPriorities,
      progress: progress ?? this.progress,
      readinessPercentage: readinessPercentage ?? this.readinessPercentage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      skillGaps: skillGaps ?? this.skillGaps,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetRole': targetRole,
      'targetCompany': targetCompany,
      'industry': industry,
      'targetSalary': targetSalary,
      'experienceLevel': experienceLevel,
      'targetDate': targetDate.toIso8601String(),
      'requiredSkills': requiredSkills,
      'recommendedSkills': recommendedSkills,
      'niceToHaveSkills': niceToHaveSkills,
      'skillPriorities': skillPriorities,
      'progress': progress,
      'readinessPercentage': readinessPercentage,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'skillGaps': skillGaps.map((gap) => gap.toJson()).toList(),
      'aiRecommendations':
          aiRecommendations.map((rec) => rec.toJson()).toList(),
      'notes': notes,
    };
  }

  factory EnhancedCareerGoal.fromJson(Map<String, dynamic> json) {
    return EnhancedCareerGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetRole: json['targetRole'],
      targetCompany: json['targetCompany'] ?? '',
      industry: json['industry'],
      targetSalary: json['targetSalary'],
      experienceLevel: json['experienceLevel'],
      targetDate: DateTime.parse(json['targetDate']),
      requiredSkills: List<String>.from(json['requiredSkills']),
      recommendedSkills: List<String>.from(json['recommendedSkills']),
      niceToHaveSkills: List<String>.from(json['niceToHaveSkills'] ?? []),
      skillPriorities: Map<String, int>.from(json['skillPriorities'] ?? {}),
      progress: (json['progress'] ?? 0.0).toDouble(),
      readinessPercentage: (json['readinessPercentage'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      skillGaps:
          (json['skillGaps'] as List? ?? [])
              .map((gap) => SkillGap.fromJson(gap))
              .toList(),
      aiRecommendations:
          (json['aiRecommendations'] as List? ?? [])
              .map((rec) => AIRecommendation.fromJson(rec))
              .toList(),
      notes: json['notes'],
    );
  }
}

class EnhancedCareerGoalsService extends ChangeNotifier {
  static const String _goalsKey = 'enhanced_career_goals';
  static const String _companiesKey = 'companies';
  static const String _skillGapsKey = 'skill_gaps';

  List<EnhancedCareerGoal> _careerGoals = [];
  List<Company> _companies = [];
  List<SkillGap> _skillGaps = [];

  // Getters
  List<EnhancedCareerGoal> get careerGoals => _careerGoals;
  List<EnhancedCareerGoal> get activeGoals =>
      _careerGoals.where((goal) => goal.isActive).toList();
  List<Company> get companies => _companies;
  List<SkillGap> get skillGaps => _skillGaps;

  /// Initialize the service
  Future<void> init() async {
    await _loadCareerGoals();
    await _loadCompanies();
    await _loadSkillGaps();
    _initializeDefaultCompanies();
  }

  /// Load career goals from storage
  Future<void> _loadCareerGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString(_goalsKey);
      if (goalsJson != null) {
        final goalsData = jsonDecode(goalsJson) as List;
        _careerGoals =
            goalsData.map((goal) => EnhancedCareerGoal.fromJson(goal)).toList();
      }
    } catch (e) {
      debugPrint('Error loading career goals: $e');
    }
  }

  /// Load companies from storage
  Future<void> _loadCompanies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companiesJson = prefs.getString(_companiesKey);
      if (companiesJson != null) {
        final companiesData = jsonDecode(companiesJson) as List;
        _companies =
            companiesData.map((company) => Company.fromJson(company)).toList();
      }
    } catch (e) {
      debugPrint('Error loading companies: $e');
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

  /// Initialize default companies
  void _initializeDefaultCompanies() {
    if (_companies.isNotEmpty) return;

    _companies = [
      Company(
        id: 'google',
        name: 'Google',
        industry: 'Technology',
        description:
            'A multinational technology company specializing in Internet-related services and products.',
        logoUrl: 'https://logo.clearbit.com/google.com',
        roleRequirements: {
          'Senior Software Engineer': [
            'Python',
            'Java',
            'C++',
            'Go',
            'System Design',
            'Algorithms',
            'Data Structures',
            'Machine Learning',
            'Distributed Systems',
          ],
          'Frontend Engineer': [
            'JavaScript',
            'TypeScript',
            'React',
            'Angular',
            'Vue.js',
            'HTML',
            'CSS',
            'Web Performance',
            'Accessibility',
          ],
          'Backend Engineer': [
            'Python',
            'Java',
            'Go',
            'Microservices',
            'Databases',
            'APIs',
            'Cloud Computing',
            'DevOps',
          ],
        },
        salaryRanges: {
          'Senior Software Engineer': 180000,
          'Frontend Engineer': 150000,
          'Backend Engineer': 160000,
        },
        benefits: [
          'Health Insurance',
          '401k',
          'Stock Options',
          'Free Meals',
          'Gym',
        ],
        location: 'Mountain View, CA',
        website: 'https://careers.google.com',
      ),
      Company(
        id: 'microsoft',
        name: 'Microsoft',
        industry: 'Technology',
        description:
            'A multinational technology corporation that develops, manufactures, licenses, supports and sells computer software, consumer electronics, personal computers, and related services.',
        logoUrl: 'https://logo.clearbit.com/microsoft.com',
        roleRequirements: {
          'Senior Software Engineer': [
            'C#',
            'C++',
            'Python',
            'Azure',
            'System Design',
            'Algorithms',
            'Data Structures',
            'Cloud Computing',
            'Microservices',
          ],
          'Full Stack Developer': [
            'C#',
            'JavaScript',
            'React',
            'Angular',
            'SQL Server',
            'Azure',
            'REST APIs',
            'Git',
          ],
        },
        salaryRanges: {
          'Senior Software Engineer': 170000,
          'Full Stack Developer': 140000,
        },
        benefits: [
          'Health Insurance',
          '401k',
          'Stock Options',
          'Flexible Work',
        ],
        location: 'Redmond, WA',
        website: 'https://careers.microsoft.com',
      ),
      Company(
        id: 'meta',
        name: 'Meta',
        industry: 'Technology',
        description:
            'A social media and technology company that develops products to help people connect and share with friends and family.',
        logoUrl: 'https://logo.clearbit.com/meta.com',
        roleRequirements: {
          'Software Engineer': [
            'Python',
            'PHP',
            'JavaScript',
            'React',
            'GraphQL',
            'System Design',
            'Algorithms',
            'Machine Learning',
          ],
          'Frontend Engineer': [
            'JavaScript',
            'React',
            'TypeScript',
            'GraphQL',
            'Web Performance',
            'Mobile Development',
          ],
        },
        salaryRanges: {
          'Software Engineer': 160000,
          'Frontend Engineer': 145000,
        },
        benefits: ['Health Insurance', '401k', 'Stock Options', 'Free Food'],
        location: 'Menlo Park, CA',
        website: 'https://careers.meta.com',
      ),
      Company(
        id: 'netflix',
        name: 'Netflix',
        industry: 'Entertainment',
        description:
            'A streaming entertainment service with 200+ million paid memberships in over 190 countries.',
        logoUrl: 'https://logo.clearbit.com/netflix.com',
        roleRequirements: {
          'Senior Software Engineer': [
            'Java',
            'Python',
            'Go',
            'System Design',
            'Microservices',
            'Cloud Computing',
            'Data Engineering',
            'Machine Learning',
          ],
        },
        salaryRanges: {'Senior Software Engineer': 200000},
        benefits: [
          'Health Insurance',
          '401k',
          'Stock Options',
          'Unlimited PTO',
        ],
        location: 'Los Gatos, CA',
        website: 'https://jobs.netflix.com',
      ),
    ];
    _saveCompanies();
  }

  /// Create a new career goal
  Future<EnhancedCareerGoal> createCareerGoal({
    required String title,
    required String description,
    required String targetRole,
    required String targetCompany,
    required String industry,
    required int targetSalary,
    required String experienceLevel,
    required DateTime targetDate,
    List<Skill>? currentSkills,
  }) async {
    final goalId = 'goal_${DateTime.now().millisecondsSinceEpoch}';

    // Get role requirements from company or default
    final roleRequirements = _getRoleRequirements(targetRole, targetCompany);

    final goal = EnhancedCareerGoal(
      id: goalId,
      title: title,
      description: description,
      targetRole: targetRole,
      targetCompany: targetCompany,
      industry: industry,
      targetSalary: targetSalary,
      experienceLevel: experienceLevel,
      targetDate: targetDate,
      requiredSkills: roleRequirements['required'] ?? [],
      recommendedSkills: roleRequirements['recommended'] ?? [],
      niceToHaveSkills: roleRequirements['niceToHave'] ?? [],
      createdAt: DateTime.now(),
    );

    // Analyze skill gaps if current skills provided
    if (currentSkills != null) {
      final skillGaps = await _analyzeSkillGaps(goal, currentSkills);
      final readinessPercentage = _calculateReadinessPercentage(
        goal,
        currentSkills,
      );
      final aiRecommendations = await _generateAIRecommendations(
        goal,
        skillGaps,
      );

      final updatedGoal = goal.copyWith(
        skillGaps: skillGaps,
        readinessPercentage: readinessPercentage,
        aiRecommendations: aiRecommendations,
      );

      _careerGoals.add(updatedGoal);
    } else {
      _careerGoals.add(goal);
    }

    await _saveCareerGoals();
    notifyListeners();
    return _careerGoals.last;
  }

  /// Get role requirements from company or default
  Map<String, List<String>> _getRoleRequirements(
    String targetRole,
    String targetCompany,
  ) {
    final company = _companies.firstWhere(
      (c) => c.name.toLowerCase() == targetCompany.toLowerCase(),
      orElse: () => _companies.first,
    );

    final requirements = company.roleRequirements[targetRole];
    if (requirements != null) {
      return {
        'required': requirements.take(5).toList(),
        'recommended': requirements.skip(5).take(3).toList(),
        'niceToHave': requirements.skip(8).toList(),
      };
    }

    // Default requirements
    return _getDefaultRoleRequirements(targetRole);
  }

  /// Get default role requirements
  Map<String, List<String>> _getDefaultRoleRequirements(String targetRole) {
    final roleRequirements = {
      'Senior Software Engineer': {
        'required': [
          'Programming Languages',
          'System Design',
          'Algorithms',
          'Databases',
          'Git',
        ],
        'recommended': [
          'Cloud Computing',
          'Microservices',
          'Testing',
          'DevOps',
        ],
        'niceToHave': ['Machine Learning', 'Leadership', 'Mentoring'],
      },
      'Frontend Engineer': {
        'required': ['JavaScript', 'HTML', 'CSS', 'React', 'Git'],
        'recommended': [
          'TypeScript',
          'Testing',
          'Web Performance',
          'Accessibility',
        ],
        'niceToHave': ['Mobile Development', 'Design Systems', 'Animation'],
      },
      'Backend Engineer': {
        'required': [
          'Programming Languages',
          'Databases',
          'APIs',
          'Git',
          'System Design',
        ],
        'recommended': [
          'Cloud Computing',
          'Microservices',
          'Caching',
          'Security',
        ],
        'niceToHave': ['Machine Learning', 'DevOps', 'Monitoring'],
      },
    };

    return roleRequirements[targetRole] ??
        {
          'required': ['Programming', 'Problem Solving', 'Communication'],
          'recommended': ['Teamwork', 'Project Management'],
          'niceToHave': ['Leadership', 'Mentoring'],
        };
  }

  /// Analyze skill gaps for a career goal
  Future<List<SkillGap>> _analyzeSkillGaps(
    EnhancedCareerGoal goal,
    List<Skill> currentSkills,
  ) async {
    final gaps = <SkillGap>[];

    // Analyze required skills
    for (final requiredSkill in goal.requiredSkills) {
      final currentSkill = currentSkills.firstWhere(
        (skill) => skill.name.toLowerCase() == requiredSkill.toLowerCase(),
        orElse:
            () => Skill(
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
      final targetLevel = 4; // High level for required skills

      if (currentLevel < targetLevel) {
        gaps.add(
          SkillGap(
            skillName: requiredSkill,
            category: _getSkillCategory(requiredSkill),
            importance: 'High',
            currentLevel: currentLevel,
            targetLevel: targetLevel,
            estimatedHours: _estimateHoursToLevel(currentLevel, targetLevel),
            resources: _getResourcesForSkill(requiredSkill),
            isRequired: true,
            priority: currentLevel == 0 ? 'Critical' : 'High',
          ),
        );
      }
    }

    // Analyze recommended skills
    for (final recommendedSkill in goal.recommendedSkills) {
      final currentSkill = currentSkills.firstWhere(
        (skill) => skill.name.toLowerCase() == recommendedSkill.toLowerCase(),
        orElse:
            () => Skill(
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
      final targetLevel = 3; // Medium level for recommended skills

      if (currentLevel < targetLevel) {
        gaps.add(
          SkillGap(
            skillName: recommendedSkill,
            category: _getSkillCategory(recommendedSkill),
            importance: 'Medium',
            currentLevel: currentLevel,
            targetLevel: targetLevel,
            estimatedHours: _estimateHoursToLevel(currentLevel, targetLevel),
            resources: _getResourcesForSkill(recommendedSkill),
            isRequired: false,
            priority: 'Medium',
          ),
        );
      }
    }

    return gaps;
  }

  /// Calculate readiness percentage
  double _calculateReadinessPercentage(
    EnhancedCareerGoal goal,
    List<Skill> currentSkills,
  ) {
    if (goal.requiredSkills.isEmpty) return 0.0;

    int totalSkills = goal.requiredSkills.length;
    int completedSkills = 0;

    for (final requiredSkill in goal.requiredSkills) {
      final currentSkill = currentSkills.firstWhere(
        (skill) => skill.name.toLowerCase() == requiredSkill.toLowerCase(),
        orElse:
            () => Skill(
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
      if (currentLevel >= 3) {
        // At least intermediate level
        completedSkills++;
      }
    }

    return (completedSkills / totalSkills) * 100;
  }

  /// Generate AI recommendations for bridging skill gaps
  Future<List<AIRecommendation>> _generateAIRecommendations(
    EnhancedCareerGoal goal,
    List<SkillGap> skillGaps,
  ) async {
    final recommendations = <AIRecommendation>[];

    // Sort gaps by priority
    final sortedGaps = List<SkillGap>.from(skillGaps)..sort(
      (a, b) => _getPriorityValue(
        a.priority,
      ).compareTo(_getPriorityValue(b.priority)),
    );

    for (final gap in sortedGaps.take(5)) {
      // Top 5 gaps
      recommendations.add(
        AIRecommendation(
          id: 'rec_${gap.skillName}_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Master ${gap.skillName}',
          description:
              'Build proficiency in ${gap.skillName} to reach level ${gap.targetLevel}',
          type: _getRecommendationType(gap.skillName),
          estimatedHours: gap.estimatedHours,
          difficulty: _getDifficultyLevel(gap.currentLevel, gap.targetLevel),
          skills: [gap.skillName],
          priority: gap.priority,
          reason: 'Required for ${goal.targetRole} at ${goal.targetCompany}',
          resources: gap.resources,
        ),
      );
    }

    return recommendations;
  }

  /// Map skill status to numeric level
  int _mapSkillStatusToLevel(SkillStatus status) {
    switch (status) {
      case SkillStatus.notStarted:
        return 0;
      case SkillStatus.inProgress:
        return 2;
      case SkillStatus.completed:
        return 4;
    }
  }

  /// Get skill category
  String _getSkillCategory(String skillName) {
    final skillCategories = {
      'JavaScript': 'Programming Languages',
      'Python': 'Programming Languages',
      'Java': 'Programming Languages',
      'React': 'Frameworks',
      'Angular': 'Frameworks',
      'Vue.js': 'Frameworks',
      'System Design': 'System Design',
      'Algorithms': 'Algorithms',
      'Databases': 'Databases',
      'Git': 'Tools',
    };

    return skillCategories[skillName] ?? 'Other';
  }

  /// Estimate hours to reach target level
  int _estimateHoursToLevel(int currentLevel, int targetLevel) {
    final levelHours = {0: 0, 1: 20, 2: 40, 3: 80, 4: 120, 5: 200};
    return (levelHours[targetLevel] ?? 0) - (levelHours[currentLevel] ?? 0);
  }

  /// Get resources for skill
  List<String> _getResourcesForSkill(String skillName) {
    final resources = {
      'JavaScript': ['MDN Web Docs', 'JavaScript.info', 'Eloquent JavaScript'],
      'Python': ['Python.org', 'Real Python', 'Python Crash Course'],
      'React': ['React Docs', 'React Tutorial', 'React Router'],
      'System Design': [
        'System Design Primer',
        'High Scalability',
        'Designing Data-Intensive Applications',
      ],
    };

    return resources[skillName] ??
        ['Online Tutorials', 'Documentation', 'Practice Projects'];
  }

  /// Get priority value for sorting
  int _getPriorityValue(String priority) {
    switch (priority) {
      case 'Critical':
        return 0;
      case 'High':
        return 1;
      case 'Medium':
        return 2;
      case 'Low':
        return 3;
      default:
        return 4;
    }
  }

  /// Get recommendation type
  String _getRecommendationType(String skillName) {
    if (skillName.toLowerCase().contains('design')) return 'Course';
    if (skillName.toLowerCase().contains('algorithm')) return 'Practice';
    if (skillName.toLowerCase().contains('language')) return 'Course';
    return 'Project';
  }

  /// Get difficulty level
  String _getDifficultyLevel(int currentLevel, int targetLevel) {
    final gap = targetLevel - currentLevel;
    if (gap <= 1) return 'Beginner';
    if (gap <= 2) return 'Intermediate';
    return 'Advanced';
  }

  /// Save career goals to storage
  Future<void> _saveCareerGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = _careerGoals.map((goal) => goal.toJson()).toList();
      await prefs.setString(_goalsKey, jsonEncode(goalsJson));
    } catch (e) {
      debugPrint('Error saving career goals: $e');
    }
  }

  /// Save companies to storage
  Future<void> _saveCompanies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companiesJson =
          _companies.map((company) => company.toJson()).toList();
      await prefs.setString(_companiesKey, jsonEncode(companiesJson));
    } catch (e) {
      debugPrint('Error saving companies: $e');
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

  /// Get available companies
  List<Company> getAvailableCompanies() {
    return _companies;
  }

  /// Get available roles for a company
  List<String> getAvailableRolesForCompany(String companyName) {
    final company = _companies.firstWhere(
      (c) => c.name.toLowerCase() == companyName.toLowerCase(),
      orElse: () => _companies.first,
    );
    return company.roleRequirements.keys.toList();
  }

  /// Get available industries
  List<String> getAvailableIndustries() {
    return [
      'Technology',
      'Finance',
      'Healthcare',
      'E-commerce',
      'Gaming',
      'Education',
    ];
  }

  /// Get available experience levels
  List<String> getAvailableExperienceLevels() {
    return ['Entry Level', 'Mid Level', 'Senior Level', 'Lead', 'Principal'];
  }

  /// Update career goal
  Future<void> updateCareerGoal(EnhancedCareerGoal goal) async {
    final index = _careerGoals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _careerGoals[index] = goal;
      await _saveCareerGoals();
      notifyListeners();
    }
  }

  /// Delete career goal
  Future<void> deleteCareerGoal(String goalId) async {
    _careerGoals.removeWhere((goal) => goal.id == goalId);
    await _saveCareerGoals();
    notifyListeners();
  }
}
