import 'package:flutter/material.dart';
import '../models/github_repository.dart';
import '../models/repo_status.dart';
import '../services/repo_status_service.dart';
import 'repo_card.dart';

class GitHubRepoList extends StatelessWidget {
  final List<GitHubRepository> repositories;
  final ProjectStatus? selectedStatus;
  final String searchQuery;
  final Function(ProjectStatus?)? onStatusChanged;
  final Function(String)? onSearchChanged;

  const GitHubRepoList({
    super.key,
    required this.repositories,
    this.selectedStatus,
    this.searchQuery = '',
    this.onStatusChanged,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (repositories.isEmpty) {
      return _buildEmptyState(context);
    }

    final filteredRepos = _filterRepositories();

    return ListView.builder(
      itemCount: filteredRepos.length,
      itemBuilder: (context, index) {
        final repo = filteredRepos[index];
        final repoStatus = RepoStatusService.getRepoStatus(repo.id);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RepoCard(
            repository: repo,
            status: repoStatus,
            onStatusChanged: (newStatus) {
              if (repoStatus != null) {
                RepoStatusService.updateRepoStatus(
                  repoStatus.copyWith(status: newStatus),
                );
              } else {
                RepoStatusService.updateStatusFromRepository(
                  repo,
                  newStatus,
                );
              }
            },
          ),
        );
      },
    );
  }

  List<GitHubRepository> _filterRepositories() {
    var filtered = repositories;

    // Filter by status
    if (selectedStatus != null) {
      filtered = filtered.where((repo) {
        final status = RepoStatusService.getRepoStatus(repo.id);
        return status?.status == selectedStatus;
      }).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((repo) {
        return repo.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               repo.description?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
               repo.language?.toLowerCase().contains(searchQuery.toLowerCase()) == true;
      }).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No repositories found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your GitHub account to see your repositories',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}