enum SkillStatus {
  notStarted,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case SkillStatus.notStarted:
        return 'Not Started';
      case SkillStatus.inProgress:
        return 'In Progress';
      case SkillStatus.completed:
        return 'Completed';
    }
  }

  String get shortName {
    switch (this) {
      case SkillStatus.notStarted:
        return 'Not Started';
      case SkillStatus.inProgress:
        return 'In Progress';
      case SkillStatus.completed:
        return 'Completed';
    }
  }
}
