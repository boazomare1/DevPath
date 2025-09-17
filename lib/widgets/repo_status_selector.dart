import 'package:flutter/material.dart';
import '../models/repo_status.dart';
import '../theme/app_colors.dart';

class RepoStatusSelector extends StatelessWidget {
  final ProjectStatus currentStatus;
  final Function(ProjectStatus) onStatusChanged;
  final String? notes;
  final Function(String)? onNotesChanged;

  const RepoStatusSelector({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    this.notes,
    this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // Status Options
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: ProjectStatus.values.map((status) {
              final isSelected = currentStatus == status;
              return _buildStatusChip(
                context,
                status,
                isSelected,
                () => onStatusChanged(status),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Notes Section
          if (onNotesChanged != null) ...[
            Text(
              'Notes (Optional)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: onNotesChanged,
              controller: TextEditingController(text: notes ?? ''),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes about this project...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    ProjectStatus status,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final color = _getStatusColor(context, status);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  status.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected 
                        ? color.withOpacity(0.8)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
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
}