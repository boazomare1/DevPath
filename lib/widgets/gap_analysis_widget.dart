import 'package:flutter/material.dart';
import '../services/enhanced_career_goals_service.dart';
import '../theme/app_colors.dart';

class GapAnalysisWidget extends StatelessWidget {
  final EnhancedCareerGoal goal;
  final VoidCallback? onTap;

  const GapAnalysisWidget({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getReadinessColor(goal.readinessPercentage).withOpacity(0.1),
              _getReadinessColor(goal.readinessPercentage).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getReadinessColor(
              goal.readinessPercentage,
            ).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with readiness percentage
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Readiness for ${goal.targetRole}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (goal.targetCompany.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'at ${goal.targetCompany}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getReadinessColor(goal.readinessPercentage),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${goal.readinessPercentage.toInt()}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Readiness progress bar
            _buildReadinessProgress(context),

            const SizedBox(height: 16),

            // Skill gaps summary
            _buildSkillGapsSummary(context),

            const SizedBox(height: 16),

            // AI recommendations preview
            if (goal.aiRecommendations.isNotEmpty)
              _buildRecommendationsPreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Readiness',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              _getReadinessLabel(goal.readinessPercentage),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getReadinessColor(goal.readinessPercentage),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: goal.readinessPercentage / 100,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getReadinessColor(goal.readinessPercentage),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillGapsSummary(BuildContext context) {
    final criticalGaps =
        goal.skillGaps.where((gap) => gap.priority == 'Critical').length;
    final highGaps =
        goal.skillGaps.where((gap) => gap.priority == 'High').length;
    final mediumGaps =
        goal.skillGaps.where((gap) => gap.priority == 'Medium').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Gaps',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (criticalGaps > 0) ...[
              _buildGapChip(context, 'Critical', criticalGaps, AppColors.error),
              const SizedBox(width: 8),
            ],
            if (highGaps > 0) ...[
              _buildGapChip(context, 'High', highGaps, AppColors.warning),
              const SizedBox(width: 8),
            ],
            if (mediumGaps > 0) ...[
              _buildGapChip(context, 'Medium', mediumGaps, AppColors.primary),
            ],
            if (goal.skillGaps.isEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No gaps!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildGapChip(
    BuildContext context,
    String priority,
    int count,
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
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$priority: $count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              'AI Recommendations',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${goal.aiRecommendations.length} personalized recommendations to bridge skill gaps',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Color _getReadinessColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.primary;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _getReadinessLabel(double percentage) {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 80) return 'Very Good';
    if (percentage >= 70) return 'Good';
    if (percentage >= 60) return 'Fair';
    if (percentage >= 40) return 'Needs Work';
    return 'Needs Significant Work';
  }
}

class SkillGapList extends StatelessWidget {
  final List<SkillGap> skillGaps;
  final Function(SkillGap)? onGapTap;

  const SkillGapList({super.key, required this.skillGaps, this.onGapTap});

  @override
  Widget build(BuildContext context) {
    if (skillGaps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Skill Gaps!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have all the required skills for this role.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skillGaps.length,
      itemBuilder: (context, index) {
        final gap = skillGaps[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSkillGapCard(context, gap),
        );
      },
    );
  }

  Widget _buildSkillGapCard(BuildContext context, SkillGap gap) {
    return GestureDetector(
      onTap: () => onGapTap?.call(gap),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getPriorityColor(gap.priority).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with skill name and priority
            Row(
              children: [
                Expanded(
                  child: Text(
                    gap.skillName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(gap.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gap.priority,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getPriorityColor(gap.priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Skill level progress
            Row(
              children: [
                Text(
                  'Level ${gap.currentLevel} → ${gap.targetLevel}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                Text(
                  '${gap.estimatedHours}h estimated',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            LinearProgressIndicator(
              value: gap.currentLevel / gap.targetLevel,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getPriorityColor(gap.priority),
              ),
            ),

            const SizedBox(height: 8),

            // Category and importance
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(gap.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gap.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getCategoryColor(gap.category),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getImportanceColor(gap.importance).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gap.importance,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getImportanceColor(gap.importance),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (gap.isRequired) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Required',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return AppColors.error;
      case 'High':
        return AppColors.warning;
      case 'Medium':
        return AppColors.primary;
      case 'Low':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Programming Languages':
        return AppColors.primary;
      case 'Frameworks':
        return AppColors.secondary;
      case 'System Design':
        return AppColors.warning;
      case 'Databases':
        return AppColors.success;
      case 'Tools':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Color _getImportanceColor(String importance) {
    switch (importance) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}

class AIRecommendationsList extends StatelessWidget {
  final List<AIRecommendation> recommendations;
  final Function(AIRecommendation)? onRecommendationTap;

  const AIRecommendationsList({
    super.key,
    required this.recommendations,
    this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No AI Recommendations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete skill gap analysis to get personalized recommendations.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRecommendationCard(context, recommendation),
        );
      },
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    AIRecommendation recommendation,
  ) {
    return GestureDetector(
      onTap: () => onRecommendationTap?.call(recommendation),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getTypeColor(recommendation.type).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and type
            Row(
              children: [
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(recommendation.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recommendation.type,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getTypeColor(recommendation.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              recommendation.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 12),

            // Details row
            Row(
              children: [
                _buildDetailChip(
                  context,
                  Icons.schedule,
                  '${recommendation.estimatedHours}h',
                  AppColors.primary,
                ),
                const SizedBox(width: 8),
                _buildDetailChip(
                  context,
                  Icons.trending_up,
                  recommendation.difficulty,
                  AppColors.warning,
                ),
                const SizedBox(width: 8),
                _buildDetailChip(
                  context,
                  Icons.priority_high,
                  recommendation.priority,
                  _getPriorityColor(recommendation.priority),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Skills
            if (recommendation.skills.isNotEmpty) ...[
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    recommendation.skills
                        .map(
                          (skill) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              skill,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Course':
        return AppColors.primary;
      case 'Project':
        return AppColors.success;
      case 'Practice':
        return AppColors.warning;
      case 'Certification':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return AppColors.error;
      case 'High':
        return AppColors.warning;
      case 'Medium':
        return AppColors.primary;
      case 'Low':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }
}
