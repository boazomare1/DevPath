import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_assistant_service.dart';
import '../services/github_auth_service.dart';
import '../services/gamification_service.dart';
import '../widgets/roadmap_timeline.dart';
import '../models/skill.dart';
import '../theme/app_colors.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _roleController = TextEditingController();
  String _selectedExperienceLevel = 'Beginner';
  bool _isGenerating = false;
  PersonalizedRoadmap? _selectedRoadmap;

  @override
  void dispose() {
    _roleController.dispose();
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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'AI Learning Assistant',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.secondary.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: _showCreateRoadmapDialog,
                    icon: const Icon(Icons.auto_awesome),
                    tooltip: 'Generate AI Roadmap',
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: Consumer<AIAssistantService>(
                  builder: (context, aiService, child) {
                    if (aiService.isLoading) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('AI is analyzing your skills and generating a personalized roadmap...'),
                            ],
                          ),
                        ),
                      );
                    }

                    if (aiService.roadmaps.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildEmptyState(context),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // Roadmap selector
                        _buildRoadmapSelector(context, aiService.roadmaps),
                        
                        const SizedBox(height: 24),
                        
                        // Selected roadmap timeline
                        if (_selectedRoadmap != null)
                          RoadmapTimeline(
                            roadmap: _selectedRoadmap!,
                            onProgressUpdate: (moduleId, progress) {
                              // TODO: Update progress
                            },
                          ),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No AI Roadmaps Yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let our AI analyze your skills and GitHub activity to create a personalized learning path!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showCreateRoadmapDialog,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate AI Roadmap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSelector(BuildContext context, List<PersonalizedRoadmap> roadmaps) {
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
          Text(
            'Your AI-Generated Roadmaps',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PersonalizedRoadmap>(
            value: _selectedRoadmap,
            decoration: const InputDecoration(
              labelText: 'Select a roadmap to view',
              border: OutlineInputBorder(),
            ),
            items: roadmaps.map((roadmap) {
              return DropdownMenuItem(
                value: roadmap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roadmap.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${roadmap.modules.length} modules • ${roadmap.totalEstimatedHours}h • ${(roadmap.overallProgress * 100).toInt()}% complete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (roadmap) {
              setState(() {
                _selectedRoadmap = roadmap;
              });
            },
          ),
        ],
      ),
    );
  }

  void _showCreateRoadmapDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate AI Learning Roadmap'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Our AI will analyze your current skills and GitHub activity to create a personalized learning path.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Target Role',
                  hintText: 'e.g., Senior Frontend Developer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedExperienceLevel,
                decoration: const InputDecoration(
                  labelText: 'Current Experience Level',
                  border: OutlineInputBorder(),
                ),
                items: ['Beginner', 'Intermediate', 'Advanced']
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExperienceLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI will analyze your skills and GitHub repositories to create the most relevant learning path.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _generateRoadmap,
            child: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateRoadmap() async {
    if (_roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a target role'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final aiService = context.read<AIAssistantService>();
      final authService = context.read<GitHubAuthService>();
      final gamificationService = context.read<GamificationService>();

      // Get current skills (placeholder - in real app, get from skills service)
      final skills = <Skill>[]; // TODO: Get from skills service
      final repositories = authService.repositories;

      final roadmap = await aiService.generatePersonalizedRoadmap(
        targetRole: _roleController.text.trim(),
        currentSkills: skills,
        repositories: repositories,
        experienceLevel: _selectedExperienceLevel,
      );

      if (roadmap != null) {
        // Award XP for generating roadmap
        await gamificationService.addXP(100);
        
        // Update achievement progress
        await gamificationService.updateAchievementProgress('first_skill', 1);

        if (mounted) {
          Navigator.of(context).pop();
          setState(() {
            _selectedRoadmap = roadmap;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI roadmap generated! You earned 100 XP! 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate roadmap: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}