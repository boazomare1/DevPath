import 'package:hive_flutter/hive_flutter.dart';
import '../models/repo_status.dart';
import '../models/github_repository.dart';

class RepoStatusService {
  static const String _repoStatusBoxName = 'repo_status';
  static late Box<RepoStatus> _repoStatusBox;

  static Future<void> init() async {
    _repoStatusBox = await Hive.openBox<RepoStatus>(_repoStatusBoxName);
  }

  /// Get status for a specific repository
  static RepoStatus? getRepoStatus(int repoId) {
    return _repoStatusBox.get(repoId);
  }

  /// Get all repository statuses
  static List<RepoStatus> getAllRepoStatuses() {
    return _repoStatusBox.values.toList();
  }

  /// Update or create status for a repository
  static Future<void> updateRepoStatus(RepoStatus status) async {
    await _repoStatusBox.put(status.repoId, status);
  }

  /// Update status for a repository from GitHub repository data
  static Future<RepoStatus> updateStatusFromRepository(
    GitHubRepository repository, {
    ProjectStatus? newStatus,
    String? notes,
  }) async {
    final existingStatus = getRepoStatus(repository.id);
    final lastCommitDate = repository.pushedAt ?? repository.updatedAt;

    final status = RepoStatus.fromRepository(
      repoId: repository.id,
      lastCommitDate: lastCommitDate,
      openIssuesCount: repository.openIssuesCount,
      status: newStatus ?? existingStatus?.status ?? ProjectStatus.notStarted,
      notes: notes ?? existingStatus?.notes,
    );

    await updateRepoStatus(status);
    return status;
  }

  /// Update project status for a repository
  static Future<void> updateProjectStatus(
    int repoId,
    ProjectStatus status, {
    String? notes,
  }) async {
    final existingStatus = getRepoStatus(repoId);
    if (existingStatus != null) {
      final updatedStatus = existingStatus.copyWith(
        status: status,
        notes: notes,
        lastUpdated: DateTime.now(),
      );
      await updateRepoStatus(updatedStatus);
    }
  }

  /// Get repositories by status
  static List<RepoStatus> getRepositoriesByStatus(ProjectStatus status) {
    return _repoStatusBox.values
        .where((repoStatus) => repoStatus.status == status)
        .toList();
  }

  /// Get stale repositories (no commits in 30+ days)
  static List<RepoStatus> getStaleRepositories() {
    return _repoStatusBox.values
        .where((repoStatus) => repoStatus.isStale)
        .toList();
  }

  /// Get repositories with open issues
  static List<RepoStatus> getRepositoriesWithIssues() {
    return _repoStatusBox.values
        .where((repoStatus) => repoStatus.openIssuesCount > 0)
        .toList();
  }

  /// Get recently active repositories (commits in last 7 days)
  static List<RepoStatus> getRecentlyActiveRepositories() {
    return _repoStatusBox.values
        .where((repoStatus) => repoStatus.hasRecentActivity)
        .toList();
  }

  /// Get repository status with repository data
  static RepoStatus? getRepoStatusWithData(
    int repoId,
    GitHubRepository repository,
  ) {
    final status = getRepoStatus(repoId);
    if (status != null) {
      // Update status with latest repository data
      final lastCommitDate = repository.pushedAt ?? repository.updatedAt;
      final daysSinceLastCommit =
          DateTime.now().difference(lastCommitDate).inDays;
      final isStale = daysSinceLastCommit > 30;
      final hasRecentActivity = daysSinceLastCommit <= 7;

      return status.copyWith(
        isStale: isStale,
        openIssuesCount: repository.openIssuesCount,
        lastCommitDate: lastCommitDate,
        hasRecentActivity: hasRecentActivity,
      );
    }
    return null;
  }

  /// Initialize status for all repositories
  static Future<void> initializeStatusForRepositories(
    List<GitHubRepository> repositories,
  ) async {
    for (final repo in repositories) {
      final existingStatus = getRepoStatus(repo.id);
      if (existingStatus == null) {
        // Create new status if it doesn't exist
        await updateStatusFromRepository(repo);
      } else {
        // Update existing status with latest data
        await updateStatusFromRepository(
          repo,
          newStatus: existingStatus.status,
          notes: existingStatus.notes,
        );
      }
    }
  }

  /// Delete status for a repository
  static Future<void> deleteRepoStatus(int repoId) async {
    await _repoStatusBox.delete(repoId);
  }

  /// Clear all repository statuses
  static Future<void> clearAllStatuses() async {
    await _repoStatusBox.clear();
  }

  /// Get status statistics
  static Map<String, int> getStatusStatistics() {
    final statuses = _repoStatusBox.values.toList();
    final stats = <String, int>{};

    for (final status in ProjectStatus.values) {
      stats[status.displayName] =
          statuses.where((s) => s.status == status).length;
    }

    stats['Stale'] = statuses.where((s) => s.isStale).length;
    stats['With Issues'] = statuses.where((s) => s.openIssuesCount > 0).length;
    stats['Recently Active'] =
        statuses.where((s) => s.hasRecentActivity).length;

    return stats;
  }

  /// Search repositories by status and criteria
  static List<RepoStatus> searchRepositories({
    ProjectStatus? status,
    bool? isStale,
    bool? hasIssues,
    bool? hasRecentActivity,
    String? searchQuery,
  }) {
    var results = _repoStatusBox.values.toList();

    if (status != null) {
      results = results.where((s) => s.status == status).toList();
    }

    if (isStale != null) {
      results = results.where((s) => s.isStale == isStale).toList();
    }

    if (hasIssues != null) {
      results =
          results.where((s) => (s.openIssuesCount > 0) == hasIssues).toList();
    }

    if (hasRecentActivity != null) {
      results =
          results
              .where((s) => s.hasRecentActivity == hasRecentActivity)
              .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      results =
          results.where((s) {
            // Note: This would need repository data to search by name/description
            // For now, we'll search by notes
            return s.notes?.toLowerCase().contains(query) ?? false;
          }).toList();
    }

    return results;
  }
}
