import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/github_auth_service.dart';
import 'services/repo_status_service.dart';
import 'services/reminder_service.dart';
import 'services/ai_roadmap_service.dart';
import 'services/ai_assistant_service.dart';
import 'services/gamification_service.dart';
import 'services/career_goals_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await StorageService.init();

  // Initialize Repo Status Service
  await RepoStatusService.init();

  // Initialize Reminder Service
  await ReminderService.init();

  runApp(const DevPathApp());
}

class DevPathApp extends StatelessWidget {
  const DevPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GitHubAuthService>(
          create: (_) => GitHubAuthService(),
        ),
        ChangeNotifierProvider<AIRoadmapService>(
          create: (_) => AIRoadmapService(),
        ),
        ChangeNotifierProvider<AIAssistantService>(
          create: (_) => AIAssistantService(),
        ),
        ChangeNotifierProvider<GamificationService>(
          create: (_) => GamificationService(),
        ),
        ChangeNotifierProvider<CareerGoalsService>(
          create: (_) => CareerGoalsService(),
        ),
      ],
      child: MaterialApp(
        title: 'DevPath',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Dark mode first (developer preference)
        home: const SplashScreen(),
        routes: {'/main': (context) => const MainScreen()},
      ),
    );
  }
}
