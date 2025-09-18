import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/skill.dart';
import '../models/skill_status.dart';
import '../models/github_repository.dart';
import '../models/github_user.dart';

class SimpleStorageService {
  static Future<void> init() async {
    // Initialize SharedPreferences
    await SharedPreferences.getInstance();
  }

  // Skills management
  static Future<List<Skill>> getAllSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final skillsJson = prefs.getString('skills') ?? '[]';
    final skillsData = jsonDecode(skillsJson) as List;
    return skillsData.map((skill) => Skill.fromJson(skill)).toList();
  }

  static Future<void> addSkill(Skill skill) async {
    final skills = await getAllSkills();
    skills.add(skill);
    await _saveSkills(skills);
  }

  static Future<void> updateSkill(Skill skill) async {
    final skills = await getAllSkills();
    final index = skills.indexWhere((s) => s.id == skill.id);
    if (index != -1) {
      skills[index] = skill;
    } else {
      skills.add(skill);
    }
    await _saveSkills(skills);
  }

  static Future<void> deleteSkill(String skillId) async {
    final skills = await getAllSkills();
    skills.removeWhere((s) => s.id == skillId);
    await _saveSkills(skills);
  }

  static Future<Skill?> getSkill(String skillId) async {
    final skills = await getAllSkills();
    try {
      return skills.firstWhere((s) => s.id == skillId);
    } catch (e) {
      return null;
    }
  }

  // GitHub repositories management
  static Future<List<GitHubRepository>> getAllRepositories() async {
    final prefs = await SharedPreferences.getInstance();
    final reposJson = prefs.getString('repositories') ?? '[]';
    final reposData = jsonDecode(reposJson) as List;
    return reposData.map((repo) => GitHubRepository.fromJson(repo)).toList();
  }

  static Future<void> addRepository(GitHubRepository repository) async {
    final repos = await getAllRepositories();
    repos.add(repository);
    await _saveRepositories(repos);
  }

  static Future<void> updateRepository(GitHubRepository repository) async {
    final repos = await getAllRepositories();
    final index = repos.indexWhere((r) => r.id == repository.id);
    if (index != -1) {
      repos[index] = repository;
    } else {
      repos.add(repository);
    }
    await _saveRepositories(repos);
  }

  static Future<void> deleteRepository(int repositoryId) async {
    final repos = await getAllRepositories();
    repos.removeWhere((r) => r.id == repositoryId);
    await _saveRepositories(repos);
  }

  static Future<GitHubRepository?> getRepository(int repositoryId) async {
    final repos = await getAllRepositories();
    try {
      return repos.firstWhere((r) => r.id == repositoryId);
    } catch (e) {
      return null;
    }
  }

  // GitHub user management
  static Future<GitHubUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      return GitHubUser.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<void> setCurrentUser(GitHubUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toJson()));
  }

  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('skills');
    await prefs.remove('repositories');
    await prefs.remove('current_user');
  }

  // Get statistics
  static Future<Map<String, int>> getSkillsStatistics() async {
    final skills = await getAllSkills();
    return {
      'total': skills.length,
      'completed':
          skills.where((s) => s.status == SkillStatus.completed).length,
      'inProgress':
          skills.where((s) => s.status == SkillStatus.inProgress).length,
      'notStarted':
          skills.where((s) => s.status == SkillStatus.notStarted).length,
    };
  }

  static Future<Map<String, int>> getRepositoriesStatistics() async {
    final repos = await getAllRepositories();
    return {
      'total': repos.length,
      'public': repos.where((r) => !r.isPrivate).length,
      'private': repos.where((r) => r.isPrivate).length,
    };
  }

  // Private helper methods
  static Future<void> _saveSkills(List<Skill> skills) async {
    final prefs = await SharedPreferences.getInstance();
    final skillsJson = skills.map((s) => s.toJson()).toList();
    await prefs.setString('skills', jsonEncode(skillsJson));
  }

  static Future<void> _saveRepositories(List<GitHubRepository> repos) async {
    final prefs = await SharedPreferences.getInstance();
    final reposJson = repos.map((r) => r.toJson()).toList();
    await prefs.setString('repositories', jsonEncode(reposJson));
  }
}
