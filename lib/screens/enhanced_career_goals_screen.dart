import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/enhanced_career_goals_service.dart';
import '../widgets/gap_analysis_widget.dart';
import '../theme/app_colors.dart';

class EnhancedCareerGoalsScreen extends StatefulWidget {
  const EnhancedCareerGoalsScreen({super.key});

  @override
  State<EnhancedCareerGoalsScreen> createState() =>
      _EnhancedCareerGoalsScreenState();
}

class _EnhancedCareerGoalsScreenState extends State<EnhancedCareerGoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  tabs: const [
                    Tab(text: 'Goals'),
                    Tab(text: 'Gap Analysis'),
                    Tab(text: 'Companies'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGoalsTab(context),
                    _buildGapAnalysisTab(context),
                    _buildCompaniesTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "career_goals_fab",
        onPressed: () => _showCreateGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Career Goals',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.work, size: 32, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab(BuildContext context) {
    return Consumer<EnhancedCareerGoalsService>(
      builder: (context, service, child) {
        final goals = service.activeGoals;

        if (goals.isEmpty) {
          return _buildEmptyGoalsState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildGoalCard(context, goal),
            );
          },
        );
      },
    );
  }

  Widget _buildGapAnalysisTab(BuildContext context) {
    return Consumer<EnhancedCareerGoalsService>(
      builder: (context, service, child) {
        final goals = service.activeGoals;

        if (goals.isEmpty) {
          return _buildEmptyGapAnalysisState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GapAnalysisWidget(
                goal: goal,
                onTap: () => _showGapAnalysisDetails(context, goal),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompaniesTab(BuildContext context) {
    return Consumer<EnhancedCareerGoalsService>(
      builder: (context, service, child) {
        final companies = service.companies;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: companies.length,
          itemBuilder: (context, index) {
            final company = companies[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCompanyCard(context, company),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyGoalsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Career Goals Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your career goals and track your progress!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateGoalDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGapAnalysisState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Gap Analysis Available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a career goal to see skill gap analysis!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, EnhancedCareerGoal goal) {
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
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${goal.targetRole}${goal.targetCompany.isNotEmpty ? ' at ${goal.targetCompany}' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          LinearProgressIndicator(
            value: goal.readinessPercentage / 100,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getReadinessColor(goal.readinessPercentage),
            ),
          ),

          const SizedBox(height: 16),

          // Details
          Row(
            children: [
              _buildDetailItem(
                context,
                Icons.calendar_today,
                'Target Date',
                _formatDate(goal.targetDate),
              ),
              const SizedBox(width: 16),
              _buildDetailItem(
                context,
                Icons.attach_money,
                'Salary',
                '\$${goal.targetSalary.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              ),
              const SizedBox(width: 16),
              _buildDetailItem(
                context,
                Icons.trending_up,
                'Experience',
                goal.experienceLevel,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Skill gaps summary
          if (goal.skillGaps.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '${goal.skillGaps.length} skill gaps identified',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context, Company company) {
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
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.business, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      company.industry,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            company.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Available roles
          Text(
            'Available Roles:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                company.roleRequirements.keys
                    .take(3)
                    .map(
                      (role) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),

          const SizedBox(height: 16),

          // Location and website
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                company.location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showCompanyDetails(context, company),
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => CreateGoalDialog());
  }

  void _showGapAnalysisDetails(BuildContext context, EnhancedCareerGoal goal) {
    showDialog(
      context: context,
      builder: (context) => GapAnalysisDetailsDialog(goal: goal),
    );
  }

  void _showCompanyDetails(BuildContext context, Company company) {
    showDialog(
      context: context,
      builder: (context) => CompanyDetailsDialog(company: company),
    );
  }

  Color _getReadinessColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.primary;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class CreateGoalDialog extends StatefulWidget {
  @override
  _CreateGoalDialogState createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<CreateGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCompany = '';
  String _selectedRole = '';
  String _selectedIndustry = '';
  String _selectedExperienceLevel = '';
  int _targetSalary = 100000;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedCareerGoalsService>(
      builder: (context, service, child) {
        return AlertDialog(
          title: const Text('Create Career Goal'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Title',
                      hintText: 'e.g., Senior Engineer at Google',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty == true
                                ? 'Please enter a title'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe your career goal...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCompany.isEmpty ? null : _selectedCompany,
                    decoration: const InputDecoration(
                      labelText: 'Target Company',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        service.companies
                            .map(
                              (company) => DropdownMenuItem(
                                value: company.name,
                                child: Text(company.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCompany = value ?? '';
                        _selectedRole = '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole.isEmpty ? null : _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Target Role',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        service
                            .getAvailableRolesForCompany(_selectedCompany)
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedIndustry.isEmpty ? null : _selectedIndustry,
                    decoration: const InputDecoration(
                      labelText: 'Industry',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        service
                            .getAvailableIndustries()
                            .map(
                              (industry) => DropdownMenuItem(
                                value: industry,
                                child: Text(industry),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIndustry = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value:
                        _selectedExperienceLevel.isEmpty
                            ? null
                            : _selectedExperienceLevel,
                    decoration: const InputDecoration(
                      labelText: 'Experience Level',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        service
                            .getAvailableExperienceLevels()
                            .map(
                              (level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedExperienceLevel = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _targetSalary.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Target Salary',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _targetSalary = int.tryParse(value) ?? 100000;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _createGoal,
              child: const Text('Create Goal'),
            ),
          ],
        );
      },
    );
  }

  void _createGoal() async {
    if (_formKey.currentState?.validate() == true) {
      final service = Provider.of<EnhancedCareerGoalsService>(
        context,
        listen: false,
      );

      await service.createCareerGoal(
        title: _titleController.text,
        description: _descriptionController.text,
        targetRole: _selectedRole,
        targetCompany: _selectedCompany,
        industry: _selectedIndustry,
        targetSalary: _targetSalary,
        experienceLevel: _selectedExperienceLevel,
        targetDate: _targetDate,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

class GapAnalysisDetailsDialog extends StatelessWidget {
  final EnhancedCareerGoal goal;

  const GapAnalysisDetailsDialog({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Gap Analysis: ${goal.title}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Skill Gaps'),
                  Tab(text: 'AI Recommendations'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SkillGapList(
                      skillGaps: goal.skillGaps,
                      onGapTap: (gap) => _showGapDetails(context, gap),
                    ),
                    AIRecommendationsList(
                      recommendations: goal.aiRecommendations,
                      onRecommendationTap:
                          (rec) => _showRecommendationDetails(context, rec),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showGapDetails(BuildContext context, SkillGap gap) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(gap.skillName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${gap.category}'),
                Text('Importance: ${gap.importance}'),
                Text('Current Level: ${gap.currentLevel}'),
                Text('Target Level: ${gap.targetLevel}'),
                Text('Estimated Hours: ${gap.estimatedHours}h'),
                Text('Priority: ${gap.priority}'),
                if (gap.resources.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Resources:'),
                  ...gap.resources.map((resource) => Text('• $resource')),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showRecommendationDetails(
    BuildContext context,
    AIRecommendation recommendation,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(recommendation.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recommendation.description),
                const SizedBox(height: 8),
                Text('Type: ${recommendation.type}'),
                Text('Difficulty: ${recommendation.difficulty}'),
                Text('Estimated Hours: ${recommendation.estimatedHours}h'),
                Text('Priority: ${recommendation.priority}'),
                Text('Reason: ${recommendation.reason}'),
                if (recommendation.resources.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Resources:'),
                  ...recommendation.resources.map(
                    (resource) => Text('• $resource'),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class CompanyDetailsDialog extends StatelessWidget {
  final Company company;

  const CompanyDetailsDialog({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(company.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Industry: ${company.industry}'),
            Text('Location: ${company.location}'),
            const SizedBox(height: 8),
            Text(company.description),
            const SizedBox(height: 16),
            const Text(
              'Available Roles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...company.roleRequirements.keys.map((role) => Text('• $role')),
            const SizedBox(height: 16),
            const Text(
              'Benefits:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...company.benefits.map((benefit) => Text('• $benefit')),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
