import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/skill.dart';
import '../models/skill_status.dart';
import '../models/github_repository.dart';
import '../models/github_user.dart';
import '../models/repo_status.dart';

class StorageService {
  static late Box<Skill> _skillsBox;
  static late Box<GitHubRepository> _repositoriesBox;
  static late Box<GitHubUser> _userBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(SkillAdapter());
    Hive.registerAdapter(SkillCategoryAdapter());
    Hive.registerAdapter(SkillStatusAdapter());
    Hive.registerAdapter(SkillProjectAdapter());
    Hive.registerAdapter(GitHubRepositoryAdapter());
    Hive.registerAdapter(GitHubUserAdapter());
    Hive.registerAdapter(RepoStatusAdapter());
    Hive.registerAdapter(ProjectStatusAdapter());
    
    // Open boxes
    _skillsBox = await Hive.openBox<Skill>('skills');
    _repositoriesBox = await Hive.openBox<GitHubRepository>('repositories');
    _userBox = await Hive.openBox<GitHubUser>('user');
  }

  // Skills management
  static List<Skill> getAllSkills() {
    return _skillsBox.values.toList();
  }

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

  // GitHub repositories management
  static List<GitHubRepository> getAllRepositories() {
    return _repositoriesBox.values.toList();
  }

  static Future<void> addRepository(GitHubRepository repository) async {
    await _repositoriesBox.put(repository.id, repository);
  }

  static Future<void> updateRepository(GitHubRepository repository) async {
    await _repositoriesBox.put(repository.id, repository);
  }

  static Future<void> deleteRepository(int repositoryId) async {
    await _repositoriesBox.delete(repositoryId);
  }

  static GitHubRepository? getRepository(int repositoryId) {
    return _repositoriesBox.get(repositoryId);
  }

  // GitHub user management
  static GitHubUser? getCurrentUser() {
    return _userBox.get('current_user');
  }

  static Future<void> setCurrentUser(GitHubUser user) async {
    await _userBox.put('current_user', user);
  }

  static Future<void> clearCurrentUser() async {
    await _userBox.delete('current_user');
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await _skillsBox.clear();
    await _repositoriesBox.clear();
    await _userBox.clear();
  }

  // Get statistics
  static Map<String, int> getSkillsStatistics() {
    final skills = getAllSkills();
    return {
      'total': skills.length,
      'completed': skills.where((s) => s.status == SkillStatus.completed).length,
      'inProgress': skills.where((s) => s.status == SkillStatus.inProgress).length,
      'notStarted': skills.where((s) => s.status == SkillStatus.notStarted).length,
    };
  }

  static Map<String, int> getRepositoriesStatistics() {
    final repos = getAllRepositories();
    return {
      'total': repos.length,
      'public': repos.where((r) => !r.isPrivate).length,
      'private': repos.where((r) => r.isPrivate).length,
    };
  }
}