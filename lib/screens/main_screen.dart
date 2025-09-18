import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'skills_screen.dart';
import 'github_auth_screen.dart';
import 'repos_screen.dart';
import 'settings_screen.dart';
import 'insights_screen.dart';
import 'roadmap_screen.dart';
import 'gamification_screen.dart';
import 'career_goals_screen.dart';
import 'enhanced_career_goals_screen.dart';
import 'advanced_analytics_screen.dart';
import 'social_sharing_screen.dart';
import 'ai_assistant_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SkillsScreen(),
    const ReposScreen(),
    const InsightsScreen(),
    const AdvancedAnalyticsScreen(),
    const SocialSharingScreen(),
    const AIAssistantScreen(),
    const RoadmapScreen(),
    const GamificationScreen(),
    const EnhancedCareerGoalsScreen(),
    const GitHubAuthScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground.withOpacity(0.8),
              AppColors.darkBackground,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.list_alt,
                    label: 'Skills',
                  ),
                  _buildNavItem(index: 2, icon: Icons.folder, label: 'Repos'),
                  _buildNavItem(
                    index: 3,
                    icon: Icons.analytics,
                    label: 'Insights',
                  ),
                  _buildNavItem(
                    index: 4,
                    icon: Icons.bar_chart,
                    label: 'Analytics',
                  ),
                  _buildNavItem(index: 5, icon: Icons.share, label: 'Social'),
                  _buildNavItem(
                    index: 6,
                    icon: Icons.auto_awesome,
                    label: 'AI Assistant',
                  ),
                  _buildNavItem(index: 7, icon: Icons.route, label: 'Roadmap'),
                  _buildNavItem(
                    index: 8,
                    icon: Icons.emoji_events,
                    label: 'Gamify',
                  ),
                  _buildNavItem(index: 9, icon: Icons.work, label: 'Goals'),
                  _buildNavItem(index: 10, icon: Icons.code, label: 'GitHub'),
                  _buildNavItem(
                    index: 11,
                    icon: Icons.settings,
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border:
              isSelected
                  ? Border.all(color: AppColors.primary.withOpacity(0.5))
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
