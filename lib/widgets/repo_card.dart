import 'package:flutter/material.dart';
import '../models/github_repository.dart';
import '../models/repo_status.dart';
import '../services/repo_status_service.dart';
import '../theme/app_colors.dart';

class RepoCard extends StatelessWidget {
  final GitHubRepository repository;
  final VoidCallback? onTap;

  const RepoCard({super.key, required this.repository, this.onTap});

  @override
  Widget build(BuildContext context) {
    final repoStatus = RepoStatusService.getRepoStatusWithData(
      repository.id,
      repository,
    );
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorderColor(context, repoStatus),
            width: _getBorderWidth(repoStatus),
          ),
          boxShadow: [
            BoxShadow(
              color: _getShadowColor(repoStatus),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and visibility
            Row(
              children: [
                Expanded(
                  child: Text(
                    repository.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                _buildVisibilityBadge(context),
              ],
            ),
            
            // Status and highlights row
            if (repoStatus != null) ...[
              const SizedBox(height: 8),
              _buildStatusAndHighlights(context, repoStatus),
            ],

            if (repository.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                repository.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                if (repository.language.isNotEmpty) ...[
                  _buildStatItem(
                    context,
                    repository.language,
                    Icons.code,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                ],
                _buildStatItem(
                  context,
                  '${repository.stars}',
                  Icons.star,
                  AppColors.warning,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  context,
                  '${repository.forks}',
                  Icons.fork_right,
                  AppColors.secondary,
                ),
                if (repository.openIssuesCount > 0) ...[
                  const SizedBox(width: 16),
                  _buildStatItem(
                    context,
                    '${repository.openIssuesCount}',
                    Icons.bug_report,
                    AppColors.error,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Footer with last commit date
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated ${_formatDate(repository.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const Spacer(),
                if (repository.topics != null &&
                    repository.topics!.isNotEmpty) ...[
                  Icon(
                    Icons.tag,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    repository.topics!.split(',').take(2).join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityBadge(BuildContext context) {
    if (repository.archived) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.archive, size: 12, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              'Archived',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (repository.isPrivate) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Text(
              'Private',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, size: 12, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              'Public',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndHighlights(BuildContext context, RepoStatus status) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Project Status
        _buildStatusBadge(context, status.status),
        
        // Stale indicator
        if (status.isStale)
          _buildHighlightBadge(
            context,
            'Stale',
            Icons.schedule,
            AppColors.warning,
          ),
        
        // Open issues indicator
        if (status.openIssuesCount > 0)
          _buildHighlightBadge(
            context,
            '${status.openIssuesCount} Issues',
            Icons.bug_report,
            AppColors.error,
          ),
        
        // Recent activity indicator
        if (status.hasRecentActivity)
          _buildHighlightBadge(
            context,
            'Active',
            Icons.trending_up,
            AppColors.success,
          ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, ProjectStatus status) {
    final color = _getStatusColor(context, status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBadge(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, ProjectStatus status) {
    switch (status) {
      case ProjectStatus.inProgress:
        return AppColors.success;
      case ProjectStatus.onHold:
        return AppColors.warning;
      case ProjectStatus.completed:
        return AppColors.primary;
      case ProjectStatus.notStarted:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  Color _getBorderColor(BuildContext context, RepoStatus? status) {
    if (status == null) {
      return Theme.of(context).colorScheme.outline.withOpacity(0.1);
    }
    
    if (status.isStale) {
      return AppColors.warning.withOpacity(0.5);
    }
    
    if (status.openIssuesCount > 0) {
      return AppColors.error.withOpacity(0.3);
    }
    
    if (status.hasRecentActivity) {
      return AppColors.success.withOpacity(0.3);
    }
    
    return Theme.of(context).colorScheme.outline.withOpacity(0.1);
  }

  double _getBorderWidth(RepoStatus? status) {
    if (status == null) return 1.0;
    
    if (status.isStale || status.openIssuesCount > 0) {
      return 2.0;
    }
    
    return 1.0;
  }

  Color _getShadowColor(RepoStatus? status) {
    if (status == null) {
      return Colors.black.withOpacity(0.05);
    }
    
    if (status.isStale) {
      return AppColors.warning.withOpacity(0.1);
    }
    
    if (status.openIssuesCount > 0) {
      return AppColors.error.withOpacity(0.1);
    }
    
    if (status.hasRecentActivity) {
      return AppColors.success.withOpacity(0.1);
    }
    
    return Colors.black.withOpacity(0.05);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}
