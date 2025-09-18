import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/skill.dart';
import '../models/skill_category.dart';
import '../models/skill_status.dart';
import '../models/github_repository.dart';
import '../services/github_insights_service.dart';

class LearningModule {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> skills;
  final List<String> prerequisites;
  final int estimatedHours;
  final String difficulty; // Beginner, Intermediate, Advanced
  final String type; // Theory, Practice, Project
  final List<LearningResource> resources;
  final List<LearningTask> tasks;
  final bool isCompleted;
  final double progress; // 0.0 to 1.0
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;

  LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.skills,
    required this.prerequisites,
    required this.estimatedHours,
    required this.difficulty,
    required this.type,
    required this.resources,
    required this.tasks,
    this.isCompleted = false,
    this.progress = 0.0,
    this.startedAt,
    this.completedAt,
    this.notes,
  });

  LearningModule copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    List<String>? skills,
    List<String>? prerequisites,
    int? estimatedHours,
    String? difficulty,
    String? type,
    List<LearningResource>? resources,
    List<LearningTask>? tasks,
    bool? isCompleted,
    double? progress,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return LearningModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      skills: skills ?? this.skills,
      prerequisites: prerequisites ?? this.prerequisites,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      resources: resources ?? this.resources,
      tasks: tasks ?? this.tasks,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'skills': skills,
      'prerequisites': prerequisites,
      'estimatedHours': estimatedHours,
      'difficulty': difficulty,
      'type': type,
      'resources': resources.map((r) => r.toJson()).toList(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'isCompleted': isCompleted,
      'progress': progress,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    return LearningModule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      skills: List<String>.from(json['skills']),
      prerequisites: List<String>.from(json['prerequisites']),
      estimatedHours: json['estimatedHours'],
      difficulty: json['difficulty'],
      type: json['type'],
      resources: (json['resources'] as List)
          .map((r) => LearningResource.fromJson(r))
          .toList(),
      tasks: (json['tasks'] as List)
          .map((t) => LearningTask.fromJson(t))
          .toList(),
      isCompleted: json['isCompleted'] ?? false,
      progress: (json['progress'] ?? 0.0).toDouble(),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
    );
  }
}

class LearningResource {
  final String title;
  final String url;
  final String type; // Video, Article, Documentation, Course, Book
  final int estimatedMinutes;
  final String description;

  LearningResource({
    required this.title,
    required this.url,
    required this.type,
    required this.estimatedMinutes,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
      'estimatedMinutes': estimatedMinutes,
      'description': description,
    };
  }

  factory LearningResource.fromJson(Map<String, dynamic> json) {
    return LearningResource(
      title: json['title'],
      url: json['url'],
      type: json['type'],
      estimatedMinutes: json['estimatedMinutes'],
      description: json['description'],
    );
  }
}

class LearningTask {
  final String id;
  final String title;
  final String description;
  final String type; // Reading, Coding, Project, Quiz
  final int estimatedMinutes;
  final bool isCompleted;
  final String? instructions;
  final List<String>? deliverables;

  LearningTask({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.estimatedMinutes,
    this.isCompleted = false,
    this.instructions,
    this.deliverables,
  });

  LearningTask copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? estimatedMinutes,
    bool? isCompleted,
    String? instructions,
    List<String>? deliverables,
  }) {
    return LearningTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      instructions: instructions ?? this.instructions,
      deliverables: deliverables ?? this.deliverables,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'estimatedMinutes': estimatedMinutes,
      'isCompleted': isCompleted,
      'instructions': instructions,
      'deliverables': deliverables,
    };
  }

  factory LearningTask.fromJson(Map<String, dynamic> json) {
    return LearningTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      estimatedMinutes: json['estimatedMinutes'],
      isCompleted: json['isCompleted'] ?? false,
      instructions: json['instructions'],
      deliverables: json['deliverables'] != null
          ? List<String>.from(json['deliverables'])
          : null,
    );
  }
}

class PersonalizedRoadmap {
  final String id;
  final String title;
  final String description;
  final String targetRole;
  final List<LearningModule> modules;
  final int totalEstimatedHours;
  final String difficulty;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double overallProgress;
  final List<String> missingSkills;
  final List<String> recommendedSkills;

