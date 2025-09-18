import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/minimal_cloud_sync.dart';
import '../theme/app_colors.dart';

class CloudSyncStatus extends StatelessWidget {
  const CloudSyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MinimalCloudSync>(
      builder: (context, cloudSyncService, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cloudSyncService.isOnline 
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cloudSyncService.isOnline 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  cloudSyncService.isOnline 
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                  color: cloudSyncService.isOnline 
                      ? AppColors.success
                      : AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cloudSyncService.isOnline 
                          ? 'Cloud Sync Active'
                          : 'Offline Mode',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (cloudSyncService.lastSyncTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Last sync: ${_formatLastSync(cloudSyncService.lastSyncTime!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Sync indicator
              if (cloudSyncService.isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else if (cloudSyncService.isOnline)
                Icon(
                  Icons.sync,
                  color: AppColors.success,
                  size: 20,
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class CloudSyncButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const CloudSyncButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MinimalCloudSync>(
      builder: (context, cloudSyncService, child) {
        return ElevatedButton.icon(
          onPressed: cloudSyncService.isOnline && !cloudSyncService.isSyncing
              ? onPressed ?? () => cloudSyncService.forceSync()
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }
}

class CloudSyncSettings extends StatelessWidget {
  const CloudSyncSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MinimalCloudSync>(
      builder: (context, cloudSyncService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cloud Sync Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            // Sync status
            CloudSyncStatus(),
            
            const SizedBox(height: 16),
            
            // Sync actions
            Row(
              children: [
                Expanded(
                  child: CloudSyncButton(
                    onPressed: () => cloudSyncService.forceSync(),
                    isLoading: cloudSyncService.isSyncing,
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
            ),
            
            const SizedBox(height: 16),
            
            // Sync info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your data syncs automatically when online. Changes are saved locally when offline.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
}