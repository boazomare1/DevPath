import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class SkillStatusChart extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int notStarted;

  const SkillStatusChart({
    super.key,
    required this.completed,
    required this.inProgress,
    required this.notStarted,
  });

  @override
  Widget build(BuildContext context) {
    final total = completed + inProgress + notStarted;

    if (total == 0) {
      return _buildEmptyChart();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Legend
          Expanded(flex: 1, child: _buildLegend()),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No skills to display',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = completed + inProgress + notStarted;

    return [
      PieChartSectionData(
        value: completed.toDouble(),
        title: '${((completed / total) * 100).toStringAsFixed(0)}%',
        color: AppColors.success,
        radius: 60,
        titleStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: inProgress.toDouble(),
        title: '${((inProgress / total) * 100).toStringAsFixed(0)}%',
        color: AppColors.warning,
        radius: 60,
        titleStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: notStarted.toDouble(),
        title: '${((notStarted / total) * 100).toStringAsFixed(0)}%',
        color: AppColors.textSecondary,
        radius: 60,
        titleStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem('Completed', completed, AppColors.success),
        const SizedBox(height: 12),
        _buildLegendItem('In Progress', inProgress, AppColors.warning),
        const SizedBox(height: 12),
        _buildLegendItem('Not Started', notStarted, AppColors.textSecondary),
      ],
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