  PersonalizedRoadmap({
    required this.id,
    required this.title,
    required this.description,
    required this.targetRole,
    required this.modules,
    required this.totalEstimatedHours,
    required this.difficulty,
    required this.createdAt,
    this.completedAt,
    required this.overallProgress,
    required this.missingSkills,
    required this.recommendedSkills,
  });

  PersonalizedRoadmap copyWith({
    String? id,
    String? title,
    String? description,
    String? targetRole,
    List<LearningModule>? modules,
    int? totalEstimatedHours,
    String? difficulty,
    DateTime? createdAt,
    DateTime? completedAt,
    double? overallProgress,
    List<String>? missingSkills,
    List<String>? recommendedSkills,
  }) {
    return PersonalizedRoadmap(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetRole: targetRole ?? this.targetRole,
      modules: modules ?? this.modules,
      totalEstimatedHours: totalEstimatedHours ?? this.totalEstimatedHours,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      overallProgress: overallProgress ?? this.overallProgress,
      missingSkills: missingSkills ?? this.missingSkills,
      recommendedSkills: recommendedSkills ?? this.recommendedSkills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetRole': targetRole,
      'modules': modules.map((m) => m.toJson()).toList(),
      'totalEstimatedHours': totalEstimatedHours,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'overallProgress': overallProgress,
      'missingSkills': missingSkills,
      'recommendedSkills': recommendedSkills,
    };
  }

  factory PersonalizedRoadmap.fromJson(Map<String, dynamic> json) {
    return PersonalizedRoadmap(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetRole: json['targetRole'],
      modules: (json['modules'] as List)
          .map((m) => LearningModule.fromJson(m))
          .toList(),
      totalEstimatedHours: json['totalEstimatedHours'],
      difficulty: json['difficulty'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      overallProgress: (json['overallProgress'] ?? 0.0).toDouble(),
      missingSkills: List<String>.from(json['missingSkills']),
      recommendedSkills: List<String>.from(json['recommendedSkills']),
    );
  }
}

class AIAssistantService extends ChangeNotifier {
  // AI API Configuration - You can switch between different providers
  static const String _openaiApiKey = 'your-openai-api-key'; // Replace with actual key
  static const String _geminiApiKey = 'your-gemini-api-key'; // Replace with actual key
  
  static const String _openaiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Use Gemini by default (free tier available)
  static const String _currentProvider = 'gemini';

  List<PersonalizedRoadmap> _roadmaps = [];
  bool _isGenerating = false;
  String? _errorMessage;

  // Getters
  List<PersonalizedRoadmap> get roadmaps => _roadmaps;
  bool get isLoading => _isGenerating;
  String? get errorMessage => _errorMessage;

