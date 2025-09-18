import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/social_sharing_service.dart';
import '../services/analytics_service.dart';
import '../services/enhanced_career_goals_service.dart';
import '../services/gamification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/progress_share_widget.dart';
import '../widgets/mentor_invitation_dialog.dart';
import '../widgets/community_leaderboard.dart';

class SocialSharingScreen extends StatefulWidget {
  const SocialSharingScreen({super.key});

  @override
  State<SocialSharingScreen> createState() => _SocialSharingScreenState();
}

class _SocialSharingScreenState extends State<SocialSharingScreen>
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
                    Tab(text: 'Share Progress'),
                    Tab(text: 'Mentors'),
                    Tab(text: 'Community'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildShareProgressTab(context),
                    _buildMentorsTab(context),
                    _buildCommunityTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Social & Sharing',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share your progress with mentors and peers',
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.share, size: 32, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildShareProgressTab(BuildContext context) {
    return Consumer4<
      SocialSharingService,
      AnalyticsService,
      EnhancedCareerGoalsService,
      GamificationService
    >(
      builder: (
        context,
        socialService,
        analyticsService,
        careerGoalsService,
        gamificationService,
        child,
      ) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Quick share options
              _buildQuickShareOptions(
                context,
                socialService,
                analyticsService,
                careerGoalsService,
                gamificationService,
              ),

              const SizedBox(height: 24),

              // Progress preview
              ProgressShareWidget(
                analyticsService: analyticsService,
                careerGoalsService: careerGoalsService,
                gamificationService: gamificationService,
              ),

              const SizedBox(height: 24),

              // Share history
              _buildShareHistory(context, socialService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMentorsTab(BuildContext context) {
    return Consumer<SocialSharingService>(
      builder: (context, socialService, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Invite mentor button
              _buildInviteMentorButton(context, socialService),

              const SizedBox(height: 24),

              // Mentor invitations list
              _buildMentorInvitationsList(context, socialService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommunityTab(BuildContext context) {
    return Consumer<SocialSharingService>(
      builder: (context, socialService, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Community leaderboard
              CommunityLeaderboard(
                users: socialService.getCommunityLeaderboard(),
              ),

              const SizedBox(height: 24),

              // Join community section
              _buildJoinCommunitySection(context, socialService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickShareOptions(
    BuildContext context,
    SocialSharingService socialService,
    AnalyticsService analyticsService,
    EnhancedCareerGoalsService careerGoalsService,
    GamificationService gamificationService,
  ) {
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
            'Quick Share Options',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildShareOption(
                  context,
                  'PDF Report',
                  Icons.picture_as_pdf,
                  AppColors.error,
                  () => _shareAsPDF(
                    context,
                    socialService,
                    analyticsService,
                    careerGoalsService,
                    gamificationService,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShareOption(
                  context,
                  'PNG Image',
                  Icons.image,
                  AppColors.primary,
                  () => _shareAsPNG(context, socialService),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildShareOption(
                  context,
                  'Share Link',
                  Icons.link,
                  AppColors.success,
                  () => _createShareableLink(
                    context,
                    socialService,
                    analyticsService,
                    careerGoalsService,
                    gamificationService,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShareOption(
                  context,
                  'Invite Mentor',
                  Icons.person_add,
                  AppColors.warning,
                  () => _showMentorInvitationDialog(context, socialService),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareHistory(
    BuildContext context,
    SocialSharingService socialService,
  ) {
    final shareableProgress = socialService.shareableProgress;

    if (shareableProgress.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.share_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No Shared Progress Yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your progress to track your sharing history',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
            'Share History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...shareableProgress
              .take(5)
              .map(
                (progress) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                progress.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    progress.isPublic
                                        ? AppColors.success
                                        : AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                progress.isPublic ? 'Public' : 'Private',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progress.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Created ${_formatDate(progress.createdAt)}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Expires ${_formatDate(progress.expiresAt)}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildInviteMentorButton(
    BuildContext context,
    SocialSharingService socialService,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.person_add, size: 48, color: AppColors.warning),
          const SizedBox(height: 16),
          Text(
            'Invite a Mentor',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your progress with mentors and get valuable feedback',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed:
                () => _showMentorInvitationDialog(context, socialService),
            icon: const Icon(Icons.add),
            label: const Text('Invite Mentor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorInvitationsList(
    BuildContext context,
    SocialSharingService socialService,
  ) {
    final invitations = socialService.mentorInvitations;

    if (invitations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No Mentor Invitations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Invite mentors to view your progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
            'Mentor Invitations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...invitations.map(
            (invitation) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        invitation.isAccepted
                            ? AppColors.success
                            : AppColors.primary,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            invitation.mentorName,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                invitation.isAccepted
                                    ? AppColors.success
                                    : AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            invitation.isAccepted ? 'Accepted' : 'Pending',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      invitation.mentorEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      invitation.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sent ${_formatDate(invitation.sentAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinCommunitySection(
    BuildContext context,
    SocialSharingService socialService,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.groups, size: 48, color: AppColors.secondary),
          const SizedBox(height: 16),
          Text(
            'Join the Community',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect with other learners and see how you compare',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _joinCommunity(context, socialService),
            icon: const Icon(Icons.group_add),
            label: const Text('Join Community'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  Future<void> _shareAsPDF(
    BuildContext context,
    SocialSharingService socialService,
    AnalyticsService analyticsService,
    EnhancedCareerGoalsService careerGoalsService,
    GamificationService gamificationService,
  ) async {
    try {
      final progressData = await socialService.generateProgressData(
        analyticsService: analyticsService,
        careerGoalsService: careerGoalsService,
        gamificationService: gamificationService,
        skills: [], // You would get this from your skills service
      );

      final fileName =
          'DevPath_Progress_${DateTime.now().millisecondsSinceEpoch}';
      final filePath = await socialService.exportProgressAsPDF(
        progressData: progressData,
        fileName: fileName,
      );

      if (filePath != null) {
        await socialService.shareProgress(
          filePath: filePath,
          title: 'My DevPath Progress',
          message: 'Check out my learning progress on DevPath!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _shareAsPNG(
    BuildContext context,
    SocialSharingService socialService,
  ) async {
    try {
      final fileName =
          'DevPath_Progress_${DateTime.now().millisecondsSinceEpoch}';
      final filePath = await socialService.exportProgressAsPNG(
        fileName: fileName,
      );

      if (filePath != null) {
        await socialService.shareProgress(
          filePath: filePath,
          title: 'My DevPath Progress',
          message: 'Check out my learning progress on DevPath!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PNG: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _createShareableLink(
    BuildContext context,
    SocialSharingService socialService,
    AnalyticsService analyticsService,
    EnhancedCareerGoalsService careerGoalsService,
    GamificationService gamificationService,
  ) async {
    try {
      final progressData = await socialService.generateProgressData(
        analyticsService: analyticsService,
        careerGoalsService: careerGoalsService,
        gamificationService: gamificationService,
        skills: [], // You would get this from your skills service
      );

      final shareableLink = await socialService.createShareableProgress(
        title: 'My DevPath Progress',
        description: 'Check out my learning journey and career progress',
        userName: 'Current User', // Replace with actual user name
        isPublic: true,
        sharedWith: [],
        progressData: progressData,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shareable link created: $shareableLink'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating shareable link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showMentorInvitationDialog(
    BuildContext context,
    SocialSharingService socialService,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => MentorInvitationDialog(
            onInvite: (mentorEmail, mentorName, message) async {
              // Create shareable link first
              final shareableLink = await socialService.createShareableProgress(
                title: 'My DevPath Progress',
                description: 'Shared with mentor: $mentorName',
                userName: 'Current User',
                isPublic: false,
                sharedWith: [mentorEmail],
                progressData: {},
              );

              await socialService.inviteMentor(
                mentorEmail: mentorEmail,
                mentorName: mentorName,
                message: message,
                shareableLink: shareableLink,
              );
            },
          ),
    );
  }

  Future<void> _joinCommunity(
    BuildContext context,
    SocialSharingService socialService,
  ) async {
    // In a real app, you would get user data from authentication
    await socialService.addToCommunity(
      name: 'Current User',
      email: 'user@example.com',
      totalXP: 1000,
      level: 5,
      badgesEarned: 3,
      skillsCompleted: 10,
      isPublic: true,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined community successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return '${(difference / 30).floor()} months ago';
  }
}
