import 'package:hive_flutter/hive_flutter.dart';
import '../models/skill.dart';
import '../models/skill_category.dart';
import '../models/skill_status.dart';
import '../models/skill_status_adapter.dart';
import '../models/skill_category_adapter.dart';
import '../models/skill_project.dart';

class StorageService {
  static const String _skillsBoxName = 'skills';
  static const String _settingsBoxName = 'settings';

  static late Box<Skill> _skillsBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(SkillAdapter());
    Hive.registerAdapter(SkillStatusAdapter());
    Hive.registerAdapter(SkillCategoryAdapter());
    Hive.registerAdapter(SkillProjectAdapter());

    // Open boxes
    _skillsBox = await Hive.openBox<Skill>(_skillsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    // Initialize with default skills if empty
    if (_skillsBox.isEmpty) {
      await _initializeDefaultSkills();
    }
  }

  static Future<void> _initializeDefaultSkills() async {
    final defaultSkills = _getDefaultSkills();
    for (final skill in defaultSkills) {
      await _skillsBox.put(skill.id, skill);
    }
  }

  static List<Skill> _getDefaultSkills() {
    final now = DateTime.now();

    return [
      // Programming Languages
      Skill(
        id: 'dart',
        name: 'Dart',
        description:
            'Modern programming language for mobile, web, and desktop development',
        category: SkillCategory.programmingLanguages,
        createdAt: now,
        priority: 5,
        tags: ['mobile', 'web', 'flutter'],
        projects: [
          SkillProject(
            id: 'dart-basics',
            title: 'Dart Fundamentals',
            description:
                'Build a command-line calculator with classes, inheritance, and error handling',
            difficulty: 'Beginner',
            requirements: [
              'Create classes for operations',
              'Implement inheritance',
              'Add error handling',
              'Write unit tests',
            ],
            estimatedHours: 8,
          ),
          SkillProject(
            id: 'dart-oop',
            title: 'Object-Oriented Programming',
            description:
                'Create a library management system with proper OOP principles',
            difficulty: 'Intermediate',
            requirements: [
              'Design class hierarchy',
              'Implement interfaces',
              'Use generics',
              'Apply SOLID principles',
            ],
            estimatedHours: 16,
          ),
          SkillProject(
            id: 'dart-async',
            title: 'Async Programming',
            description: 'Build a weather app with async/await and streams',
            difficulty: 'Advanced',
            requirements: [
              'Use Future and Stream',
              'Handle async errors',
              'Implement reactive programming',
              'Add caching',
            ],
            estimatedHours: 24,
          ),
        ],
      ),
      Skill(
        id: 'javascript',
        name: 'JavaScript',
        description:
            'The language of the web, essential for frontend and backend development',
        category: SkillCategory.programmingLanguages,
        createdAt: now,
        priority: 5,
        tags: ['web', 'frontend', 'backend'],
      ),
      Skill(
        id: 'typescript',
        name: 'TypeScript',
        description:
            'JavaScript with static type checking for better code quality',
        category: SkillCategory.programmingLanguages,
        createdAt: now,
        priority: 4,
        tags: ['web', 'types', 'javascript'],
      ),
      Skill(
        id: 'python',
        name: 'Python',
        description:
            'Versatile language for web development, data science, and automation',
        category: SkillCategory.programmingLanguages,
        createdAt: now,
        priority: 4,
        tags: ['backend', 'data-science', 'automation'],
      ),
      Skill(
        id: 'java',
        name: 'Java',
        description: 'Enterprise-grade language for large-scale applications',
        category: SkillCategory.programmingLanguages,
        createdAt: now,
        priority: 3,
        tags: ['enterprise', 'backend', 'android'],
      ),
      Skill(
        id: 'go',
        name: 'Go',
        description:
            'Efficient language for microservices and cloud-native applications',
        category: SkillCategory.programmingLanguages,
        createdAt: now,
        priority: 3,
        tags: ['backend', 'microservices', 'cloud'],
      ),

      // Frameworks
      Skill(
        id: 'flutter',
        name: 'Flutter',
        description: 'UI toolkit for building natively compiled applications',
        category: SkillCategory.frameworks,
        createdAt: now,
        priority: 5,
        tags: ['mobile', 'ui', 'cross-platform'],
      ),
      Skill(
        id: 'react',
        name: 'React',
        description: 'JavaScript library for building user interfaces',
        category: SkillCategory.frameworks,
        createdAt: now,
        priority: 5,
        tags: ['web', 'frontend', 'ui'],
      ),
      Skill(
        id: 'nodejs',
        name: 'Node.js',
        description: 'JavaScript runtime for server-side development',
        category: SkillCategory.frameworks,
        createdAt: now,
        priority: 4,
        tags: ['backend', 'javascript', 'server'],
      ),
      Skill(
        id: 'express',
        name: 'Express.js',
        description: 'Fast, unopinionated web framework for Node.js',
        category: SkillCategory.frameworks,
        createdAt: now,
        priority: 4,
        tags: ['backend', 'api', 'web'],
      ),
      Skill(
        id: 'nextjs',
        name: 'Next.js',
        description: 'React framework for production with SSR and SSG',
        category: SkillCategory.frameworks,
        createdAt: now,
        priority: 4,
        tags: ['react', 'ssr', 'web'],
      ),

      // Databases
      Skill(
        id: 'postgresql',
        name: 'PostgreSQL',
        description: 'Advanced open-source relational database',
        category: SkillCategory.databases,
        createdAt: now,
        priority: 4,
        tags: ['sql', 'relational', 'database'],
      ),
      Skill(
        id: 'mongodb',
        name: 'MongoDB',
        description: 'NoSQL document database for modern applications',
        category: SkillCategory.databases,
        createdAt: now,
        priority: 4,
        tags: ['nosql', 'document', 'database'],
      ),
      Skill(
        id: 'redis',
        name: 'Redis',
        description: 'In-memory data structure store for caching and messaging',
        category: SkillCategory.databases,
        createdAt: now,
        priority: 3,
        tags: ['cache', 'memory', 'database'],
      ),

      // Testing
      Skill(
        id: 'unit-testing',
        name: 'Unit Testing',
        description: 'Testing individual components in isolation',
        category: SkillCategory.testing,
        createdAt: now,
        priority: 5,
        tags: ['testing', 'quality', 'tdd'],
      ),
      Skill(
        id: 'integration-testing',
        name: 'Integration Testing',
        description: 'Testing the interaction between different components',
        category: SkillCategory.testing,
        createdAt: now,
        priority: 4,
        tags: ['testing', 'integration', 'quality'],
      ),
      Skill(
        id: 'e2e-testing',
        name: 'End-to-End Testing',
        description: 'Testing complete user workflows from start to finish',
        category: SkillCategory.testing,
        createdAt: now,
        priority: 4,
        tags: ['testing', 'e2e', 'automation'],
      ),

      // DevOps
      Skill(
        id: 'docker',
        name: 'Docker',
        description: 'Containerization platform for consistent deployments',
        category: SkillCategory.devops,
        createdAt: now,
        priority: 4,
        tags: ['containers', 'deployment', 'devops'],
      ),
      Skill(
        id: 'kubernetes',
        name: 'Kubernetes',
        description:
            'Container orchestration platform for scalable applications',
        category: SkillCategory.devops,
        createdAt: now,
        priority: 3,
        tags: ['orchestration', 'containers', 'scaling'],
      ),
      Skill(
        id: 'ci-cd',
        name: 'CI/CD',
        description:
            'Continuous Integration and Continuous Deployment practices',
        category: SkillCategory.devops,
        createdAt: now,
        priority: 4,
        tags: ['automation', 'deployment', 'quality'],
      ),

      // System Design
      Skill(
        id: 'microservices',
        name: 'Microservices Architecture',
        description:
            'Designing applications as a collection of loosely coupled services',
        category: SkillCategory.systemDesign,
        createdAt: now,
        priority: 4,
        tags: ['architecture', 'scalability', 'services'],
      ),
      Skill(
        id: 'api-design',
        name: 'API Design',
        description:
            'Designing RESTful and GraphQL APIs for optimal developer experience',
        category: SkillCategory.systemDesign,
        createdAt: now,
        priority: 4,
        tags: ['api', 'rest', 'graphql'],
      ),
      Skill(
        id: 'scalability',
        name: 'Scalability Patterns',
        description: 'Designing systems that can handle growing loads',
        category: SkillCategory.systemDesign,
        createdAt: now,
        priority: 3,
        tags: ['scalability', 'performance', 'architecture'],
      ),

      // Soft Skills
      Skill(
        id: 'communication',
        name: 'Technical Communication',
        description:
            'Effectively communicating technical concepts to various audiences',
        category: SkillCategory.softSkills,
        createdAt: now,
        priority: 5,
        tags: ['communication', 'presentation', 'documentation'],
      ),
      Skill(
        id: 'mentoring',
        name: 'Mentoring & Leadership',
        description: 'Guiding and developing other developers',
        category: SkillCategory.softSkills,
        createdAt: now,
        priority: 4,
        tags: ['leadership', 'mentoring', 'team'],
      ),
      Skill(
        id: 'code-review',
        name: 'Code Review',
        description:
            'Providing constructive feedback on code quality and design',
        category: SkillCategory.softSkills,
        createdAt: now,
        priority: 4,
        tags: ['review', 'quality', 'collaboration'],
      ),
    ];
  }

