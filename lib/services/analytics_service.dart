import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill.dart';
import '../models/skill_status.dart';
import '../models/github_repository.dart';
import '../services/enhanced_career_goals_service.dart';

class LearningActivity {
  final DateTime date;
  final int minutesSpent;
  final int skillsCompleted;
  final int repositoriesWorkedOn;
  final List<String> activities;

  LearningActivity({
    required this.date,
    required this.minutesSpent,
    required this.skillsCompleted,
    required this.repositoriesWorkedOn,
    required this.activities,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'minutesSpent': minutesSpent,
      'skillsCompleted': skillsCompleted,
      'repositoriesWorkedOn': repositoriesWorkedOn,
      'activities': activities,
    };
  }

  factory LearningActivity.fromJson(Map<String, dynamic> json) {
    return LearningActivity(
      date: DateTime.parse(json['date']),
      minutesSpent: json['minutesSpent'],
      skillsCompleted: json['skillsCompleted'],
      repositoriesWorkedOn: json['repositoriesWorkedOn'],
      activities: List<String>.from(json['activities']),
    );
  }
}

class SkillTrend {
  final DateTime date;
  final int totalSkills;
  final int completedSkills;
  final int inProgressSkills;
  final int notStartedSkills;
  final Map<String, int> categoryBreakdown;

  SkillTrend({
    required this.date,
    required this.totalSkills,
    required this.completedSkills,
    required this.inProgressSkills,
    required this.notStartedSkills,
    required this.categoryBreakdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalSkills': totalSkills,
      'completedSkills': completedSkills,
      'inProgressSkills': inProgressSkills,
      'notStartedSkills': notStartedSkills,
      'categoryBreakdown': categoryBreakdown,
    };
  }

  factory SkillTrend.fromJson(Map<String, dynamic> json) {
    return SkillTrend(
      date: DateTime.parse(json['date']),
      totalSkills: json['totalSkills'],
      completedSkills: json['completedSkills'],
      inProgressSkills: json['inProgressSkills'],
      notStartedSkills: json['notStartedSkills'],
      categoryBreakdown: Map<String, int>.from(json['categoryBreakdown']),
    );
  }
}

class ContributionData {
  final DateTime date;
  final int contributions;
  final List<String> repositories;

  ContributionData({
    required this.date,
    required this.contributions,
    required this.repositories,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'contributions': contributions,
      'repositories': repositories,
    };
  }

  factory ContributionData.fromJson(Map<String, dynamic> json) {
    return ContributionData(
      date: DateTime.parse(json['date']),
      contributions: json['contributions'],
      repositories: List<String>.from(json['repositories']),
    );
  }
}

class CareerProgress {
  final String goalId;
  final String goalTitle;
  final double readinessPercentage;
  final int skillGaps;
  final int completedRecommendations;
  final DateTime lastUpdated;

