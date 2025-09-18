import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/simple_storage_service.dart';
import 'services/github_auth_service.dart';
import 'services/auth_code_storage.dart';
import 'services/reminder_service.dart';
import 'services/ai_roadmap_service.dart';
import 'services/ai_assistant_service.dart';
import 'services/gamification_service.dart';
import 'services/career_goals_service.dart';
import 'services/enhanced_career_goals_service.dart';
import 'services/analytics_service.dart';
import 'services/social_sharing_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/minimal_cloud_sync.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/cloud_auth_screen.dart';
import 'screens/github_auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Simple Storage
  await SimpleStorageService.init();

  // Initialize Repo Status Service
  // await RepoStatusService.init();

  // Initialize Reminder Service
  await ReminderService.init();

  // Initialize Enhanced Career Goals Service
  await EnhancedCareerGoalsService().init();

  // Initialize Analytics Service
  await AnalyticsService().init();

  // Initialize Social Sharing Service
  await SocialSharingService().init();

  // Initialize Cloud Sync Service
  await MinimalCloudSync().initialize();

  runApp(const DevPathApp());
}

class DevPathApp extends StatefulWidget {
  const DevPathApp({super.key});

  @override
  State<DevPathApp> createState() => _DevPathAppState();
}

class _DevPathAppState extends State<DevPathApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle app links while the app is already started
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        // Handle exception by warning the user. This is optional.
        debugPrint('Error handling deep link: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');

    if (uri.scheme == 'devpath' &&
        uri.host == 'oauth' &&
        uri.path == '/callback') {
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];

      if (code != null) {
        debugPrint('🚀 Processing auth code immediately: $code');
        // Process the auth code immediately to avoid expiration
        _processAuthCodeImmediately(code);
      }
    }
  }

  /// Process auth code immediately when deep link is received
  Future<void> _processAuthCodeImmediately(String code) async {
    try {
      debugPrint('🔄 Storing auth code: $code');

      // Store the auth code for processing by the GitHub Integration screen
      await AuthCodeStorage.storePendingAuthCode(code, null);
      debugPrint(
        '✅ Auth code stored successfully - go to GitHub Integration to complete authentication',
      );
    } catch (e) {
      debugPrint('❌ Error storing auth code: $e');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

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
        ChangeNotifierProvider<EnhancedCareerGoalsService>(
          create: (_) => EnhancedCareerGoalsService(),
        ),
        ChangeNotifierProvider<AnalyticsService>(
          create: (_) => AnalyticsService(),
        ),
        ChangeNotifierProvider<SocialSharingService>(
          create: (_) => SocialSharingService(),
        ),
        ChangeNotifierProvider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        ChangeNotifierProvider<MinimalCloudSync>(
          create: (_) => MinimalCloudSync(),
        ),
      ],
      child: MaterialApp(
        title: 'DevPath',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Dark mode first (developer preference)
        home: const SplashScreen(),
        routes: {
          '/main': (context) => const MainScreen(),
          '/cloud-auth': (context) => const CloudAuthScreen(),
          '/github-auth': (context) => const GitHubAuthScreen(),
        },
      ),
    );
  }
}
