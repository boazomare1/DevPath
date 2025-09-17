import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/github_repository.dart';
import '../models/repo_status.dart';
import 'repo_status_service.dart';

class ReminderService {
  static const String _reminderFrequencyKey = 'reminder_frequency_days';
  static const String _lastReminderCheckKey = 'last_reminder_check';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  
  static const int _defaultReminderDays = 14;
  static const int _notificationId = 1001;
  
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static Timer? _reminderTimer;
  static bool _isInitialized = false;

  /// Initialize the reminder service
  static Future<void> init() async {
    if (_isInitialized) return;
    
    // Initialize local notifications
    await _initializeNotifications();
    
    // Request notification permissions
    await _requestNotificationPermissions();
    
    // Start the reminder timer
    _startReminderTimer();
    
    _isInitialized = true;
  }

  /// Initialize local notifications
  static Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Request notification permissions
  static Future<bool> _requestNotificationPermissions() async {
    if (kIsWeb) return true; // Web doesn't need permission requests
    
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    
    return true;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to repos screen or specific repository
  }

  /// Start the reminder timer
  static void _startReminderTimer() {
    _reminderTimer?.cancel();
    
    // Check every hour
    _reminderTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _checkAndSendReminders(),
    );
  }

  /// Check for repositories that need reminders
  static Future<void> _checkAndSendReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      
      if (!notificationsEnabled) return;
      
      final reminderDays = prefs.getInt(_reminderFrequencyKey) ?? _defaultReminderDays;
      final lastCheck = prefs.getInt(_lastReminderCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Only check once per day
      if (now - lastCheck < 24 * 60 * 60 * 1000) return;
      
      await prefs.setInt(_lastReminderCheckKey, now);
      
      final inactiveRepos = await _getInactiveInProgressRepos(reminderDays);
      
      if (inactiveRepos.isNotEmpty) {
        await _sendReminderNotification(inactiveRepos);
      }
    } catch (e) {
      debugPrint('Error checking reminders: $e');
    }
  }

  /// Get repositories that are "In Progress" but haven't been updated
  static Future<List<GitHubRepository>> _getInactiveInProgressRepos(int reminderDays) async {
    final allStatuses = RepoStatusService.getAllRepoStatuses();
    final inactiveRepos = <GitHubRepository>[];
    
    for (final status in allStatuses) {
      if (status.status == ProjectStatus.inProgress && status.isStale) {
        final daysSinceLastCommit = status.lastCommitDate != null
            ? DateTime.now().difference(status.lastCommitDate!).inDays
            : 999;
            
        if (daysSinceLastCommit >= reminderDays) {
          // We need to get the repository data, but we only have the ID
          // For now, we'll create a placeholder or fetch from GitHub
          // In a real implementation, you'd store repository data or fetch it
          inactiveRepos.add(_createPlaceholderRepo(status.repoId));
        }
      }
    }
    
    return inactiveRepos;
  }

  /// Create a placeholder repository for notification purposes
  static GitHubRepository _createPlaceholderRepo(int repoId) {
    return GitHubRepository(
      id: repoId,
      name: 'Repository #$repoId',
      fullName: 'user/repo#$repoId',
      htmlUrl: 'https://github.com/user/repo#$repoId',
      description: 'Repository requiring attention',
      language: 'Unknown',
      stars: 0,
      forks: 0,
      cloneUrl: 'https://github.com/user/repo#$repoId.git',
      isPrivate: false,
      isFork: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      pushedAt: DateTime.now().subtract(const Duration(days: 15)),
      openIssuesCount: 0,
      defaultBranch: 'main',
      size: 0,
      topics: null,
      hasIssues: false,
      hasProjects: false,
      hasWiki: false,
      hasPages: false,
      archived: false,
      disabled: false,
    );
  }

  /// Send reminder notification
  static Future<void> _sendReminderNotification(List<GitHubRepository> inactiveRepos) async {
    if (inactiveRepos.isEmpty) return;
    
    final title = 'DevPath Reminder';
    final body = inactiveRepos.length == 1
        ? '${inactiveRepos.first.name} hasn\'t been updated in a while'
        : '${inactiveRepos.length} repositories need attention';
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'devpath_reminders',
      'DevPath Reminders',
      channelDescription: 'Notifications for inactive repositories',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      _notificationId,
      title,
      body,
      notificationDetails,
      payload: 'repos_screen',
    );
  }

  /// Set reminder frequency in days
  static Future<void> setReminderFrequency(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderFrequencyKey, days);
  }

  /// Get current reminder frequency
  static Future<int> getReminderFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reminderFrequencyKey) ?? _defaultReminderDays;
  }

  /// Enable/disable notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Get available reminder frequencies
  static List<ReminderFrequency> getAvailableFrequencies() {
    return [
      ReminderFrequency(days: 7, label: '7 days'),
      ReminderFrequency(days: 14, label: '14 days'),
      ReminderFrequency(days: 30, label: '30 days'),
    ];
  }

  /// Check for inactive repositories and return them
  static Future<List<InactiveRepoInfo>> checkInactiveRepositories() async {
    final reminderDays = await getReminderFrequency();
    final allStatuses = RepoStatusService.getAllRepoStatuses();
    final inactiveRepos = <InactiveRepoInfo>[];
    
    for (final status in allStatuses) {
      if (status.status == ProjectStatus.inProgress && status.lastCommitDate != null) {
        final daysSinceLastCommit = DateTime.now().difference(status.lastCommitDate!).inDays;
        
        if (daysSinceLastCommit >= reminderDays) {
          inactiveRepos.add(InactiveRepoInfo(
            repoId: status.repoId,
            daysInactive: daysSinceLastCommit,
            lastCommitDate: status.lastCommitDate!,
          ));
        }
      }
    }
    
    return inactiveRepos;
  }

  /// Dispose resources
  static void dispose() {
    _reminderTimer?.cancel();
    _isInitialized = false;
  }
}

/// Reminder frequency option
class ReminderFrequency {
  final int days;
  final String label;

  ReminderFrequency({
    required this.days,
    required this.label,
  });
}

/// Information about an inactive repository
class InactiveRepoInfo {
  final int repoId;
  final int daysInactive;
  final DateTime lastCommitDate;

  InactiveRepoInfo({
    required this.repoId,
    required this.daysInactive,
    required this.lastCommitDate,
  });
}