import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/skill_project.dart';

class ProjectCard extends StatelessWidget {
  final SkillProject project;
  final Function(bool) onStatusChanged;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              project.isCompleted
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => onStatusChanged(!project.isCompleted),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        project.isCompleted
                            ? AppColors.success
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          project.isCompleted
                              ? AppColors.success
                              : AppColors.borderMedium,
                      width: 2,
                    ),
                  ),
                  child:
                      project.isCompleted
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 12),

              // Project Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        decoration:
                            project.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Difficulty Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getDifficultyColor().withOpacity(0.5),
                  ),
                ),
                child: Text(
                  project.difficulty,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getDifficultyColor(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Requirements
          if (project.requirements.isNotEmpty) ...[
            Text(
              'Requirements:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  project.requirements.map((requirement) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        requirement,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Footer
          Row(
            children: [
              // Estimated Hours
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${project.estimatedHours}h',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),

              const Spacer(),

              // Completion Date
              if (project.isCompleted && project.completedAt != null) ...[
                Icon(Icons.check_circle, size: 16, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  'Completed ${_formatDate(project.completedAt!)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.success,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (project.difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
