import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/skill_category.dart';

class CategoryProgressCard extends StatelessWidget {
  final SkillCategory category;
  final int completedCount;
  final int totalCount;

  const CategoryProgressCard({
    super.key,
    required this.category,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final progressPercentage = (progress * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      category.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$completedCount/$totalCount',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentStart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderLight.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(progress),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),

          // Progress Percentage
          Text(
            '$progressPercentage% Complete',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress == 0) {
      return AppColors.textSecondary;
    } else if (progress < 0.3) {
      return AppColors.warning;
    } else if (progress < 0.7) {
      return AppColors.info;
    } else {
      return AppColors.success;
    }
  }
}
