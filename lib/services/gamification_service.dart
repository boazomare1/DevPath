import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill.dart';
import '../models/github_repository.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int points;
  final DateTime earnedAt;
  final bool isEarned;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.points,
    required this.earnedAt,
    this.isEarned = false,
  });

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? category,
    int? points,
    DateTime? earnedAt,
    bool? isEarned,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      points: points ?? this.points,
      earnedAt: earnedAt ?? this.earnedAt,
      isEarned: isEarned ?? this.isEarned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category,
      'points': points,
      'earnedAt': earnedAt.toIso8601String(),
      'isEarned': isEarned,
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      category: json['category'],
      points: json['points'],
      earnedAt: DateTime.parse(json['earnedAt']),
      isEarned: json['isEarned'] ?? false,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final String category;
  final int progress;
  final int target;
  final bool isCompleted;
  final DateTime? completedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.category,
    required this.progress,
    required this.target,
    this.isCompleted = false,
    this.completedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? xpReward,
    String? category,
    int? progress,
    int? target,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      xpReward: xpReward ?? this.xpReward,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'xpReward': xpReward,
      'category': category,
      'progress': progress,
      'target': target,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      xpReward: json['xpReward'],
      category: json['category'],
      progress: json['progress'],
      target: json['target'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
    );
  }
}

class UserStats {
  final int totalXP;
  final int level;
  final int badgesEarned;
  final int achievementsCompleted;
  final int skillsLearned;
  final int repositoriesContributed;
  final int streakDays;
  final int dailyStreak;
  final int weeklyStreak;
  final int longestStreak;
  final DateTime lastActivity;
  final int totalSessions;
  final Map<String, int> categoryXP;
  final List<String> recentActivities;

  UserStats({
    required this.totalXP,
    required this.level,
    required this.badgesEarned,
    required this.achievementsCompleted,
    required this.skillsLearned,
    required this.repositoriesContributed,
    required this.streakDays,
    this.dailyStreak = 0,
    this.weeklyStreak = 0,
    this.longestStreak = 0,
    required this.lastActivity,
    this.totalSessions = 0,
    Map<String, int>? categoryXP,
    this.recentActivities = const [],
  }) : categoryXP = categoryXP ?? {};

  UserStats copyWith({
    int? totalXP,
    int? level,
    int? badgesEarned,
    int? achievementsCompleted,
    int? skillsLearned,
    int? repositoriesContributed,
    int? streakDays,
    int? dailyStreak,
    int? weeklyStreak,
    int? longestStreak,
    DateTime? lastActivity,
    int? totalSessions,
    Map<String, int>? categoryXP,
    List<String>? recentActivities,
  }) {
    return UserStats(
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      achievementsCompleted:
          achievementsCompleted ?? this.achievementsCompleted,
      skillsLearned: skillsLearned ?? this.skillsLearned,
      repositoriesContributed:
          repositoriesContributed ?? this.repositoriesContributed,
      streakDays: streakDays ?? this.streakDays,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      weeklyStreak: weeklyStreak ?? this.weeklyStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivity: lastActivity ?? this.lastActivity,
      totalSessions: totalSessions ?? this.totalSessions,
      categoryXP: categoryXP ?? this.categoryXP,
      recentActivities: recentActivities ?? this.recentActivities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXP': totalXP,
      'level': level,
      'badgesEarned': badgesEarned,
      'achievementsCompleted': achievementsCompleted,
      'skillsLearned': skillsLearned,
      'repositoriesContributed': repositoriesContributed,
      'streakDays': streakDays,
      'dailyStreak': dailyStreak,
      'weeklyStreak': weeklyStreak,
      'longestStreak': longestStreak,
      'lastActivity': lastActivity.toIso8601String(),
      'totalSessions': totalSessions,
      'categoryXP': categoryXP,
      'recentActivities': recentActivities,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXP: json['totalXP'],
      level: json['level'],
      badgesEarned: json['badgesEarned'],
      achievementsCompleted: json['achievementsCompleted'],
      skillsLearned: json['skillsLearned'],
      repositoriesContributed: json['repositoriesContributed'],
      streakDays: json['streakDays'],
      dailyStreak: json['dailyStreak'] ?? 0,
      weeklyStreak: json['weeklyStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActivity: DateTime.parse(json['lastActivity']),
      totalSessions: json['totalSessions'] ?? 0,
      categoryXP: Map<String, int>.from(json['categoryXP'] ?? {}),
      recentActivities: List<String>.from(json['recentActivities'] ?? []),
    );
  }
}

class GamificationService extends ChangeNotifier {
  static const String _userStatsKey = 'user_stats';
  static const String _badgesKey = 'user_badges';
  static const String _achievementsKey = 'user_achievements';

