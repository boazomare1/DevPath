import 'package:hive/hive.dart';
import 'github_repository.dart';

part 'repo_status.g.dart';

enum ProjectStatus {
  notStarted,
  inProgress,
  onHold,
  completed,
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

  RepoStatus({
    required this.repoId,
    required this.status,
    required this.lastUpdated,
    this.notes,
    this.openIssuesCount = 0,
    this.lastActivity,
    this.isStale = false,
    this.hasRecentActivity = false,
  });

  factory RepoStatus.fromRepository(
    GitHubRepository repository, {
    ProjectStatus? newStatus,
  }) {
    final now = DateTime.now();
    final lastActivity = repository.updatedAt;
    final daysSinceActivity = lastActivity != null 
        ? now.difference(lastActivity).inDays 
        : 30;
    
    return RepoStatus(
      repoId: repository.id,
      status: newStatus ?? ProjectStatus.notStarted,
      lastUpdated: now,
      openIssuesCount: repository.openIssuesCount ?? 0,
      lastActivity: lastActivity,
      isStale: daysSinceActivity > 30,
      hasRecentActivity: daysSinceActivity <= 7,
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

  @override
  int get hashCode => repoId.hashCode;
}