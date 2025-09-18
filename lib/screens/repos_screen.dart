import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/github_auth_service.dart';
import '../models/github_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/repo_filter_chips.dart';
import '../widgets/repo_card.dart';
import '../widgets/repo_search_bar.dart';
import '../widgets/repo_status_selector.dart';
import '../widgets/notification_banner.dart';
import '../services/repo_status_service.dart';
import '../services/reminder_service.dart';
import '../models/repo_status.dart';

class ReposScreen extends StatefulWidget {
  const ReposScreen({super.key});

  @override
  State<ReposScreen> createState() => _ReposScreenState();
}

class _ReposScreenState extends State<ReposScreen> {
  String _searchQuery = '';
  String _selectedLanguage = 'All';
  bool _showActiveOnly = true;
  bool _showArchivedOnly = false;
  ProjectStatus? _selectedStatus;
  bool _showStaleOnly = false;
  bool _showWithIssuesOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeRepositoryStatuses();
    _checkForInactiveRepositories();
  }

  Future<void> _initializeRepositoryStatuses() async {
    final authService = context.read<GitHubAuthService>();
    if (authService.isAuthenticated && authService.repositories.isNotEmpty) {
      await RepoStatusService.initializeStatusForRepositories(
        authService.repositories,
      );
    }
  }

  Future<void> _checkForInactiveRepositories() async {
    try {
      final inactiveRepos = await ReminderService.checkInactiveRepositories();

      if (inactiveRepos.isNotEmpty && mounted) {
        _showInactiveReposBanner(inactiveRepos);
      }
    } catch (e) {
      debugPrint('Error checking inactive repositories: $e');
    }
  }

  void _showInactiveReposBanner(List<InactiveRepoInfo> inactiveRepos) {
    final title = 'Inactive Repositories';
    final message =
        inactiveRepos.length == 1
            ? '1 repository marked "In Progress" hasn\'t been updated recently'
            : '${inactiveRepos.length} repositories marked "In Progress" haven\'t been updated recently';

    NotificationBannerManager.show(
      context: context,
      title: title,
      message: message,
      duration: const Duration(seconds: 5),
      onTap: () {
        // Navigate to repos screen with stale filter
        setState(() {
          _showStaleOnly = true;
        });
        NotificationBannerManager.hide();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Search and Filters
              _buildSearchAndFilters(context),

              // Repositories List
              Expanded(child: _buildRepositoriesList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.folder, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Repositories',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and explore your GitHub repositories',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Search Bar
          RepoSearchBar(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),

          const SizedBox(height: 16),

          // Filter Chips
          RepoFilterChips(
            selectedLanguage: _selectedLanguage,
            showActiveOnly: _showActiveOnly,
            showArchivedOnly: _showArchivedOnly,
            selectedStatus: _selectedStatus,
            showStaleOnly: _showStaleOnly,
            showWithIssuesOnly: _showWithIssuesOnly,
            onLanguageChanged: (language) {
              setState(() {
                _selectedLanguage = language;
              });
            },
            onActiveFilterChanged: (showActive) {
              setState(() {
                _showActiveOnly = showActive;
                if (showActive) _showArchivedOnly = false;
              });
            },
            onArchivedFilterChanged: (showArchived) {
              setState(() {
                _showArchivedOnly = showArchived;
                if (showArchived) _showActiveOnly = false;
              });
            },
            onStatusChanged: (status) {
              setState(() {
                _selectedStatus = status;
              });
            },
            onStaleFilterChanged: (showStale) {
              setState(() {
                _showStaleOnly = showStale;
              });
            },
            onWithIssuesFilterChanged: (showWithIssues) {
              setState(() {
                _showWithIssuesOnly = showWithIssues;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRepositoriesList(BuildContext context) {
    return StreamBuilder<List<GitHubRepository>>(
      stream: context.watch<GitHubAuthService>().reposStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRepos = snapshot.data!;
        final filteredRepos = _filterRepositories(allRepos);

        if (filteredRepos.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: filteredRepos.length,
          itemBuilder: (context, index) {
            final repo = filteredRepos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RepoCard(
                repository: repo,
                onTap: () => _showRepoDetails(context, repo),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isNotEmpty ||
                              _selectedLanguage != 'All' ||
                              _showActiveOnly ||
                              _showArchivedOnly
                          ? 'No repositories match your filters'
                          : 'No repositories found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _searchQuery.isNotEmpty ||
                              _selectedLanguage != 'All' ||
                              _showActiveOnly ||
                              _showArchivedOnly
                          ? 'Try adjusting your search or filter criteria'
                          : 'Connect your GitHub account to view your repositories',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_searchQuery.isNotEmpty ||
                        _selectedLanguage != 'All' ||
                        _showActiveOnly ||
                        _showArchivedOnly) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedLanguage = 'All';
                            _showActiveOnly = true;
                            _showArchivedOnly = false;
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<GitHubRepository> _filterRepositories(List<GitHubRepository> repos) {
    return repos.where((repo) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!repo.name.toLowerCase().contains(query) &&
            !repo.description.toLowerCase().contains(query) &&
            !repo.language.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Language filter
      if (_selectedLanguage != 'All' && repo.language != _selectedLanguage) {
        return false;
      }

      // Active/Archived filter
      if (_showActiveOnly && repo.archived) {
        return false;
      }
      if (_showArchivedOnly && !repo.archived) {
        return false;
      }

      // Status filters
      final repoStatus = RepoStatusService.getRepoStatusWithData(repo.id, repo);
      if (repoStatus != null) {
        // Project status filter
        if (_selectedStatus != null && repoStatus.status != _selectedStatus) {
          return false;
        }

        // Stale filter
        if (_showStaleOnly && !repoStatus.isStale) {
          return false;
        }

        // Issues filter
        if (_showWithIssuesOnly && repoStatus.openIssuesCount == 0) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showRepoDetails(BuildContext context, GitHubRepository repo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRepoDetailsModal(context, repo),
    );
  }

  Widget _buildRepoDetailsModal(BuildContext context, GitHubRepository repo) {
    final repoStatus = RepoStatusService.getRepoStatusWithData(repo.id, repo);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          repo.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  if (repo.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      repo.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Status Management Section
                  RepoStatusSelector(
                    currentStatus:
                        repoStatus?.status ?? ProjectStatus.notStarted,
                    onStatusChanged: (status) async {
                      await RepoStatusService.updateProjectStatus(
                        repo.id,
                        status,
                      );
                      setState(() {});
                    },
                    notes: repoStatus?.notes,
                    onNotesChanged: (notes) async {
                      await RepoStatusService.updateProjectStatus(
                        repo.id,
                        repoStatus?.status ?? ProjectStatus.notStarted,
                        notes: notes,
                      );
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildStatChip(
                        context,
                        'Stars',
                        repo.stars.toString(),
                        Icons.star,
                      ),
                      _buildStatChip(
                        context,
                        'Forks',
                        repo.forks.toString(),
                        Icons.fork_right,
                      ),
                      if (repo.language.isNotEmpty)
                        _buildStatChip(
                          context,
                          'Language',
                          repo.language,
                          Icons.code,
                        ),
                      _buildStatChip(
                        context,
                        'Issues',
                        repo.openIssuesCount.toString(),
                        Icons.bug_report,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement open in browser
                          },
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Open in GitHub'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement copy clone URL
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Clone URL'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