  CareerProgress({
    required this.goalId,
    required this.goalTitle,
    required this.readinessPercentage,
    required this.skillGaps,
    required this.completedRecommendations,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'goalTitle': goalTitle,
      'readinessPercentage': readinessPercentage,
      'skillGaps': skillGaps,
      'completedRecommendations': completedRecommendations,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CareerProgress.fromJson(Map<String, dynamic> json) {
    return CareerProgress(
      goalId: json['goalId'],
      goalTitle: json['goalTitle'],
      readinessPercentage: json['readinessPercentage'],
      skillGaps: json['skillGaps'],
      completedRecommendations: json['completedRecommendations'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class AnalyticsService extends ChangeNotifier {
  static const String _learningActivityKey = 'learning_activity';
  static const String _skillTrendsKey = 'skill_trends';
  static const String _contributionDataKey = 'contribution_data';
  static const String _careerProgressKey = 'career_progress';

  List<LearningActivity> _learningActivities = [];
  List<SkillTrend> _skillTrends = [];
  List<ContributionData> _contributionData = [];
  List<CareerProgress> _careerProgress = [];

  // Getters
  List<LearningActivity> get learningActivities => _learningActivities;
  List<SkillTrend> get skillTrends => _skillTrends;
  List<ContributionData> get contributionData => _contributionData;
  List<CareerProgress> get careerProgress => _careerProgress;

  /// Initialize the analytics service
  Future<void> init() async {
    await _loadLearningActivities();
    await _loadSkillTrends();
    await _loadContributionData();
    await _loadCareerProgress();
  }

  /// Load learning activities from storage
  Future<void> _loadLearningActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = prefs.getString(_learningActivityKey);
      if (activitiesJson != null) {
        final activitiesData = jsonDecode(activitiesJson) as List;
        _learningActivities =
            activitiesData
                .map((activity) => LearningActivity.fromJson(activity))
                .toList();
      }
    } catch (e) {
      debugPrint('Error loading learning activities: $e');
    }
  }

  /// Load skill trends from storage
  Future<void> _loadSkillTrends() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trendsJson = prefs.getString(_skillTrendsKey);
      if (trendsJson != null) {
        final trendsData = jsonDecode(trendsJson) as List;
        _skillTrends =
            trendsData.map((trend) => SkillTrend.fromJson(trend)).toList();
      }
    } catch (e) {
      debugPrint('Error loading skill trends: $e');
    }
  }

  /// Load contribution data from storage
  Future<void> _loadContributionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contributionsJson = prefs.getString(_contributionDataKey);
      if (contributionsJson != null) {
        final contributionsData = jsonDecode(contributionsJson) as List;
        _contributionData =
            contributionsData
                .map((data) => ContributionData.fromJson(data))
                .toList();
      }
    } catch (e) {
      debugPrint('Error loading contribution data: $e');
    }
  }

