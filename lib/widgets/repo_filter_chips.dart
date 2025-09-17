import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/repo_status.dart';

class RepoFilterChips extends StatelessWidget {
  final String selectedLanguage;
  final bool showActiveOnly;
  final bool showArchivedOnly;
  final ProjectStatus? selectedStatus;
  final bool showStaleOnly;
  final bool showWithIssuesOnly;
  final Function(String) onLanguageChanged;
  final Function(bool) onActiveFilterChanged;
  final Function(bool) onArchivedFilterChanged;
  final Function(ProjectStatus?) onStatusChanged;
  final Function(bool) onStaleFilterChanged;
  final Function(bool) onWithIssuesFilterChanged;

  const RepoFilterChips({
    super.key,
    required this.selectedLanguage,
    required this.showActiveOnly,
    required this.showArchivedOnly,
    required this.selectedStatus,
    required this.showStaleOnly,
    required this.showWithIssuesOnly,
    required this.onLanguageChanged,
    required this.onActiveFilterChanged,
    required this.onArchivedFilterChanged,
    required this.onStatusChanged,
    required this.onStaleFilterChanged,
    required this.onWithIssuesFilterChanged,
  });

  static const List<String> commonLanguages = [
    'All',
    'Dart',
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'C++',
    'C#',
    'Go',
    'Rust',
    'Swift',
    'Kotlin',
    'PHP',
    'Ruby',
    'C',
    'Shell',
    'HTML',
    'CSS',
    'Vue',
    'React',
    'Angular',
    'Flutter',
    'Swift',
    'Objective-C',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Filters
        Row(
          children: [
            Text(
              'Status:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            _buildStatusChip(
              context,
              'Active',
              showActiveOnly,
              Icons.play_circle,
              AppColors.success,
              () => onActiveFilterChanged(!showActiveOnly),
            ),
            const SizedBox(width: 8),
            _buildStatusChip(
              context,
              'Archived',
              showArchivedOnly,
              Icons.archive,
              AppColors.warning,
              () => onArchivedFilterChanged(!showArchivedOnly),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Project Status Filter
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Status:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildStatusChip(
                  context,
                  'All',
                  selectedStatus == null,
                  Icons.all_inclusive,
                  AppColors.primary,
                  () => onStatusChanged(null),
                ),
                ...ProjectStatus.values.map((status) {
                  final isSelected = selectedStatus == status;
                  return _buildStatusChip(
                    context,
                    '${status.emoji} ${status.displayName}',
                    isSelected,
                    Icons.circle,
                    _getStatusColor(status),
                    () => onStatusChanged(isSelected ? null : status),
                  );
                }),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Special Filters
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Special Filters:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildSpecialFilterChip(
                  context,
                  'Stale',
                  Icons.schedule,
                  AppColors.warning,
                  showStaleOnly,
                  () => onStaleFilterChanged(!showStaleOnly),
                ),
                _buildSpecialFilterChip(
                  context,
                  'With Issues',
                  Icons.bug_report,
                  AppColors.error,
                  showWithIssuesOnly,
                  () => onWithIssuesFilterChanged(!showWithIssuesOnly),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Language Filter
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: commonLanguages.length,
                itemBuilder: (context, index) {
                  final language = commonLanguages[index];
                  final isSelected = selectedLanguage == language;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildLanguageChip(
                      context,
                      language,
                      isSelected,
                      () => onLanguageChanged(language),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    bool isSelected,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isSelected
                      ? color
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    isSelected
                        ? color
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  isSelected
                      ? color
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    isSelected
                        ? color
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(
    BuildContext context,
    String language,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          language,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.inProgress:
        return AppColors.success;
      case ProjectStatus.onHold:
        return AppColors.warning;
      case ProjectStatus.completed:
        return AppColors.primary;
      case ProjectStatus.notStarted:
        return AppColors.textSecondary;
    }
  }
}
