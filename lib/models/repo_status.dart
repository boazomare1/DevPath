import 'package:hive/hive.dart';
import 'github_repository.dart';

part 'repo_status.g.dart';

enum ProjectStatus { notStarted, inProgress, onHold, completed }

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.notStarted:
        return 'Not Started';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }

  String get emoji {
    switch (this) {
      case ProjectStatus.notStarted:
        return '⏳';
      case ProjectStatus.inProgress:
        return '🚀';
      case ProjectStatus.onHold:
        return '⏸️';
      case ProjectStatus.completed:
        return '✅';
    }
  }

  String get description {
    switch (this) {
      case ProjectStatus.notStarted:
        return 'Project has not been started yet';
      case ProjectStatus.inProgress:
        return 'Project is currently being worked on';
      case ProjectStatus.onHold:
        return 'Project is temporarily paused';
      case ProjectStatus.completed:
        return 'Project has been completed';
    }
  }
}

@HiveType(typeId: 4)
class RepoStatus extends HiveObject {
  @HiveField(0)
  final int repoId;

  @HiveField(1)
  final ProjectStatus status;

  @HiveField(2)
  final DateTime lastUpdated;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final int openIssuesCount;

  @HiveField(5)
  final DateTime? lastActivity;

  @HiveField(6)
  final bool isStale;

  @HiveField(7)
  final bool hasRecentActivity;

  @HiveField(8)
  final DateTime? lastCommitDate;

  RepoStatus({
    required this.repoId,
    required this.status,
    required this.lastUpdated,
    this.notes,
    this.openIssuesCount = 0,
    this.lastActivity,
    this.isStale = false,
    this.hasRecentActivity = false,
    this.lastCommitDate,
  });

  factory RepoStatus.fromRepository(
    GitHubRepository repository, {
    ProjectStatus? newStatus,
  }) {
    final now = DateTime.now();
    final lastActivity = repository.updatedAt;
    final daysSinceActivity =
        lastActivity != null ? now.difference(lastActivity).inDays : 30;

    return RepoStatus(
      repoId: repository.id,
      status: newStatus ?? ProjectStatus.notStarted,
      lastUpdated: now,
      openIssuesCount: repository.openIssuesCount ?? 0,
      lastActivity: lastActivity,
      isStale: daysSinceActivity > 30,
      hasRecentActivity: daysSinceActivity <= 7,
      lastCommitDate: lastActivity,
    );
  }

  RepoStatus copyWith({
    int? repoId,
    ProjectStatus? status,
    DateTime? lastUpdated,
    String? notes,
    int? openIssuesCount,
    DateTime? lastActivity,
    bool? isStale,
    bool? hasRecentActivity,
    DateTime? lastCommitDate,
  }) {
    return RepoStatus(
      repoId: repoId ?? this.repoId,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
      openIssuesCount: openIssuesCount ?? this.openIssuesCount,
      lastActivity: lastActivity ?? this.lastActivity,
      isStale: isStale ?? this.isStale,
      hasRecentActivity: hasRecentActivity ?? this.hasRecentActivity,
      lastCommitDate: lastCommitDate ?? this.lastCommitDate,
    );
  }

  @override
  String toString() {
    return 'RepoStatus(repoId: $repoId, status: $status, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepoStatus && other.repoId == repoId;
  }

  Map<String, dynamic> toJson() {
    return {
      'repoId': repoId,
      'status': status.index,
      'lastUpdated': lastUpdated.toIso8601String(),
      'notes': notes,
      'openIssuesCount': openIssuesCount,
      'lastActivity': lastActivity?.toIso8601String(),
      'isStale': isStale,
      'hasRecentActivity': hasRecentActivity,
      'lastCommitDate': lastCommitDate?.toIso8601String(),
    };
  }

  factory RepoStatus.fromJson(Map<String, dynamic> json) {
    return RepoStatus(
      repoId: json['repoId'],
      status: ProjectStatus.values[json['status']],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      notes: json['notes'],
      openIssuesCount: json['openIssuesCount'] ?? 0,
      lastActivity:
          json['lastActivity'] != null
              ? DateTime.parse(json['lastActivity'])
              : null,
      isStale: json['isStale'] ?? false,
      hasRecentActivity: json['hasRecentActivity'] ?? false,
      lastCommitDate:
          json['lastCommitDate'] != null
              ? DateTime.parse(json['lastCommitDate'])
              : null,
    );
  }

  @override
  int get hashCode => repoId.hashCode;
}
