import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/github_auth_service.dart';
import '../services/github_insights_service.dart';
import '../theme/app_colors.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  RepositoryInsights? _insights;
  bool _isLoading = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load if not already loading and not already loaded
    final authService = context.watch<GitHubAuthService>();
    if (authService.isAuthenticated && 
        authService.repositories.isNotEmpty && 
        !_isLoading && 
        !_hasLoaded) {
      _loadInsights();
    }
  }

  Future<void> _loadInsights({bool forceRefresh = false}) async {
    final authService = context.read<GitHubAuthService>();
    if (!authService.isAuthenticated || authService.repositories.isEmpty) {
      return;
    }

    // Don't reload if already loaded and not forcing refresh
    if (_hasLoaded && !forceRefresh) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get access token from the auth service
      final accessToken = await authService.getAccessToken();
      if (accessToken != null) {
        // Add timeout to prevent infinite loading
        final insights = await GitHubInsightsService.getRepositoryInsights(
          accessToken,
          authService.repositories,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            debugPrint('Insights loading timed out after 30 seconds');
            return RepositoryInsights.empty();
          },
        );

        if (mounted) {
          setState(() {
            _insights = insights;
            _isLoading = false;
            _hasLoaded = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading insights: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                title: const Text('Repository Insights'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                actions: [
                  IconButton(
                    onPressed: () => _loadInsights(forceRefresh: true),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Insights',
                  ),
                ],
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.surface.withOpacity(0.9),
                        Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Consumer<GitHubAuthService>(
                      builder: (context, authService, child) {
                        if (!authService.isAuthenticated) {
                          return _buildNotConnectedView(context);
                        }

                        final repos = authService.repositories;
                        if (repos.isEmpty) {
                          return _buildNoReposView(context);
                        }

                        if (_isLoading) {
                          return _buildLoadingView(context);
                        }

                        if (_insights == null) {
                          return _buildErrorView(context);
                        }

                        return Column(
                          children: [
                            // Language Breakdown Chart
                            _buildLanguageBreakdownChart(context, _insights!),

                            const SizedBox(height: 32),

                            // Commit Activity Chart
                            _buildCommitActivityChart(context, _insights!),

                            const SizedBox(height: 32),

                            // Repository Statistics
                            _buildRepositoryStats(context, _insights!),

                            const SizedBox(height: 24),

                            // Refresh Button
                            _buildRefreshButton(context),
                          ],
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotConnectedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Connect to GitHub',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Connect your GitHub account to view repository insights and analytics',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoReposView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.folder_open,
              size: 64,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Repositories',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No repositories found. Make sure you have some repositories in your GitHub account.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Loading insights...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to Load Insights',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to fetch repository insights. Please try again.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInsights,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loadInsights,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh Insights'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLanguageBreakdownChart(
    BuildContext context,
    RepositoryInsights insights,
  ) {
    final languageData = insights.languageStats;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Languages Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(languageData),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageLegend(context, languageData),
        ],
      ),
    );
  }

  Widget _buildCommitActivityChart(
    BuildContext context,
    RepositoryInsights insights,
  ) {
    final commitData = insights.commitActivity;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Commit Activity (Last 6 Months)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: _buildBarChartGroups(commitData),
                titlesData: _buildBarChartTitles(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${commitData[groupIndex].month}\n${rod.toY.round()} commits',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepositoryStats(
    BuildContext context,
    RepositoryInsights insights,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Repository Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Repositories',
                  insights.totalRepositories.toString(),
                  Icons.folder,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Stars',
                  insights.totalStars.toString(),
                  Icons.star,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Forks',
                  insights.totalForks.toString(),
                  Icons.fork_right,
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Languages Used',
                  insights.languagesUsed.toString(),
                  Icons.code,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Avg Commits/Month',
                  insights.avgCommitsPerMonth.toStringAsFixed(1),
                  Icons.timeline,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Most Active Month',
                  insights.mostActiveMonth,
                  Icons.calendar_today,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageLegend(
    BuildContext context,
    Map<String, LanguageStats> languageData,
  ) {
    final colors = _getLanguageColors();
    final entries =
        languageData.entries.toList()..sort(
          (a, b) => b.value.repositoryCount.compareTo(a.value.repositoryCount),
        );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          entries.map((entry) {
            final color = colors[entry.key] ?? AppColors.primary;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.key} (${entry.value.repositoryCount})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, LanguageStats> languageData,
  ) {
    final colors = _getLanguageColors();
    final total = languageData.values.fold(
      0,
      (sum, stats) => sum + stats.repositoryCount,
    );

    return languageData.entries.map((entry) {
      final percentage = (entry.value.repositoryCount / total) * 100;
      final color = colors[entry.key] ?? AppColors.primary;

      return PieChartSectionData(
        color: color,
        value: entry.value.repositoryCount.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarChartGroups(List<CommitActivityData> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.commits.toDouble(),
            color: AppColors.secondary,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  FlTitlesData _buildBarChartTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
            if (value.toInt() >= 0 && value.toInt() < months.length) {
              return Text(
                months[value.toInt()],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              );
            }
            return const Text('');
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Map<String, Color> _getLanguageColors() {
    return {
      'Dart': AppColors.primary,
      'JavaScript': AppColors.warning,
      'TypeScript': AppColors.secondary,
      'Python': AppColors.success,
      'Java': AppColors.error,
      'C++': const Color(0xFF00599C),
      'C#': const Color(0xFF239120),
      'Go': const Color(0xFF00ADD8),
      'Rust': const Color(0xFFDEA584),
      'Swift': const Color(0xFFFA7343),
      'Kotlin': const Color(0xFF7F52FF),
      'PHP': const Color(0xFF777BB4),
      'Ruby': const Color(0xFFCC342D),
      'Unknown': Colors.grey,
    };
  }
}
