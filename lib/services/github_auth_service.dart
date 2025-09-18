import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../models/github_user.dart';
import '../models/github_repository.dart';
import '../config/github_oauth_config.dart';

class GitHubAuthService extends ChangeNotifier {
  static const String _clientId = GitHubOAuthConfig.clientId;
  static const String _clientSecret = GitHubOAuthConfig.clientSecret;
  static const String _redirectUri = GitHubOAuthConfig.redirectUri;
  static const String _authorizationEndpoint =
      GitHubOAuthConfig.authorizationEndpoint;
  static const String _tokenEndpoint = GitHubOAuthConfig.tokenEndpoint;
  static const String _apiBaseUrl = GitHubOAuthConfig.apiBaseUrl;

  static const String _tokenKey = 'github_access_token';
  static const String _userKey = 'github_user_data';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  String? _accessToken;
  GitHubUser? _currentUser;
  List<GitHubRepository> _repositories = [];

  // Getters
  GitHubUser? get currentUser => _currentUser;
  List<GitHubRepository> get repositories => _repositories;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  // Get access token for API calls
  Future<String?> getAccessToken() async {
    return _accessToken;
  }

  // Stream controllers for reactive updates
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();
  final StreamController<GitHubUser?> _userController =
      StreamController<GitHubUser?>.broadcast();
  final StreamController<List<GitHubRepository>> _reposController =
      StreamController<List<GitHubRepository>>.broadcast();

  Stream<bool> get authStateStream => _authStateController.stream;
  Stream<GitHubUser?> get userStream => _userController.stream;
  Stream<List<GitHubRepository>> get reposStream => _reposController.stream;

  /// Initialize the authentication service
  Future<void> initialize() async {
    try {
      final storedToken = await _secureStorage.read(key: _tokenKey);
      if (storedToken != null) {
        _accessToken = storedToken;
        await _fetchUserData();
        await _fetchRepositories();
        _authStateController.add(true);
      } else {
        _authStateController.add(false);
      }
    } catch (e) {
      debugPrint('Error initializing GitHub auth: $e');
      _authStateController.add(false);
    }
  }

  /// Get a fresh authorization URL (useful for debugging)
  Future<Uri?> getFreshAuthorizationUrl() async {
    try {
      // Create a simple authorization URL without PKCE
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = DateTime.now().microsecondsSinceEpoch;
      final state = 'devpath_${timestamp}_$random';

      final authUrl = Uri.parse(
        '$_authorizationEndpoint?'
        'response_type=code&'
        'client_id=$_clientId&'
        'redirect_uri=${Uri.encodeComponent(_redirectUri)}&'
        'scope=${Uri.encodeComponent('user:email repo read:user')}&'
        'state=$state&'
        '_cb=$timestamp$random',
      );

      debugPrint('Fresh authorization URL: $authUrl');
      return authUrl;
    } catch (e) {
      debugPrint('Error creating fresh authorization URL: $e');
      return null;
    }
  }

  /// Start the OAuth 2.0 authentication flow
  Future<bool> authenticate() async {
    try {
      // Create a simple authorization URL without PKCE
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = DateTime.now().microsecondsSinceEpoch;
      final state = 'devpath_${timestamp}_$random';

      final authUrl = Uri.parse(
        '$_authorizationEndpoint?'
        'response_type=code&'
        'client_id=$_clientId&'
        'redirect_uri=${Uri.encodeComponent(_redirectUri)}&'
        'scope=${Uri.encodeComponent('user:email repo read:user')}&'
        'state=$state&'
        '_cb=$timestamp$random',
      );

      // Launch browser for authentication
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl, mode: LaunchMode.platformDefault);

        // Show instructions to user
        debugPrint(
          'Please complete authentication in the browser and return to the app',
        );
        debugPrint('Authorization URL: $authUrl');
        return true; // Return true to indicate the browser was launched
      }

