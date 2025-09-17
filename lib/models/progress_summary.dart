import 'skill.dart';
import 'skill_category.dart';

class ProgressSummary {
  final int totalSkills;
  final int completedSkills;
  final int inProgressSkills;
  final int notStartedSkills;
  final Map<SkillCategory, int> categoryProgress;
  final double overallProgress;

  const ProgressSummary({
    required this.totalSkills,
    required this.completedSkills,
    required this.inProgressSkills,
    required this.notStartedSkills,
    required this.categoryProgress,
    required this.overallProgress,
  });

  factory ProgressSummary.fromSkills(List<Skill> skills) {
    final totalSkills = skills.length;
    final completedSkills = skills.where((s) => s.isCompleted).length;
    final inProgressSkills = skills.where((s) => s.isInProgress).length;
    final notStartedSkills = skills.where((s) => s.isNotStarted).length;

    final overallProgress =
        totalSkills > 0 ? completedSkills / totalSkills : 0.0;

    final categoryProgress = <SkillCategory, int>{};
    for (final category in SkillCategory.values) {
      final categorySkills = skills.where((s) => s.category == category);
      final completedInCategory =
          categorySkills.where((s) => s.isCompleted).length;
      categoryProgress[category] = completedInCategory;
    }

    return ProgressSummary(
      totalSkills: totalSkills,
      completedSkills: completedSkills,
      inProgressSkills: inProgressSkills,
      notStartedSkills: notStartedSkills,
      categoryProgress: categoryProgress,
      overallProgress: overallProgress,
    );
  }

  double get completionPercentage => overallProgress * 100;

  int get totalInProgressAndCompleted => completedSkills + inProgressSkills;

  bool get hasProgress => completedSkills > 0 || inProgressSkills > 0;

  String get progressDescription {
    if (completedSkills == 0 && inProgressSkills == 0) {
      return 'Ready to start your journey!';
    } else if (completedSkills == 0) {
      return 'Great start! Keep going!';
    } else if (completedSkills < totalSkills) {
      return 'Excellent progress! You\'re on your way!';
    } else {
      return 'Congratulations! You\'ve completed all skills!';
    }
  }
}