  /// Generate a personalized learning roadmap using AI
  Future<PersonalizedRoadmap?> generatePersonalizedRoadmap({
    required String targetRole,
    required List<Skill> currentSkills,
    required List<GitHubRepository> repositories,
    String experienceLevel = 'Beginner',
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Analyze current skills and repositories
      final skillAnalysis = _analyzeCurrentSkills(currentSkills);
      final repoAnalysis = await _analyzeRepositories(repositories);
      
      // Generate AI-powered roadmap
      final roadmap = await _generateAIRoadmap(
        targetRole: targetRole,
        currentSkills: currentSkills,
        repositories: repositories,
        skillAnalysis: skillAnalysis,
        repoAnalysis: repoAnalysis,
        experienceLevel: experienceLevel,
      );

      _roadmaps.add(roadmap);
      notifyListeners();
      return roadmap;
    } catch (e) {
      _errorMessage = 'Failed to generate personalized roadmap: $e';
      debugPrint('Error generating roadmap: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Analyze current skills to identify strengths and gaps
  Map<String, dynamic> _analyzeCurrentSkills(List<Skill> skills) {
    final completedSkills = skills.where((s) => s.status == SkillStatus.completed).toList();
    final inProgressSkills = skills.where((s) => s.status == SkillStatus.inProgress).toList();
    final notStartedSkills = skills.where((s) => s.status == SkillStatus.notStarted).toList();

    final skillCategories = <String, int>{};
    for (final skill in completedSkills) {
      skillCategories[skill.category.displayName] = (skillCategories[skill.category.displayName] ?? 0) + 1;
    }

    return {
      'totalSkills': skills.length,
      'completedSkills': completedSkills.length,
      'inProgressSkills': inProgressSkills.length,
      'notStartedSkills': notStartedSkills.length,
      'skillCategories': skillCategories,
      'completedSkillNames': completedSkills.map((s) => s.name).toList(),
      'inProgressSkillNames': inProgressSkills.map((s) => s.name).toList(),
      'notStartedSkillNames': notStartedSkills.map((s) => s.name).toList(),
    };
  }

  /// Analyze GitHub repositories for insights
  Future<Map<String, dynamic>> _analyzeRepositories(List<GitHubRepository> repositories) async {
    if (repositories.isEmpty) {
      return {
        'totalRepos': 0,
        'languages': <String, int>{},
        'topLanguages': <String>[],
        'repoTypes': <String, int>{},
        'recentActivity': false,
        'averageStars': 0.0,
      };
    }

    final languages = <String, int>{};
    final repoTypes = <String, int>{};
    int totalStars = 0;
    bool hasRecentActivity = false;

    for (final repo in repositories) {
      // Count languages
      if (repo.language != null && repo.language!.isNotEmpty) {
        languages[repo.language!] = (languages[repo.language!] ?? 0) + 1;
      }

      // Categorize repository types
      final repoType = _categorizeRepository(repo);
      repoTypes[repoType] = (repoTypes[repoType] ?? 0) + 1;

      // Count stars
      totalStars += repo.stars;

      // Check for recent activity (last 30 days)
      if (repo.pushedAt != null) {
        final daysSincePush = DateTime.now().difference(repo.pushedAt!).inDays;
        if (daysSincePush <= 30) {
          hasRecentActivity = true;
        }
      }
    }

    // Sort languages by frequency
    final sortedLanguages = languages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topLanguages = sortedLanguages.take(5).map((e) => e.key).toList();

    return {
      'totalRepos': repositories.length,
      'languages': languages,
      'topLanguages': topLanguages,
      'repoTypes': repoTypes,
      'recentActivity': hasRecentActivity,
      'averageStars': repositories.isNotEmpty ? totalStars / repositories.length : 0.0,
    };
  }

  /// Categorize repository by its characteristics
  String _categorizeRepository(GitHubRepository repo) {
    if (repo.name.toLowerCase().contains('frontend') || 
        repo.name.toLowerCase().contains('ui') ||
        repo.name.toLowerCase().contains('web')) {
      return 'Frontend';
    } else if (repo.name.toLowerCase().contains('backend') ||
               repo.name.toLowerCase().contains('api') ||
               repo.name.toLowerCase().contains('server')) {
      return 'Backend';
    } else if (repo.name.toLowerCase().contains('mobile') ||
               repo.name.toLowerCase().contains('app')) {
      return 'Mobile';
    } else if (repo.name.toLowerCase().contains('data') ||
               repo.name.toLowerCase().contains('ml') ||
               repo.name.toLowerCase().contains('ai')) {
      return 'Data Science';
    } else if (repo.name.toLowerCase().contains('devops') ||
               repo.name.toLowerCase().contains('docker') ||
               repo.name.toLowerCase().contains('kubernetes')) {
      return 'DevOps';
    } else {
      return 'General';
    }
  }

  /// Generate AI-powered roadmap using external API
  Future<PersonalizedRoadmap> _generateAIRoadmap({
    required String targetRole,
    required List<Skill> currentSkills,
    required List<GitHubRepository> repositories,
    required Map<String, dynamic> skillAnalysis,
    required Map<String, dynamic> repoAnalysis,
    required String experienceLevel,
  }) async {
    final now = DateTime.now();
    final roadmapId = 'roadmap_${now.millisecondsSinceEpoch}';

    // Create prompt for AI
    final prompt = _createAIPrompt(
      targetRole: targetRole,
      skillAnalysis: skillAnalysis,
      repoAnalysis: repoAnalysis,
      experienceLevel: experienceLevel,
    );

    try {
      // Call AI API
      final aiResponse = await _callAIAPI(prompt);
      
      // Parse AI response and create roadmap
      final roadmap = _parseAIResponse(
        aiResponse: aiResponse,
        roadmapId: roadmapId,
        targetRole: targetRole,
        skillAnalysis: skillAnalysis,
        repoAnalysis: repoAnalysis,
        experienceLevel: experienceLevel,
      );

      return roadmap;
    } catch (e) {
      debugPrint('AI API call failed, using fallback: $e');
      // Fallback to rule-based generation
      return _generateFallbackRoadmap(
        roadmapId: roadmapId,
        targetRole: targetRole,
        skillAnalysis: skillAnalysis,
        repoAnalysis: repoAnalysis,
        experienceLevel: experienceLevel,
      );
    }
  }

  /// Create prompt for AI API
  String _createAIPrompt({
    required String targetRole,
    required Map<String, dynamic> skillAnalysis,
    required Map<String, dynamic> repoAnalysis,
    required String experienceLevel,
  }) {
    return '''
You are an expert career advisor and learning path specialist. Generate a personalized learning roadmap for someone who wants to become a $targetRole.

CURRENT SKILLS ANALYSIS:
- Total skills: ${skillAnalysis['totalSkills']}
- Completed skills: ${skillAnalysis['completedSkills']} (${skillAnalysis['completedSkillNames']})
- In progress skills: ${skillAnalysis['inProgressSkills']} (${skillAnalysis['inProgressSkillNames']})
- Not started skills: ${skillAnalysis['notStartedSkills']} (${skillAnalysis['notStartedSkillNames']})
- Skill categories: ${skillAnalysis['skillCategories']}

GITHUB REPOSITORY INSIGHTS:
- Total repositories: ${repoAnalysis['totalRepos']}
- Top languages: ${repoAnalysis['topLanguages']}
- Repository types: ${repoAnalysis['repoTypes']}
- Recent activity: ${repoAnalysis['recentActivity']}
- Average stars: ${repoAnalysis['averageStars']}

EXPERIENCE LEVEL: $experienceLevel

Please generate a detailed learning roadmap with the following structure:
1. Identify 5-8 missing skills needed for $targetRole
2. Create 6-10 learning modules that address these gaps
3. Each module should include:
   - Title and description
   - Category (Programming, Framework, Tool, Concept, Project)
   - Skills it teaches
   - Prerequisites
   - Estimated hours (2-20 hours per module)
   - Difficulty level
   - Type (Theory, Practice, Project)
   - 3-5 learning resources (with URLs)
   - 2-4 practical tasks

Format the response as JSON with this structure:
{
  "missingSkills": ["skill1", "skill2", ...],
  "recommendedSkills": ["skill1", "skill2", ...],
  "modules": [
    {
      "title": "Module Title",
      "description": "Detailed description",
      "category": "Programming",
      "skills": ["skill1", "skill2"],
      "prerequisites": ["prereq1"],
      "estimatedHours": 8,
      "difficulty": "Intermediate",
      "type": "Practice",
      "resources": [
        {
          "title": "Resource Title",
          "url": "https://example.com",
          "type": "Video",
          "estimatedMinutes": 60,
          "description": "Resource description"
        }
      ],
      "tasks": [
        {
          "id": "task1",
          "title": "Task Title",
          "description": "Task description",
          "type": "Coding",
          "estimatedMinutes": 120,
          "instructions": "Step-by-step instructions",
          "deliverables": ["deliverable1", "deliverable2"]
        }
      ]
    }
  ]
}
''';
  }

  /// Call AI API (Gemini or OpenAI)
  Future<String> _callAIAPI(String prompt) async {
    if (_currentProvider == 'gemini') {
      return await _callGeminiAPI(prompt);
    } else {
      return await _callOpenAIAPI(prompt);
    }
  }

  /// Call Gemini API
  Future<String> _callGeminiAPI(String prompt) async {
    final response = await http.post(
      Uri.parse('$_geminiUrl?key=$_geminiApiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 8192,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Call OpenAI API
  Future<String> _callOpenAIAPI(String prompt) async {
    final response = await http.post(
      Uri.parse(_openaiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openaiApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert career advisor and learning path specialist. Always respond with valid JSON only.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'temperature': 0.7,
        'max_tokens': 4000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Parse AI response and create roadmap
  PersonalizedRoadmap _parseAIResponse({
    required String aiResponse,
    required String roadmapId,
    required String targetRole,
    required Map<String, dynamic> skillAnalysis,
    required Map<String, dynamic> repoAnalysis,
    required String experienceLevel,
  }) {
    try {
      // Clean the response (remove markdown formatting if present)
      String cleanResponse = aiResponse;
      if (cleanResponse.contains('```json')) {
        cleanResponse = cleanResponse.split('```json')[1].split('```')[0];
      } else if (cleanResponse.contains('```')) {
        cleanResponse = cleanResponse.split('```')[1].split('```')[0];
      }

      final data = jsonDecode(cleanResponse);
      final modules = <LearningModule>[];

      // Create learning modules from AI response
      for (int i = 0; i < (data['modules'] as List).length; i++) {
        final moduleData = data['modules'][i];
        final moduleId = '${roadmapId}_module_$i';
        
        final resources = <LearningResource>[];
        for (final resourceData in moduleData['resources']) {
          resources.add(LearningResource(
            title: resourceData['title'],
            url: resourceData['url'],
            type: resourceData['type'],
            estimatedMinutes: resourceData['estimatedMinutes'],
            description: resourceData['description'],
          ));
        }

        final tasks = <LearningTask>[];
        for (int j = 0; j < (moduleData['tasks'] as List).length; j++) {
          final taskData = moduleData['tasks'][j];
          tasks.add(LearningTask(
            id: '${moduleId}_task_$j',
            title: taskData['title'],
            description: taskData['description'],
            type: taskData['type'],
            estimatedMinutes: taskData['estimatedMinutes'],
            instructions: taskData['instructions'],
            deliverables: taskData['deliverables'] != null 
                ? List<String>.from(taskData['deliverables'])
                : null,
          ));
        }

        modules.add(LearningModule(
          id: moduleId,
          title: moduleData['title'],
          description: moduleData['description'],
          category: moduleData['category'],
          skills: List<String>.from(moduleData['skills']),
          prerequisites: List<String>.from(moduleData['prerequisites']),
          estimatedHours: moduleData['estimatedHours'],
          difficulty: moduleData['difficulty'],
          type: moduleData['type'],
          resources: resources,
          tasks: tasks,
        ));
      }

      final totalHours = modules.fold(0, (sum, module) => sum + module.estimatedHours);

      return PersonalizedRoadmap(
        id: roadmapId,
        title: 'Become a $targetRole - AI Personalized Path',
        description: 'A personalized learning roadmap generated by AI based on your current skills and GitHub activity.',
        targetRole: targetRole,
        modules: modules,
        totalEstimatedHours: totalHours,
        difficulty: experienceLevel,
        createdAt: DateTime.now(),
        overallProgress: 0.0,
        missingSkills: List<String>.from(data['missingSkills']),
        recommendedSkills: List<String>.from(data['recommendedSkills']),
      );
    } catch (e) {
      debugPrint('Error parsing AI response: $e');
      // Fallback to rule-based generation
      return _generateFallbackRoadmap(
        roadmapId: roadmapId,
        targetRole: targetRole,
        skillAnalysis: skillAnalysis,
        repoAnalysis: repoAnalysis,
        experienceLevel: experienceLevel,
      );
    }
  }

  /// Generate fallback roadmap when AI API fails
  PersonalizedRoadmap _generateFallbackRoadmap({
    required String roadmapId,
    required String targetRole,
    required Map<String, dynamic> skillAnalysis,
    required Map<String, dynamic> repoAnalysis,
    required String experienceLevel,
  }) {
    final modules = _getFallbackModules(targetRole, experienceLevel);
    final totalHours = modules.fold(0, (sum, module) => sum + module.estimatedHours);

    return PersonalizedRoadmap(
      id: roadmapId,
      title: 'Become a $targetRole - Structured Path',
      description: 'A structured learning roadmap based on industry best practices.',
      targetRole: targetRole,
      modules: modules,
      totalEstimatedHours: totalHours,
      difficulty: experienceLevel,
      createdAt: DateTime.now(),
      overallProgress: 0.0,
      missingSkills: _getMissingSkillsForRole(targetRole),
      recommendedSkills: _getRecommendedSkillsForRole(targetRole),
    );
  }

  /// Get fallback modules based on role
  List<LearningModule> _getFallbackModules(String targetRole, String experienceLevel) {
    final roleModules = {
      'Frontend Developer': [
        LearningModule(
          id: 'html_css_basics',
          title: 'HTML & CSS Fundamentals',
          description: 'Master the building blocks of web development',
          category: 'Web Development',
          skills: ['HTML', 'CSS', 'Responsive Design'],
          prerequisites: [],
          estimatedHours: 20,
          difficulty: 'Beginner',
          type: 'Theory',
          resources: [
            LearningResource(
              title: 'MDN HTML Tutorial',
              url: 'https://developer.mozilla.org/en-US/docs/Web/HTML',
              type: 'Documentation',
              estimatedMinutes: 180,
              description: 'Complete HTML reference and tutorial',
            ),
            LearningResource(
              title: 'CSS Grid Guide',
              url: 'https://css-tricks.com/snippets/css/complete-guide-grid/',
              type: 'Article',
              estimatedMinutes: 60,
              description: 'Comprehensive CSS Grid tutorial',
            ),
          ],
          tasks: [
            LearningTask(
              id: 'build_landing_page',
              title: 'Build a Landing Page',
              description: 'Create a responsive landing page using HTML and CSS',
              type: 'Project',
              estimatedMinutes: 240,
              instructions: 'Design and code a modern landing page with navigation, hero section, and footer',
              deliverables: ['HTML file', 'CSS file', 'Screenshots'],
            ),
          ],
        ),
        // Add more modules...
      ],
      // Add more roles...
    };

    return roleModules[targetRole] ?? roleModules['Frontend Developer']!;
  }

  /// Get missing skills for a role
  List<String> _getMissingSkillsForRole(String targetRole) {
    final roleSkills = {
      'Frontend Developer': ['React', 'JavaScript', 'CSS Grid', 'TypeScript'],
      'Backend Developer': ['Node.js', 'Python', 'SQL', 'Docker'],
      'Full Stack Developer': ['React', 'Node.js', 'MongoDB', 'Docker'],
    };

    return roleSkills[targetRole] ?? ['Problem Solving', 'Git', 'Communication'];
  }

  /// Get recommended skills for a role
  List<String> _getRecommendedSkillsForRole(String targetRole) {
    final roleSkills = {
      'Frontend Developer': ['Vue.js', 'SASS', 'Webpack', 'Testing'],
      'Backend Developer': ['Kubernetes', 'Redis', 'GraphQL', 'AWS'],
      'Full Stack Developer': ['Docker', 'AWS', 'Testing', 'CI/CD'],
    };

    return roleSkills[targetRole] ?? ['Project Management', 'Teamwork', 'Continuous Learning'];
  }

  /// Update module progress
  Future<void> updateModuleProgress(String roadmapId, String moduleId, double progress) async {
    final roadmapIndex = _roadmaps.indexWhere((r) => r.id == roadmapId);
    if (roadmapIndex != -1) {
      final moduleIndex = _roadmaps[roadmapIndex].modules.indexWhere((m) => m.id == moduleId);
      if (moduleIndex != -1) {
        final updatedModules = List<LearningModule>.from(_roadmaps[roadmapIndex].modules);
        updatedModules[moduleIndex] = updatedModules[moduleIndex].copyWith(
          progress: progress,
          isCompleted: progress >= 1.0,
          completedAt: progress >= 1.0 ? DateTime.now() : null,
        );

        _roadmaps[roadmapIndex] = _roadmaps[roadmapIndex].copyWith(
          modules: updatedModules,
          overallProgress: _calculateOverallProgress(updatedModules),
        );

        notifyListeners();
      }
    }
  }

  /// Calculate overall roadmap progress
  double _calculateOverallProgress(List<LearningModule> modules) {
    if (modules.isEmpty) return 0.0;
    final totalProgress = modules.fold(0.0, (sum, module) => sum + module.progress);
    return totalProgress / modules.length;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isGenerating = loading;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}