import 'package:hive/hive.dart';

part 'repo_status.g.dart';

@HiveType(typeId: 6)
enum ProjectStatus {
  @HiveField(0)
  inProgress,

  @HiveField(1)
  onHold,

  @HiveField(2)
  completed,

  @HiveField(3)
  notStarted,
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.notStarted:
        return 'Not Started';
    }
  }

  String get emoji {
    switch (this) {
      case ProjectStatus.inProgress:
        return '✅';
      case ProjectStatus.onHold:
        return '⏸️';
      case ProjectStatus.completed:
        return '🏁';
      case ProjectStatus.notStarted:
        return '📋';
    }
  }

  String get description {
    switch (this) {
      case ProjectStatus.inProgress:
        return 'Active development';
      case ProjectStatus.onHold:
        return 'Paused temporarily';
      case ProjectStatus.completed:
        return 'Project finished';
      case ProjectStatus.notStarted:
        return 'Not yet started';
    }
  }
}

@HiveType(typeId: 7)
class RepoStatus {
  @HiveField(0)
  final int repoId;

  @HiveField(1)
  final ProjectStatus status;

  @HiveField(2)
  final DateTime lastUpdated;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final bool isStale;

  @HiveField(5)
  final int openIssuesCount;

  @HiveField(6)
  final DateTime? lastCommitDate;

  @HiveField(7)
  final bool hasRecentActivity;

  RepoStatus({
    required this.repoId,
    required this.status,
    required this.lastUpdated,
    this.notes,
    required this.isStale,
    required this.openIssuesCount,
    this.lastCommitDate,
    required this.hasRecentActivity,
  });

  factory RepoStatus.fromRepository({
    required int repoId,
    required DateTime lastCommitDate,
    required int openIssuesCount,
    ProjectStatus status = ProjectStatus.notStarted,
    String? notes,
  }) {
    final now = DateTime.now();
    final daysSinceLastCommit = now.difference(lastCommitDate).inDays;
    final isStale = daysSinceLastCommit > 30;
    final hasRecentActivity = daysSinceLastCommit <= 7;

    return RepoStatus(
      repoId: repoId,
      status: status,
      lastUpdated: now,
      notes: notes,
      isStale: isStale,
      openIssuesCount: openIssuesCount,
      lastCommitDate: lastCommitDate,
      hasRecentActivity: hasRecentActivity,
    );
  }

  RepoStatus copyWith({
    int? repoId,
    ProjectStatus? status,
    DateTime? lastUpdated,
    String? notes,
    bool? isStale,
    int? openIssuesCount,
    DateTime? lastCommitDate,
    bool? hasRecentActivity,
  }) {
    return RepoStatus(
      repoId: repoId ?? this.repoId,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
      isStale: isStale ?? this.isStale,
      openIssuesCount: openIssuesCount ?? this.openIssuesCount,
      lastCommitDate: lastCommitDate ?? this.lastCommitDate,
      hasRecentActivity: hasRecentActivity ?? this.hasRecentActivity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'repoId': repoId,
      'status': status.index,
      'lastUpdated': lastUpdated.toIso8601String(),
      'notes': notes,
      'isStale': isStale,
      'openIssuesCount': openIssuesCount,
      'lastCommitDate': lastCommitDate?.toIso8601String(),
      'hasRecentActivity': hasRecentActivity,
    };
  }

  factory RepoStatus.fromJson(Map<String, dynamic> json) {
    return RepoStatus(
      repoId: json['repoId'] ?? 0,
      status: ProjectStatus.values[json['status'] ?? 0],
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
      notes: json['notes'],
      isStale: json['isStale'] ?? false,
      openIssuesCount: json['openIssuesCount'] ?? 0,
      lastCommitDate:
          json['lastCommitDate'] != null
              ? DateTime.parse(json['lastCommitDate'])
              : null,
      hasRecentActivity: json['hasRecentActivity'] ?? false,
    );
  }

  @override
  String toString() {
    return 'RepoStatus(repoId: $repoId, status: ${status.displayName}, isStale: $isStale, openIssues: $openIssuesCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepoStatus && other.repoId == repoId;
  }

  @override
  int get hashCode => repoId.hashCode;
}
