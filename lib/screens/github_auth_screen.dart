import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/github_auth_service.dart';
import '../models/github_user.dart';
import '../models/github_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/github_auth_button.dart';
import '../widgets/github_user_card.dart';
import '../widgets/github_repo_list.dart';

class GitHubAuthScreen extends StatefulWidget {
  const GitHubAuthScreen({super.key});

  @override
  State<GitHubAuthScreen> createState() => _GitHubAuthScreenState();
}

class _GitHubAuthScreenState extends State<GitHubAuthScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize the GitHub auth service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GitHubAuthService>().initialize();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleGitHubLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<GitHubAuthService>();
      final success = await authService.authenticate();

      if (!success) {
        setState(() {
          _errorMessage = 'Failed to start authentication. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleManualCodeAuth() async {
    if (_codeController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the authorization code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<GitHubAuthService>();
      final success = await authService.authenticateWithCode(
        _codeController.text.trim(),
      );

      if (success) {
        _codeController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully authenticated with GitHub!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid authorization code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await context.read<GitHubAuthService>().logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged out from GitHub'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'GitHub Integration',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect your GitHub account to sync repositories and track your development progress',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Authentication Status
                StreamBuilder<bool>(
                  stream: context.watch<GitHubAuthService>().authStateStream,
                  builder: (context, snapshot) {
                    final isAuthenticated = snapshot.data ?? false;

                    if (isAuthenticated) {
                      return _buildAuthenticatedView();
                    } else {
                      return _buildUnauthenticatedView();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView() {
    return Expanded(
      child: Column(
        children: [
          // User Info
          StreamBuilder<GitHubUser?>(
            stream: context.watch<GitHubAuthService>().userStream,
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user != null) {
                return GitHubUserCard(user: user);
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 24),

          // Repositories
          Expanded(
            child: StreamBuilder<List<GitHubRepository>>(
              stream: context.watch<GitHubAuthService>().reposStream,
              builder: (context, snapshot) {
                final repos = snapshot.data ?? [];
                if (repos.isNotEmpty) {
                  return GitHubRepoList(repositories: repos);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout from GitHub'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // GitHub Logo/Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.code, size: 60, color: Colors.black),
          ),

          const SizedBox(height: 32),

          // Login Button
          GitHubAuthButton(
            onPressed: _isLoading ? null : _handleGitHubLogin,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 24),

          // Manual Code Input (for testing)
          Container(
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
                  'Manual Authentication (for testing)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'If you have an authorization code, enter it below:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Authorization Code',
                    hintText: 'Enter the code from GitHub',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleManualCodeAuth,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Authenticate with Code'),
                  ),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }
}
