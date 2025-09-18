import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ContributionHeatmap extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> data;

  const ContributionHeatmap({super.key, required this.data});

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
          Row(
            children: [
              Text(
                'Contribution Heatmap',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Last 52 weeks',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            children: [
              Text(
                'Less',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                final intensity = (index + 1) / 5;
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: _getContributionColor(intensity),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                'More',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Heatmap grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month labels
                Row(
                  children: [
                    const SizedBox(width: 20), // Space for day labels
                    ..._getMonthLabels().map(
                      (month) => Container(
                        width: 13 * 7, // 7 days per week
                        child: Text(
                          month,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Day labels and heatmap
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day labels
                    Column(
                      children: [
                        const SizedBox(height: 6),
                        ...['M', 'T', 'W', 'T', 'F', 'S', 'S'].map(
                          (day) => Container(
                            height: 12,
                            width: 20,
                            margin: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              day,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Heatmap grid
                    Column(
                      children:
                          data.entries.map((weekEntry) {
                            return Row(
                              children:
                                  weekEntry.value.map((dayData) {
                                    final contributions =
                                        dayData['contributions'] as int;
                                    final intensity = _getContributionIntensity(
                                      contributions,
                                    );

                                    return Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: _getContributionColor(intensity),
                                        borderRadius: BorderRadius.circular(2),
                                        border:
                                            _isToday(
                                                  dayData['date'] as DateTime,
                                                )
                                                ? Border.all(
                                                  color: AppColors.primary,
                                                  width: 1,
                                                )
                                                : null,
                                      ),
                                      child:
                                          contributions > 0
                                              ? Tooltip(
                                                message:
                                                    '${contributions} contributions on ${_formatDate(dayData['date'] as DateTime)}',
                                                child: Container(),
                                              )
                                              : null,
                                    );
                                  }).toList(),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getMonthLabels() {
    final months = <String>[];
    final now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
      final date = now.subtract(Duration(days: i * 30));
      months.add(_getMonthName(date.month));
    }

    return months;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  double _getContributionIntensity(int contributions) {
    if (contributions == 0) return 0.0;
    if (contributions <= 1) return 0.2;
    if (contributions <= 3) return 0.4;
    if (contributions <= 6) return 0.6;
    if (contributions <= 10) return 0.8;
    return 1.0;
  }

  Color _getContributionColor(double intensity) {
    if (intensity == 0.0) {
      return AppColors.primary.withOpacity(0.1);
    }

    // GitHub-style green gradient
    final baseColor = AppColors.success;
    return Color.fromRGBO(
      (baseColor.red * (0.1 + intensity * 0.9)).round(),
      (baseColor.green * (0.1 + intensity * 0.9)).round(),
      (baseColor.blue * (0.1 + intensity * 0.9)).round(),
      1.0,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
