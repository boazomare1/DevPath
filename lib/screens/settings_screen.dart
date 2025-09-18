import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/reminder_service.dart';
import '../services/github_auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/minimal_cloud_sync.dart';
import '../widgets/cloud_sync_status.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedFrequency = 14;
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final frequency = await ReminderService.getReminderFrequency();
    final notificationsEnabled =
        await ReminderService.areNotificationsEnabled();

    setState(() {
      _selectedFrequency = frequency;
      _notificationsEnabled = notificationsEnabled;
      _isLoading = false;
    });
  }

  Future<void> _testNotification() async {
    try {
      await ReminderService.showTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notification: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                title: const Text('Settings'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
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

              // Settings Content
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Reminder Settings Section
                    _buildSettingsSection(
                      context,
                      'Reminder Settings',
                      Icons.notifications,
                      [
                        _buildNotificationToggle(context),
                        const SizedBox(height: 16),
                        _buildFrequencySelector(context),
                        const SizedBox(height: 16),
                        _buildTestNotificationButton(context),
                        const SizedBox(height: 16),
                        _buildReminderInfo(context),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Cloud Sync Section
                    _buildSettingsSection(
                      context,
                      'Cloud Sync',
                      Icons.cloud_sync,
                      [
                        const CloudSyncStatus(),
                        const SizedBox(height: 16),
                        _buildCloudSyncActions(context),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Account Settings Section
                    _buildSettingsSection(
                      context,
                      'Account',
                      Icons.account_circle,
                      [
                        _buildGitHubStatus(context),
                        const SizedBox(height: 16),
                        _buildCloudAuthStatus(context),
                        const SizedBox(height: 16),
                        _buildLogoutButton(context),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // App Info Section
                    _buildSettingsSection(
                      context,
                      'App Information',
                      Icons.info,
                      [_buildAppInfo(context)],
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

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enable Notifications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Receive reminders for inactive repositories',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _notificationsEnabled,
          onChanged: (value) async {
            setState(() {
              _notificationsEnabled = value;
            });
            await ReminderService.setNotificationsEnabled(value);
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildFrequencySelector(BuildContext context) {
    final frequencies = ReminderService.getAvailableFrequencies();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Frequency',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How often to check for inactive repositories',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              frequencies.map((frequency) {
                final isSelected = _selectedFrequency == frequency.days;
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      _selectedFrequency = frequency.days;
                    });
                    await ReminderService.setReminderFrequency(frequency.days);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      frequency.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildReminderInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Repositories marked "In Progress" that haven\'t been updated in $_selectedFrequency days will trigger a notification.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubStatus(BuildContext context) {
    final authService = context.watch<GitHubAuthService>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.code,
            color:
                authService.isAuthenticated
                    ? AppColors.success
                    : AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GitHub Account',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  authService.isAuthenticated
                      ? 'Connected to GitHub'
                      : 'Not connected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (authService.isAuthenticated)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Connected',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final authService = context.watch<GitHubAuthService>();

    if (!authService.isAuthenticated) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await authService.logout();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out successfully')),
            );
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout from GitHub'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _testNotification,
        icon: const Icon(Icons.notifications_active),
        label: const Text('Test Notification'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCloudSyncActions(BuildContext context) {
    return Consumer<MinimalCloudSync>(
      builder: (context, cloudSyncService, child) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: cloudSyncService.isOnline && !cloudSyncService.isSyncing
                    ? () => cloudSyncService.forceSync()
                    : null,
                icon: cloudSyncService.isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  cloudSyncService.isSyncing
                      ? 'Syncing...'
                      : cloudSyncService.isOnline
                          ? 'Sync Now'
                          : 'Offline',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cloudSyncService.isOnline
                      ? AppColors.primary
                      : AppColors.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: cloudSyncService.isOnline
                    ? () => _showSyncOptions(context, cloudSyncService)
                    : null,
                icon: const Icon(Icons.settings),
                label: const Text('Options'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCloudAuthStatus(BuildContext context) {
    return Consumer<FirebaseAuthService>(
      builder: (context, authService, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: authService.isAuthenticated
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: authService.isAuthenticated
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                authService.isAuthenticated ? Icons.cloud_done : Icons.cloud_off,
                color: authService.isAuthenticated ? AppColors.success : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authService.isAuthenticated ? 'Cloud Account Connected' : 'Cloud Account Not Connected',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (authService.userProfile != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        authService.userProfile!.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!authService.isAuthenticated)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/cloud-auth');
                  },
                  child: const Text('Connect'),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSyncOptions(BuildContext context, MinimalCloudSync cloudSyncService) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Upload to Cloud'),
              subtitle: const Text('Upload local changes to cloud'),
              onTap: () {
                Navigator.pop(context);
                cloudSyncService.uploadToCloud();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download from Cloud'),
              subtitle: const Text('Download latest changes from cloud'),
              onTap: () {
                Navigator.pop(context);
                cloudSyncService.downloadFromCloud();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Force Sync'),
              subtitle: const Text('Sync all data both ways'),
              onTap: () {
                Navigator.pop(context);
                cloudSyncService.forceSync();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(context, 'App Version', '1.0.0'),
        _buildInfoRow(context, 'Build', 'Debug'),
        _buildInfoRow(context, 'Platform', _getPlatformName()),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
