import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';
import '../theme/app_colors.dart';

class RoadmapTimeline extends StatelessWidget {
  final PersonalizedRoadmap roadmap;
  final Function(String moduleId, double progress)? onProgressUpdate;

  const RoadmapTimeline({
    super.key,
    required this.roadmap,
    this.onProgressUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Roadmap header
        _buildRoadmapHeader(context),

        const SizedBox(height: 24),

        // Timeline
        _buildTimeline(context),
      ],
    );
  }

  Widget _buildRoadmapHeader(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  roadmap.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(
                    roadmap.difficulty,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  roadmap.difficulty,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getDifficultyColor(roadmap.difficulty),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            roadmap.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 16),

          // Progress overview
          Row(
            children: [
              Expanded(
                child: _buildProgressInfo(
                  context,
                  'Overall Progress',
                  '${(roadmap.overallProgress * 100).toInt()}%',
                  roadmap.overallProgress,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressInfo(
                  context,
                  'Estimated Hours',
                  '${roadmap.totalEstimatedHours}h',
                  null,
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressInfo(
                  context,
                  'Modules',
                  '${roadmap.modules.length}',
                  null,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(
    BuildContext context,
    String label,
    String value,
    double? progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (progress != null) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: roadmap.modules.length,
      itemBuilder: (context, index) {
        final module = roadmap.modules[index];
        final isLast = index == roadmap.modules.length - 1;

        return _buildTimelineItem(context, module, index + 1, isLast);
      },
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    LearningModule module,
    int stepNumber,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and step indicator
        Column(
          children: [
            // Step number circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    module.isCompleted
                        ? AppColors.success
                        : module.progress > 0
                        ? AppColors.primary
                        : Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      module.isCompleted
                          ? AppColors.success
                          : AppColors.primary,
                  width: 2,
                ),
              ),
              child: Center(
                child:
                    module.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                          stepNumber.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            // Timeline line
            if (!isLast)
              Container(
                width: 2,
                height: 100,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Module content
        Expanded(child: _buildModuleCard(context, module)),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, LearningModule module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              module.isCompleted
                  ? AppColors.success.withOpacity(0.3)
                  : module.progress > 0
                  ? AppColors.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module header
          Row(
            children: [
              Expanded(
                child: Text(
                  module.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(module.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  module.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getTypeColor(module.type),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            module.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 16),

          // Module details
          Row(
            children: [
              _buildModuleDetail(
                context,
                Icons.schedule,
                '${module.estimatedHours}h',
                'Duration',
              ),
              const SizedBox(width: 16),
              _buildModuleDetail(
                context,
                Icons.school,
                module.difficulty,
                'Difficulty',
              ),
              const SizedBox(width: 16),
              _buildModuleDetail(
                context,
                Icons.category,
                module.category,
                'Category',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Skills
          if (module.skills.isNotEmpty) ...[
            Text(
              'Skills you\'ll learn:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  module.skills
                      .map((skill) => _buildSkillChip(context, skill))
                      .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Progress bar
          if (module.progress > 0 || module.isCompleted) ...[
            LinearProgressIndicator(
              value: module.progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                module.isCompleted ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(module.progress * 100).toInt()}% Complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (module.isCompleted)
                  Text(
                    'Completed!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showModuleDetails(context, module),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      module.isCompleted
                          ? null
                          : () => _startModule(context, module),
                  icon: Icon(
                    module.isCompleted ? Icons.check : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(module.isCompleted ? 'Completed' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        module.isCompleted
                            ? AppColors.success
                            : AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleDetail(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillChip(BuildContext context, String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        skill,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'theory':
        return AppColors.primary;
      case 'practice':
        return AppColors.success;
      case 'project':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  void _showModuleDetails(BuildContext context, LearningModule module) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(module.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Resources
                  Text(
                    'Learning Resources:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...module.resources.map(
                    (resource) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            _getResourceIcon(resource.type),
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resource.title,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${resource.estimatedMinutes} min • ${resource.type}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tasks
                  Text(
                    'Learning Tasks:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...module.tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            _getTaskIcon(task.type),
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${task.estimatedMinutes} min • ${task.type}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline;
      case 'article':
        return Icons.article_outlined;
      case 'documentation':
        return Icons.description_outlined;
      case 'course':
        return Icons.school_outlined;
      case 'book':
        return Icons.menu_book_outlined;
      default:
        return Icons.link;
    }
  }

  IconData _getTaskIcon(String type) {
    switch (type.toLowerCase()) {
      case 'coding':
        return Icons.code;
      case 'reading':
        return Icons.menu_book;
      case 'project':
        return Icons.build;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.task_alt;
    }
  }

  void _startModule(BuildContext context, LearningModule module) {
    // TODO: Implement module start functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${module.title}...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