  UserStats _userStats = UserStats(
    totalXP: 0,
    level: 1,
    badgesEarned: 0,
    achievementsCompleted: 0,
    skillsLearned: 0,
    repositoriesContributed: 0,
    streakDays: 0,
    lastActivity: DateTime.now(),
  );

  List<Badge> _badges = [];
  List<Achievement> _achievements = [];

  // Getters
  UserStats get userStats => _userStats;
  List<Badge> get badges => _badges;
  List<Achievement> get achievements => _achievements;
  List<Badge> get earnedBadges =>
      _badges.where((badge) => badge.isEarned).toList();
  List<Achievement> get completedAchievements =>
      _achievements.where((achievement) => achievement.isCompleted).toList();

  /// Initialize the gamification service
  Future<void> init() async {
    await _loadUserStats();
    await _loadBadges();
    await _loadAchievements();
    _initializeDefaultBadges();
    _initializeDefaultAchievements();
  }

  /// Load user stats from storage
  Future<void> _loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_userStatsKey);
      if (statsJson != null) {
        final statsData = jsonDecode(statsJson);
        _userStats = UserStats.fromJson(statsData);
      }
    } catch (e) {
      debugPrint('Error loading user stats: $e');
    }
  }

  /// Load badges from storage
  Future<void> _loadBadges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final badgesJson = prefs.getString(_badgesKey);
      if (badgesJson != null) {
        final badgesData = jsonDecode(badgesJson) as List;
        _badges = badgesData.map((badge) => Badge.fromJson(badge)).toList();
      }
    } catch (e) {
      debugPrint('Error loading badges: $e');
    }
  }

  /// Load achievements from storage
  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_achievementsKey);
      if (achievementsJson != null) {
        final achievementsData = jsonDecode(achievementsJson) as List;
        _achievements =
            achievementsData
                .map((achievement) => Achievement.fromJson(achievement))
                .toList();
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
  }

  /// Initialize default achievements
  void _initializeDefaultAchievements() {
    if (_achievements.isEmpty) {
      _achievements = [
        Achievement(
          id: 'first_skill',
          title: 'First Steps',
          description: 'Learn your first skill',
          icon: '🎯',
          xpReward: 50,
          category: 'Learning',
          progress: 0,
          target: 1,
        ),
        Achievement(
          id: 'skill_master',
          title: 'Skill Master',
          description: 'Learn 10 different skills',
          icon: '🏆',
          xpReward: 200,
          category: 'Learning',
          progress: 0,
          target: 10,
        ),
        Achievement(
          id: 'github_hero',
          title: 'GitHub Hero',
          description: 'Connect your GitHub account',
          icon: '🐙',
          xpReward: 100,
          category: 'Integration',
          progress: 0,
          target: 1,
        ),
        Achievement(
          id: 'repo_contributor',
          title: 'Repository Contributor',
          description: 'Contribute to 5 repositories',
          icon: '📚',
          xpReward: 300,
          category: 'Contribution',
          progress: 0,
          target: 5,
        ),
        Achievement(
          id: 'streak_keeper',
          title: 'Streak Keeper',
          description: 'Maintain a 7-day learning streak',
          icon: '🔥',
          xpReward: 150,
          category: 'Consistency',
          progress: 0,
          target: 7,
        ),
        Achievement(
          id: 'level_up',
          title: 'Level Up',
          description: 'Reach level 5',
          icon: '⭐',
          xpReward: 500,
          category: 'Progression',
          progress: 0,
          target: 5,
        ),
      ];
      _saveAchievements();
    }
  }

  /// Add XP and check for level up
  Future<void> addXP(int xp, {String? category, String? activity}) async {
    final newTotalXP = _userStats.totalXP + xp;
    final newLevel = _calculateLevel(newTotalXP);

    // Update streaks
    await _updateStreaks();

    // Update category XP
    final updatedCategoryXP = Map<String, int>.from(_userStats.categoryXP);
    if (category != null) {
      updatedCategoryXP[category] = (updatedCategoryXP[category] ?? 0) + xp;
    }

    // Add to recent activities
    final updatedActivities = List<String>.from(_userStats.recentActivities);
    if (activity != null) {
      updatedActivities.insert(0, activity);
      if (updatedActivities.length > 10) {
        updatedActivities.removeLast();
      }
    }

    _userStats = _userStats.copyWith(
      totalXP: newTotalXP,
      level: newLevel,
      lastActivity: DateTime.now(),
      totalSessions: _userStats.totalSessions + 1,
      categoryXP: updatedCategoryXP,
      recentActivities: updatedActivities,
    );

    await _saveUserStats();
    notifyListeners();

    // Check for level up
    if (newLevel > _userStats.level) {
      _showLevelUpNotification(newLevel);
    }
  }

  /// Update daily and weekly streaks
  Future<void> _updateStreaks() async {
    final now = DateTime.now();
    final lastActivity = _userStats.lastActivity;

    // Check if it's a new day
    final daysDifference = now.difference(lastActivity).inDays;
    final isNewDay = daysDifference >= 1;
    final isNewWeek = now.difference(lastActivity).inDays >= 7;

    int newDailyStreak = _userStats.dailyStreak;
    int newWeeklyStreak = _userStats.weeklyStreak;
    int newLongestStreak = _userStats.longestStreak;

    if (isNewDay) {
      if (daysDifference == 1) {
        // Consecutive day - increment streak
        newDailyStreak = _userStats.dailyStreak + 1;
      } else {
        // Streak broken - reset
        newDailyStreak = 1;
      }

      // Update longest streak
      if (newDailyStreak > newLongestStreak) {
        newLongestStreak = newDailyStreak;
      }
    }

    if (isNewWeek) {
      if (daysDifference >= 7 && daysDifference < 14) {
        // Consecutive week - increment streak
        newWeeklyStreak = _userStats.weeklyStreak + 1;
      } else {
        // Weekly streak broken - reset
        newWeeklyStreak = 1;
      }
    }

    _userStats = _userStats.copyWith(
      dailyStreak: newDailyStreak,
      weeklyStreak: newWeeklyStreak,
      longestStreak: newLongestStreak,
    );
  }

  /// Get streak bonus XP
  int _getStreakBonus() {
    int bonus = 0;

    // Daily streak bonus
    if (_userStats.dailyStreak >= 7) {
      bonus += 50; // 7-day streak bonus
    }
    if (_userStats.dailyStreak >= 30) {
      bonus += 100; // 30-day streak bonus
    }

    // Weekly streak bonus
    if (_userStats.weeklyStreak >= 4) {
      bonus += 200; // 4-week streak bonus
    }

    return bonus;
  }

  /// Add XP with streak bonus
  Future<void> addXPWithStreakBonus(
    int baseXP, {
    String? category,
    String? activity,
  }) async {
    final streakBonus = _getStreakBonus();
    final totalXP = baseXP + streakBonus;

    await addXP(totalXP, category: category, activity: activity);

    if (streakBonus > 0) {
      debugPrint('🔥 Streak bonus: +$streakBonus XP!');
    }
  }

  /// Calculate level based on XP
  int _calculateLevel(int xp) {
    // Level formula: level = sqrt(xp / 100) + 1
    return sqrt(xp / 100).floor() + 1;
  }

  /// Show level up notification
  void _showLevelUpNotification(int newLevel) {
    debugPrint('🎉 Level Up! You reached level $newLevel!');
    // In a real app, you would show a notification or popup
  }

  /// Award a badge
  Future<void> awardBadge(String badgeId) async {
    final badgeIndex = _badges.indexWhere((badge) => badge.id == badgeId);
    if (badgeIndex != -1 && !_badges[badgeIndex].isEarned) {
      _badges[badgeIndex] = _badges[badgeIndex].copyWith(
        isEarned: true,
        earnedAt: DateTime.now(),
      );

      _userStats = _userStats.copyWith(
        badgesEarned: _userStats.badgesEarned + 1,
      );

      await _saveBadges();
      await _saveUserStats();
      notifyListeners();

      debugPrint('🏆 Badge earned: ${_badges[badgeIndex].name}');
    }
  }

  /// Update achievement progress
  Future<void> updateAchievementProgress(
    String achievementId,
    int progress,
  ) async {
    final achievementIndex = _achievements.indexWhere(
      (achievement) => achievement.id == achievementId,
    );
    if (achievementIndex != -1) {
      final achievement = _achievements[achievementIndex];
      final newProgress = (achievement.progress + progress).clamp(
        0,
        achievement.target,
      );
      final isCompleted = newProgress >= achievement.target;

      _achievements[achievementIndex] = achievement.copyWith(
        progress: newProgress,
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now() : achievement.completedAt,
      );

      if (isCompleted && !achievement.isCompleted) {
        await addXP(achievement.xpReward);
        _userStats = _userStats.copyWith(
          achievementsCompleted: _userStats.achievementsCompleted + 1,
        );
        debugPrint('🎯 Achievement completed: ${achievement.title}');
      }

      await _saveAchievements();
      await _saveUserStats();
      notifyListeners();
    }
  }

  /// Check and award badges based on user activity
  Future<void> checkBadges({
    List<Skill>? skills,
    List<GitHubRepository>? repositories,
  }) async {
    if (skills != null) {
      await _checkSkillBadges(skills);
    }
    if (repositories != null) {
      await _checkRepositoryBadges(repositories);
    }
  }

  /// Check skill-related badges
  Future<void> _checkSkillBadges(List<Skill> skills) async {
    final skillsLearned = skills.length;

    // First skill badge
    if (skillsLearned >= 1) {
      await awardBadge('first_skill');
    }

    // Skill master badge
    if (skillsLearned >= 10) {
      await awardBadge('skill_master');
    }

    // Update skills learned achievement
    await updateAchievementProgress('first_skill', skillsLearned);
    await updateAchievementProgress('skill_master', skillsLearned);
  }

  /// Check repository-related badges
  Future<void> _checkRepositoryBadges(
    List<GitHubRepository> repositories,
  ) async {
    final repoCount = repositories.length;

    // GitHub hero badge
    if (repoCount > 0) {
      await awardBadge('github_hero');
    }

    // Repository contributor badge
    if (repoCount >= 5) {
      await awardBadge('repo_contributor');
    }

    // Update repository achievements
    await updateAchievementProgress('github_hero', repoCount > 0 ? 1 : 0);
    await updateAchievementProgress('repo_contributor', repoCount);
  }

  /// Save user stats to storage
  Future<void> _saveUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatsKey, jsonEncode(_userStats.toJson()));
    } catch (e) {
      debugPrint('Error saving user stats: $e');
    }
  }

  /// Save badges to storage
  Future<void> _saveBadges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final badgesJson = _badges.map((badge) => badge.toJson()).toList();
      await prefs.setString(_badgesKey, jsonEncode(badgesJson));
    } catch (e) {
      debugPrint('Error saving badges: $e');
    }
  }

  /// Save achievements to storage
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson =
          _achievements.map((achievement) => achievement.toJson()).toList();
      await prefs.setString(_achievementsKey, jsonEncode(achievementsJson));
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }

  /// Initialize default badges
  void _initializeDefaultBadges() {
    if (_badges.isNotEmpty)
      return; // Don't reinitialize if badges already exist

    _badges = [
      // Skill-based badges
      Badge(
        id: 'first_skill',
        name: 'First Steps',
        description: 'Complete your first skill',
        icon: '🎯',
        category: 'Skills',
        points: 50,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'frontend_pro',
        name: 'Frontend Pro',
        description: 'Master 5 frontend skills',
        icon: '🎨',
        category: 'Skills',
        points: 200,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'backend_master',
        name: 'Backend Master',
        description: 'Master 5 backend skills',
        icon: '⚙️',
        category: 'Skills',
        points: 200,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'database_explorer',
        name: 'Database Explorer',
        description: 'Learn 3 database technologies',
        icon: '🗄️',
        category: 'Skills',
        points: 150,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'testing_guru',
        name: 'Testing Guru',
        description: 'Master testing frameworks',
        icon: '🧪',
        category: 'Skills',
        points: 150,
        earnedAt: DateTime.now(),
      ),

      // Streak badges
      Badge(
        id: 'week_warrior',
        name: 'Week Warrior',
        description: '7-day learning streak',
        icon: '🔥',
        category: 'Streaks',
        points: 100,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'month_master',
        name: 'Month Master',
        description: '30-day learning streak',
        icon: '💪',
        category: 'Streaks',
        points: 500,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'consistency_king',
        name: 'Consistency King',
        description: '100-day learning streak',
        icon: '👑',
        category: 'Streaks',
        points: 1000,
        earnedAt: DateTime.now(),
      ),

      // Level badges
      Badge(
        id: 'level_5',
        name: 'Rising Star',
        description: 'Reach level 5',
        icon: '⭐',
        category: 'Progression',
        points: 200,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'level_10',
        name: 'Code Warrior',
        description: 'Reach level 10',
        icon: '⚔️',
        category: 'Progression',
        points: 500,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'level_20',
        name: 'Tech Legend',
        description: 'Reach level 20',
        icon: '🏆',
        category: 'Progression',
        points: 1000,
        earnedAt: DateTime.now(),
      ),

      // GitHub badges
      Badge(
        id: 'github_hero',
        name: 'GitHub Hero',
        description: 'Connect your GitHub account',
        icon: '🐙',
        category: 'GitHub',
        points: 100,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'repo_manager',
        name: 'Repo Manager',
        description: 'Manage 10 repositories',
        icon: '📁',
        category: 'GitHub',
        points: 200,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'commit_master',
        name: 'Commit Master',
        description: 'Track 100 commits',
        icon: '📝',
        category: 'GitHub',
        points: 300,
        earnedAt: DateTime.now(),
      ),

      // Special badges
      Badge(
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Complete a skill before 8 AM',
        icon: '🌅',
        category: 'Special',
        points: 75,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'night_owl',
        name: 'Night Owl',
        description: 'Complete a skill after 10 PM',
        icon: '🦉',
        category: 'Special',
        points: 75,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'weekend_warrior',
        name: 'Weekend Warrior',
        description: 'Learn on both weekend days',
        icon: '🏃',
        category: 'Special',
        points: 100,
        earnedAt: DateTime.now(),
      ),
    ];
    _saveBadges();
  }

  /// Reset all gamification data
  Future<void> reset() async {
    _userStats = UserStats(
      totalXP: 0,
      level: 1,
      badgesEarned: 0,
      achievementsCompleted: 0,
      skillsLearned: 0,
      repositoriesContributed: 0,
      streakDays: 0,
      lastActivity: DateTime.now(),
    );
    _badges.clear();
    _achievements.clear();

    await _saveUserStats();
    await _saveBadges();
    await _saveAchievements();
    notifyListeners();
  }
}
