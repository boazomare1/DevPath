import 'package:flutter/material.dart';
import '../services/gamification_service.dart' as gamification;
import '../theme/app_colors.dart';

class StreakWidget extends StatelessWidget {
  final gamification.UserStats stats;
  final VoidCallback? onTap;

  const StreakWidget({
    super.key,
    required this.stats,
    this.onTap,
  });

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
              AppColors.warning.withOpacity(0.1),
              AppColors.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.warning.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Learning Streaks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (stats.dailyStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${stats.dailyStreak} days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Streak stats
            Row(
              children: [
                Expanded(
                  child: _buildStreakStat(
                    context,
                    'Daily',
                    '${stats.dailyStreak}',
                    Icons.calendar_today,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStreakStat(
                    context,
                    'Weekly',
                    '${stats.weeklyStreak}',
                    Icons.date_range,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStreakStat(
                    context,
                    'Best',
                    '${stats.longestStreak}',
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Streak progress bar
            _buildStreakProgress(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakProgress(BuildContext context) {
    // Calculate streak progress (0-7 days for daily streak)
    final progress = (stats.dailyStreak % 7) / 7.0;
    final streakLevel = (stats.dailyStreak / 7).floor() + 1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Streak Level: $streakLevel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '${(progress * 7).toInt()}/7 days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
        ),
        const SizedBox(height: 8),
        Text(
          _getStreakMotivation(stats.dailyStreak),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _getStreakMotivation(int streak) {
    if (streak == 0) {
      return "Start your learning journey today! 🚀";
    } else if (streak < 3) {
      return "Great start! Keep the momentum going! 💪";
    } else if (streak < 7) {
      return "You're building a great habit! 🔥";
    } else if (streak < 14) {
      return "Amazing consistency! You're on fire! 🎯";
    } else if (streak < 30) {
      return "Incredible dedication! You're unstoppable! ⚡";
    } else {
      return "Legendary commitment! You're a learning champion! 👑";
    }
  }
}

class StreakCalendar extends StatelessWidget {
  final List<DateTime> activeDays;
  final DateTime currentMonth;

  const StreakCalendar({
    super.key,
    required this.activeDays,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Calendar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: firstWeekday - 1 + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox.shrink();
              }
              
              final day = index - firstWeekday + 2;
              final date = DateTime(currentMonth.year, currentMonth.month, day);
              final isActive = activeDays.any((d) => 
                d.year == date.year && 
                d.month == date.month && 
                d.day == date.day
              );
              final isToday = date.day == DateTime.now().day && 
                             date.month == DateTime.now().month && 
                             date.year == DateTime.now().year;
              
              return Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.warning
                      : isToday
                          ? AppColors.primary.withOpacity(0.3)
                          : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: isToday
                      ? Border.all(color: AppColors.primary, width: 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive || isToday
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}