      return false;
    } catch (e) {
      debugPrint('Error during authentication: $e');
      return false;
    }
  }

  /// Handle the OAuth callback with authorization code
  Future<bool> handleCallback(String authorizationCode) async {
    try {
      // Use custom token exchange
      final token = await _exchangeCodeForToken(authorizationCode);

      if (token != null) {
        _accessToken = token;

        // Store token securely
        await _secureStorage.write(key: _tokenKey, value: token);

        // Fetch user data and repositories
        await _fetchUserData();
        await _fetchRepositories();

        _authStateController.add(true);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error handling callback: $e');
      return false;
    }
  }

  /// Authenticate with authorization code (for manual testing)
  Future<bool> authenticateWithCode(String authorizationCode) async {
    try {
      debugPrint(
        'Attempting to authenticate with code: ${authorizationCode.substring(0, 8)}...',
      );
      debugPrint('Client ID: $_clientId');
      debugPrint('Redirect URI: $_redirectUri');

      // Use custom token exchange
      final token = await _exchangeCodeForToken(authorizationCode);

      if (token != null) {
        debugPrint('Successfully obtained access token');

        _accessToken = token;

        // Store token securely
        await _secureStorage.write(key: _tokenKey, value: token);

        // Fetch user data
        await _fetchUserData();
        await _fetchRepositories();

        _authStateController.add(true);
        notifyListeners();
        return true;
      }

      debugPrint('Failed to obtain access token');
      return false;
    } catch (e) {
      debugPrint('Error authenticating with code: $e');
      debugPrint('Error type: ${e.runtimeType}');
      if (e.toString().contains('invalid_grant')) {
        debugPrint(
          'The authorization code may have expired or been used already',
        );
        debugPrint('Try getting a fresh authorization code from the browser');
      }
      return false;
    }
  }

  /// Custom token exchange that handles GitHub's response
  Future<String?> _exchangeCodeForToken(String authorizationCode) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'code': authorizationCode,
          'redirect_uri': _redirectUri,
        },
      );

      debugPrint('Token exchange response status: ${response.statusCode}');
      debugPrint('Token exchange response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;

        // Try to parse as JSON first (GitHub sometimes returns JSON)
        try {
          final jsonResponse = jsonDecode(responseBody);
          final accessToken = jsonResponse['access_token'];

          if (accessToken != null) {
            debugPrint('Access token obtained successfully from JSON');
            return accessToken;
          }
        } catch (e) {
          debugPrint('Not JSON, trying form-encoded parsing...');
        }

        // Fallback to form-encoded response parsing
        final params = Uri.splitQueryString(responseBody);
        final accessToken = params['access_token'];

        if (accessToken != null) {
          debugPrint('Access token obtained successfully from form-encoded');
          return accessToken;
        } else {
          debugPrint('No access token found in response');
          return null;
        }
      } else {
        debugPrint('Token exchange failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error in token exchange: $e');
      return null;
    }
  }

  /// Fetch current user data from GitHub API
  Future<GitHubUser?> _fetchUserData() async {
    if (_accessToken == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/user'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _currentUser = GitHubUser.fromJson(userData);

        // Store user data securely
        await _secureStorage.write(key: _userKey, value: jsonEncode(userData));

        _userController.add(_currentUser);
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }

    return null;
  }

  /// Fetch user repositories from GitHub API
  Future<List<GitHubRepository>> _fetchRepositories() async {
    if (_accessToken == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/user/repos?sort=updated&per_page=100'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> reposData = jsonDecode(response.body);
        _repositories =
            reposData.map((repo) => GitHubRepository.fromJson(repo)).toList();

        _reposController.add(_repositories);
        return _repositories;
      }
    } catch (e) {
      debugPrint('Error fetching repositories: $e');
    }

    return [];
  }

  /// Fetch repositories for a specific user
  Future<List<GitHubRepository>> fetchUserRepositories(String username) async {
    if (_accessToken == null) return [];

    try {
      final response = await http.get(
        Uri.parse(
          '$_apiBaseUrl/users/$username/repos?sort=updated&per_page=100',
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> reposData = jsonDecode(response.body);
        return reposData
            .map((repo) => GitHubRepository.fromJson(repo))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching user repositories: $e');
    }

    return [];
  }

  /// Log out from GitHub
  Future<void> logout() async {
    try {
      // Clear secure storage
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);

      // Clear in-memory data
      _accessToken = null;
      _currentUser = null;
      _repositories.clear();

      // Notify listeners
      _authStateController.add(false);
      _userController.add(null);
      _reposController.add([]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  /// Filter repositories based on search query
  List<GitHubRepository> filterRepositories(String searchQuery) {
    if (searchQuery.isEmpty) {
      return _repositories;
    }

    final lowercaseQuery = searchQuery.toLowerCase();
    return _repositories.where((repo) {
      return repo.name.toLowerCase().contains(lowercaseQuery) ||
          repo.description.toLowerCase().contains(lowercaseQuery) ||
          repo.language.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Dispose resources
  @override
  void dispose() {
    _authStateController.close();
    _userController.close();
    _reposController.close();
    super.dispose();
  }
}