  /// Load career progress from storage
  Future<void> _loadCareerProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_careerProgressKey);
      if (progressJson != null) {
        final progressData = jsonDecode(progressJson) as List;
        _careerProgress =
            progressData
                .map((progress) => CareerProgress.fromJson(progress))
                .toList();
      }
    } catch (e) {
      debugPrint('Error loading career progress: $e');
    }
  }

  /// Record learning activity
  Future<void> recordLearningActivity({
    required int minutesSpent,
    required int skillsCompleted,
    required int repositoriesWorkedOn,
    required List<String> activities,
  }) async {
    final today = DateTime.now();
    final existingIndex = _learningActivities.indexWhere(
      (activity) => _isSameDay(activity.date, today),
    );

    final activity = LearningActivity(
      date: today,
      minutesSpent: minutesSpent,
      skillsCompleted: skillsCompleted,
      repositoriesWorkedOn: repositoriesWorkedOn,
      activities: activities,
    );

    if (existingIndex != -1) {
      _learningActivities[existingIndex] = activity;
    } else {
      _learningActivities.add(activity);
    }

    await _saveLearningActivities();
    notifyListeners();
  }

  /// Update skill trends
  Future<void> updateSkillTrends(List<Skill> skills) async {
    final today = DateTime.now();
    final existingIndex = _skillTrends.indexWhere(
      (trend) => _isSameDay(trend.date, today),
    );

    final completedSkills =
        skills.where((s) => s.status == SkillStatus.completed).length;
    final inProgressSkills =
        skills.where((s) => s.status == SkillStatus.inProgress).length;
    final notStartedSkills =
        skills.where((s) => s.status == SkillStatus.notStarted).length;

    final categoryBreakdown = <String, int>{};
    for (final skill in skills) {
      final category = skill.category.displayName;
      categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + 1;
    }

    final trend = SkillTrend(
      date: today,
      totalSkills: skills.length,
      completedSkills: completedSkills,
      inProgressSkills: inProgressSkills,
      notStartedSkills: notStartedSkills,
      categoryBreakdown: categoryBreakdown,
    );

    if (existingIndex != -1) {
      _skillTrends[existingIndex] = trend;
    } else {
      _skillTrends.add(trend);
    }

    await _saveSkillTrends();
    notifyListeners();
  }

  /// Update contribution data
  Future<void> updateContributionData(
    List<GitHubRepository> repositories,
  ) async {
    final contributionMap = <DateTime, List<String>>{};

    for (final repo in repositories) {
      // Simulate contribution data based on repository activity
      final lastActivity = repo.updatedAt;
      final daysSinceUpdate = DateTime.now().difference(lastActivity).inDays;

      if (daysSinceUpdate <= 365) {
        // Generate random contribution data for the past year
        for (int i = 0; i < min(30, daysSinceUpdate); i++) {
          final date = lastActivity.add(Duration(days: i));
          final contributions = Random().nextInt(
            5,
          ); // 0-4 contributions per day

          if (contributions > 0) {
            if (contributionMap[date] == null) {
              contributionMap[date] = [];
            }
            contributionMap[date]!.add(repo.name);
          }
        }
      }
    }

    _contributionData =
        contributionMap.entries
            .map(
              (entry) => ContributionData(
                date: entry.key,
                contributions: entry.value.length,
                repositories: entry.value,
              ),
            )
            .toList();

    await _saveContributionData();
    notifyListeners();
  }

  /// Update career progress
  Future<void> updateCareerProgress(List<EnhancedCareerGoal> goals) async {
    _careerProgress =
        goals
            .map(
              (goal) => CareerProgress(
                goalId: goal.id,
                goalTitle: goal.title,
                readinessPercentage: goal.readinessPercentage,
                skillGaps: goal.skillGaps.length,
                completedRecommendations:
                    goal.aiRecommendations
                        .where((rec) => rec.isCompleted)
                        .length,
                lastUpdated: DateTime.now(),
              ),
            )
            .toList();

    await _saveCareerProgress();
    notifyListeners();
  }

  /// Get weekly learning activity data
  List<Map<String, dynamic>> getWeeklyLearningActivity() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklyData =
        _learningActivities
            .where((activity) => activity.date.isAfter(weekAgo))
            .toList();

    // Fill in missing days with zero data
    final result = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final activity = weeklyData.firstWhere(
        (a) => _isSameDay(a.date, date),
        orElse:
            () => LearningActivity(
              date: date,
              minutesSpent: 0,
              skillsCompleted: 0,
              repositoriesWorkedOn: 0,
              activities: [],
            ),
      );

      result.add({
        'date': date,
        'minutesSpent': activity.minutesSpent,
        'skillsCompleted': activity.skillsCompleted,
        'repositoriesWorkedOn': activity.repositoriesWorkedOn,
        'dayName': _getDayName(date.weekday),
      });
    }

    return result;
  }

  /// Get skill completion trends
  List<Map<String, dynamic>> getSkillCompletionTrends() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final monthlyData =
        _skillTrends.where((trend) => trend.date.isAfter(monthAgo)).toList();

    // Fill in missing days with zero data
    final result = <Map<String, dynamic>>[];
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final trend = monthlyData.firstWhere(
        (t) => _isSameDay(t.date, date),
        orElse:
            () => SkillTrend(
              date: date,
              totalSkills: 0,
              completedSkills: 0,
              inProgressSkills: 0,
              notStartedSkills: 0,
              categoryBreakdown: {},
            ),
      );

      result.add({
        'date': date,
        'totalSkills': trend.totalSkills,
        'completedSkills': trend.completedSkills,
        'inProgressSkills': trend.inProgressSkills,
        'notStartedSkills': trend.notStartedSkills,
        'completionRate':
            trend.totalSkills > 0
                ? (trend.completedSkills / trend.totalSkills) * 100
                : 0.0,
      });
    }

    return result;
  }

  /// Get contribution heatmap data
  Map<String, List<Map<String, dynamic>>> getContributionHeatmap() {
    final now = DateTime.now();
    final yearAgo = now.subtract(const Duration(days: 365));

    final yearlyData =
        _contributionData.where((data) => data.date.isAfter(yearAgo)).toList();

    // Group by weeks
    final weeklyData = <String, List<Map<String, dynamic>>>{};

    for (int i = 0; i < 52; i++) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final weekEnd = now.subtract(Duration(days: i * 7));

      final weekKey = 'Week ${52 - i}';
      final weekContributions = <Map<String, dynamic>>[];

      for (int day = 0; day < 7; day++) {
        final date = weekStart.add(Duration(days: day));
        final contribution = yearlyData.firstWhere(
          (data) => _isSameDay(data.date, date),
          orElse:
              () => ContributionData(
                date: date,
                contributions: 0,
                repositories: [],
              ),
        );

        weekContributions.add({
          'date': date,
          'contributions': contribution.contributions,
          'repositories': contribution.repositories,
          'dayName': _getDayName(date.weekday),
        });
      }

      weeklyData[weekKey] = weekContributions;
    }

    return weeklyData;
  }

  /// Get career goals progress comparison
  List<Map<String, dynamic>> getCareerGoalsProgress() {
    return _careerProgress
        .map(
          (progress) => {
            'goalId': progress.goalId,
            'goalTitle': progress.goalTitle,
            'readinessPercentage': progress.readinessPercentage,
            'skillGaps': progress.skillGaps,
            'completedRecommendations': progress.completedRecommendations,
            'lastUpdated': progress.lastUpdated,
            'progressLevel': _getProgressLevel(progress.readinessPercentage),
          },
        )
        .toList();
  }

  /// Get analytics summary
  Map<String, dynamic> getAnalyticsSummary() {
    final weeklyActivity = getWeeklyLearningActivity();
    final skillTrends = getSkillCompletionTrends();
    final careerProgress = getCareerGoalsProgress();

    final totalMinutes = weeklyActivity.fold(
      0,
      (sum, day) => sum + (day['minutesSpent'] as int),
    );
    final totalSkillsCompleted = weeklyActivity.fold(
      0,
      (sum, day) => sum + (day['skillsCompleted'] as int),
    );
    final averageReadiness =
        careerProgress.isNotEmpty
            ? careerProgress.fold(
                  0.0,
                  (sum, goal) => sum + (goal['readinessPercentage'] as double),
                ) /
                careerProgress.length
            : 0.0;

    final currentWeekTrend = skillTrends.take(7).toList();
    final previousWeekTrend = skillTrends.skip(7).take(7).toList();

    final currentWeekCompletion = currentWeekTrend.fold(
      0,
      (sum, day) => sum + (day['completedSkills'] as int),
    );
    final previousWeekCompletion = previousWeekTrend.fold(
      0,
      (sum, day) => sum + (day['completedSkills'] as int),
    );

    final completionTrend =
        previousWeekCompletion > 0
            ? ((currentWeekCompletion - previousWeekCompletion) /
                    previousWeekCompletion) *
                100
            : 0.0;

    return {
      'totalMinutesThisWeek': totalMinutes,
      'totalSkillsCompletedThisWeek': totalSkillsCompleted,
      'averageReadinessPercentage': averageReadiness,
      'completionTrendPercentage': completionTrend,
      'activeGoals': careerProgress.length,
      'totalSkillGaps': careerProgress.fold(
        0,
        (sum, goal) => sum + (goal['skillGaps'] as int),
      ),
      'completedRecommendations': careerProgress.fold(
        0,
        (sum, goal) => sum + (goal['completedRecommendations'] as int),
      ),
    };
  }

  /// Save learning activities to storage
  Future<void> _saveLearningActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson =
          _learningActivities.map((activity) => activity.toJson()).toList();
      await prefs.setString(_learningActivityKey, jsonEncode(activitiesJson));
    } catch (e) {
      debugPrint('Error saving learning activities: $e');
    }
  }

  /// Save skill trends to storage
  Future<void> _saveSkillTrends() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trendsJson = _skillTrends.map((trend) => trend.toJson()).toList();
      await prefs.setString(_skillTrendsKey, jsonEncode(trendsJson));
    } catch (e) {
      debugPrint('Error saving skill trends: $e');
    }
  }

  /// Save contribution data to storage
  Future<void> _saveContributionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contributionsJson =
          _contributionData.map((data) => data.toJson()).toList();
      await prefs.setString(
        _contributionDataKey,
        jsonEncode(contributionsJson),
      );
    } catch (e) {
      debugPrint('Error saving contribution data: $e');
    }
  }

  /// Save career progress to storage
  Future<void> _saveCareerProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson =
          _careerProgress.map((progress) => progress.toJson()).toList();
      await prefs.setString(_careerProgressKey, jsonEncode(progressJson));
    } catch (e) {
      debugPrint('Error saving career progress: $e');
    }
  }

  /// Helper methods
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getProgressLevel(double percentage) {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 80) return 'Very Good';
    if (percentage >= 70) return 'Good';
    if (percentage >= 60) return 'Fair';
    if (percentage >= 40) return 'Needs Work';
    return 'Needs Significant Work';
  }
}