  // Skills CRUD operations
  static Future<void> addSkill(Skill skill) async {
    await _skillsBox.put(skill.id, skill);
  }

  static Future<void> updateSkill(Skill skill) async {
    await _skillsBox.put(skill.id, skill);
  }

  static Future<void> deleteSkill(String skillId) async {
    await _skillsBox.delete(skillId);
  }

  static Skill? getSkill(String skillId) {
    return _skillsBox.get(skillId);
  }

  static List<Skill> getAllSkills() {
    return _skillsBox.values.toList();
  }

  static List<Skill> getSkillsByCategory(SkillCategory category) {
    return _skillsBox.values
        .where((skill) => skill.category == category)
        .toList();
  }

  static List<Skill> getSkillsByStatus(SkillStatus status) {
    return _skillsBox.values.where((skill) => skill.status == status).toList();
  }

  // Settings
  static Future<void> setThemeMode(bool isDarkMode) async {
    await _settingsBox.put('isDarkMode', isDarkMode);
  }

  static bool getThemeMode() {
    return _settingsBox.get('isDarkMode', defaultValue: true);
  }

  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _settingsBox.put('isFirstLaunch', isFirstLaunch);
  }

  static bool getFirstLaunch() {
    return _settingsBox.get('isFirstLaunch', defaultValue: true);
  }

  static Future<void> close() async {
    await _skillsBox.close();
    await _settingsBox.close();
  }
}
