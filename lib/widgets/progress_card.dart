import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/progress_summary.dart';

class ProgressCard extends StatelessWidget {
  final ProgressSummary progress;

  const ProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${progress.completionPercentage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentStart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.overallProgress,
              backgroundColor: AppColors.borderLight.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accentStart,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              _buildStatItem(
                'Completed',
                progress.completedSkills,
                AppColors.success,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                'In Progress',
                progress.inProgressSkills,
                AppColors.warning,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                'Not Started',
                progress.notStartedSkills,
                AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
