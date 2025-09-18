import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/repo_status.dart';
import '../models/github_repository.dart';

class SimpleRepoStatusService {
  static const String _repoStatusKey = 'repo_statuses';

  /// Get status for a specific repository
  static Future<RepoStatus?> getRepoStatus(int repoId) async {
    final prefs = await SharedPreferences.getInstance();
    final statusesJson = prefs.getString(_repoStatusKey) ?? '{}';
    final statusesMap = jsonDecode(statusesJson) as Map<String, dynamic>;

    if (statusesMap.containsKey(repoId.toString())) {
      return RepoStatus.fromJson(statusesMap[repoId.toString()]);
    }
    return null;
  }

  /// Get all repository statuses
  static Future<List<RepoStatus>> getAllRepoStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final statusesJson = prefs.getString(_repoStatusKey) ?? '{}';
    final statusesMap = jsonDecode(statusesJson) as Map<String, dynamic>;

    return statusesMap.values
        .map((statusJson) => RepoStatus.fromJson(statusJson))
        .toList();
  }

  /// Update or create status for a repository
  static Future<void> updateRepoStatus(RepoStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final statusesJson = prefs.getString(_repoStatusKey) ?? '{}';
    final statusesMap = Map<String, dynamic>.from(jsonDecode(statusesJson));

    statusesMap[status.repoId.toString()] = status.toJson();
    await prefs.setString(_repoStatusKey, jsonEncode(statusesMap));
  }

  /// Update status for a repository from GitHub repository data
  static Future<RepoStatus> updateStatusFromRepository(
    GitHubRepository repository, {
    ProjectStatus? newStatus,
    String? notes,
  }) async {
    final existingStatus = await getRepoStatus(repository.id);

    final status = RepoStatus.fromRepository(
      repository,
      newStatus:
          newStatus ?? existingStatus?.status ?? ProjectStatus.notStarted,
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
    final existingStatus = await getRepoStatus(repoId);
    if (existingStatus != null) {
      final updatedStatus = existingStatus.copyWith(
        status: status,
        notes: notes ?? existingStatus.notes,
        lastUpdated: DateTime.now(),
      );
      await updateRepoStatus(updatedStatus);
    }
  }

  /// Get status with data for a repository (creates if doesn't exist)
  static Future<RepoStatus> getRepoStatusWithData(
    int repoId,
    GitHubRepository repository,
  ) async {
    final existingStatus = await getRepoStatus(repoId);
    if (existingStatus != null) {
      return existingStatus;
    }

    // Create new status from repository
    final newStatus = RepoStatus.fromRepository(repository);
    await updateRepoStatus(newStatus);
    return newStatus;
  }

  /// Get statistics for repository statuses
  static Future<Map<String, int>> getStatusStatistics() async {
    final statuses = await getAllRepoStatuses();
    final stats = <String, int>{};

    for (final status in statuses) {
      final statusName = status.status.displayName;
      stats[statusName] = (stats[statusName] ?? 0) + 1;
    }

    return stats;
  }

  /// Initialize status for repositories
  static Future<void> initializeStatusForRepositories(
    List<GitHubRepository> repositories,
  ) async {
    for (final repo in repositories) {
      final existingStatus = await getRepoStatus(repo.id);
      if (existingStatus == null) {
        final newStatus = RepoStatus.fromRepository(repo);
        await updateRepoStatus(newStatus);
      }
    }
  }

  /// Clear all repository statuses
  static Future<void> clearAllStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_repoStatusKey);
  }
}
