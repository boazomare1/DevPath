import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/github_auth_service.dart';
import 'services/repo_status_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await StorageService.init();
  
  // Initialize Repo Status Service
  await RepoStatusService.init();

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
