import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/skill.dart';
import '../models/skill_status.dart';

class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;
  final Function(SkillStatus) onStatusChanged;

  const SkillCard({
    super.key,
    required this.skill,
    required this.onTap,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getBorderColor(), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status Indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // Skill Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (skill.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          skill.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Category Icon
                Text(skill.category.icon, style: const TextStyle(fontSize: 20)),
              ],
            ),

            const SizedBox(height: 12),

            // Tags and Priority
            Row(
              children: [
                // Priority
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getPriorityColor().withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'Priority ${skill.priority}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Tags
                if (skill.tags.isNotEmpty) ...[
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children:
                          skill.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Status Actions
            Row(
              children: [
                Expanded(
                  child: _buildStatusButton(
                    'Not Started',
                    SkillStatus.notStarted,
                    Icons.radio_button_unchecked,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusButton(
                    'In Progress',
                    SkillStatus.inProgress,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusButton(
                    'Completed',
                    SkillStatus.completed,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, SkillStatus status, IconData icon) {
    final isSelected = skill.status == status;

    return GestureDetector(
      onTap: () => onStatusChanged(status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _getStatusColor() : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _getStatusColor() : AppColors.borderMedium,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : _getStatusColor(),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _getStatusColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (skill.status) {
      case SkillStatus.completed:
        return AppColors.success;
      case SkillStatus.inProgress:
        return AppColors.warning;
      case SkillStatus.notStarted:
        return AppColors.textSecondary;
    }
  }

  Color _getBorderColor() {
    switch (skill.status) {
      case SkillStatus.completed:
        return AppColors.success.withOpacity(0.3);
      case SkillStatus.inProgress:
        return AppColors.warning.withOpacity(0.3);
      case SkillStatus.notStarted:
        return AppColors.glassBorder;
    }
  }

  Color _getPriorityColor() {
    switch (skill.priority) {
      case 5:
        return AppColors.error;
      case 4:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      case 2:
        return AppColors.success;
      case 1:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}
