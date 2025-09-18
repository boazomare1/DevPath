import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../services/analytics_service.dart';
import '../services/enhanced_career_goals_service.dart';
import '../theme/app_colors.dart';

class PDFExportWidget extends StatelessWidget {
  const PDFExportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AnalyticsService, EnhancedCareerGoalsService>(
      builder: (context, analyticsService, careerGoalsService, child) {
        return AlertDialog(
          title: const Text('Export Analytics Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose what to include in your analytics report:'),
              const SizedBox(height: 16),
              _buildExportOptions(context),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  () =>
                      _exportPDF(context, analyticsService, careerGoalsService),
              child: const Text('Export PDF'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportOptions(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Learning Activity'),
          subtitle: const Text('Weekly learning charts and trends'),
          value: true,
          onChanged: (value) {},
        ),
        CheckboxListTile(
          title: const Text('Contribution Heatmap'),
          subtitle: const Text('GitHub-style contribution calendar'),
          value: true,
          onChanged: (value) {},
        ),
        CheckboxListTile(
          title: const Text('Career Goals Progress'),
          subtitle: const Text('Goal readiness and skill gaps'),
          value: true,
          onChanged: (value) {},
        ),
        CheckboxListTile(
          title: const Text('Skill Trends'),
          subtitle: const Text('Skill completion over time'),
          value: true,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Future<void> _exportPDF(
    BuildContext context,
    AnalyticsService analyticsService,
    EnhancedCareerGoalsService careerGoalsService,
  ) async {
    try {
      final pdf = pw.Document();

      // Generate PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildPDFHeader(),
              pw.SizedBox(height: 20),
              _buildSummarySection(analyticsService),
              pw.SizedBox(height: 20),
              _buildLearningActivitySection(analyticsService),
              pw.SizedBox(height: 20),
              _buildCareerGoalsSection(analyticsService, careerGoalsService),
              pw.SizedBox(height: 20),
              _buildSkillTrendsSection(analyticsService),
            ];
          },
        ),
      );

      // Show print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'DevPath_Analytics_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report exported successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  pw.Widget _buildPDFHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DevPath Analytics Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on ${DateTime.now().toString().split(' ')[0]}',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.blue700),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummarySection(AnalyticsService analyticsService) {
    final summary = analyticsService.getAnalyticsSummary();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Learning Time',
                '${summary['totalMinutesThisWeek']} min',
              ),
              _buildSummaryItem(
                'Skills Completed',
                '${summary['totalSkillsCompletedThisWeek']}',
              ),
              _buildSummaryItem(
                'Career Readiness',
                '${summary['averageReadinessPercentage'].toStringAsFixed(1)}%',
              ),
              _buildSummaryItem('Active Goals', '${summary['activeGoals']}'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildLearningActivitySection(AnalyticsService analyticsService) {
    final weeklyData = analyticsService.getWeeklyLearningActivity();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Weekly Learning Activity',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableHeader('Day'),
                  _buildTableHeader('Minutes'),
                  _buildTableHeader('Skills'),
                  _buildTableHeader('Repos'),
                ],
              ),
              ...weeklyData.map(
                (day) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(day['dayName']),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${day['minutesSpent']}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${day['skillsCompleted']}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${day['repositoriesWorkedOn']}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCareerGoalsSection(
    AnalyticsService analyticsService,
    EnhancedCareerGoalsService careerGoalsService,
  ) {
    final progress = analyticsService.getCareerGoalsProgress();

    if (progress.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Center(
          child: pw.Text(
            'No career goals set',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
          ),
        ),
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Career Goals Progress',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableHeader('Goal'),
                  _buildTableHeader('Readiness'),
                  _buildTableHeader('Gaps'),
                  _buildTableHeader('Completed'),
                ],
              ),
              ...progress.map(
                (goal) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        goal['goalTitle'],
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${(goal['readinessPercentage'] as double).toStringAsFixed(1)}%',
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${goal['skillGaps']}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${goal['completedRecommendations']}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSkillTrendsSection(AnalyticsService analyticsService) {
    final trendsData = analyticsService.getSkillCompletionTrends();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Skill Completion Trends (Last 30 Days)',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'This section shows your skill completion progress over the last 30 days. '
            'Track your learning momentum and identify patterns in your skill development.',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableHeader('Date'),
                  _buildTableHeader('Total'),
                  _buildTableHeader('Completed'),
                  _buildTableHeader('In Progress'),
                  _buildTableHeader('Rate %'),
                ],
              ),
              ...trendsData
                  .take(7)
                  .map(
                    (day) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            _formatDate(day['date'] as DateTime),
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${day['totalSkills']}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${day['completedSkills']}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${day['inProgressSkills']}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${(day['completionRate'] as double).toStringAsFixed(1)}%',
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
