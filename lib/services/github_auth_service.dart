import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
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

  oauth2.Client? _client;
  oauth2.AuthorizationCodeGrant? _currentGrant;
  String? _codeVerifier;
  GitHubUser? _currentUser;
  List<GitHubRepository> _repositories = [];

  // Getters
  oauth2.Client? get client => _client;
  GitHubUser? get currentUser => _currentUser;
  List<GitHubRepository> get repositories => _repositories;
  bool get isAuthenticated => _client != null && _currentUser != null;
  bool get hasActiveGrant => _currentGrant != null;

  // Get access token for API calls
  Future<String?> getAccessToken() async {
    return _client?.credentials.accessToken;
  }

  /// Generate a PKCE code verifier
  String _generateCodeVerifier() {
    const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(128, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Generate a PKCE code challenge from code verifier
  String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Get a fresh authorization URL (useful for debugging)
  Future<Uri?> getFreshAuthorizationUrl() async {
    try {
      // Clear any existing grant first
      _currentGrant = null;
      
      // Generate PKCE parameters
      _codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(_codeVerifier!);
      
      debugPrint('Generated code verifier: ${_codeVerifier!.substring(0, 8)}...');
      debugPrint('Generated code challenge: ${codeChallenge.substring(0, 8)}...');
      
      // Create new OAuth client and store it
      _currentGrant = oauth2.AuthorizationCodeGrant(
        _clientId,
        Uri.parse(_authorizationEndpoint),
        Uri.parse(_tokenEndpoint),
        secret: _clientSecret,
      );

      final authUrl = _currentGrant!.getAuthorizationUrl(
        Uri.parse(_redirectUri),
        scopes: ['user:email', 'repo', 'read:user'],
      );

      debugPrint('Fresh authorization URL: $authUrl');
      return authUrl;
    } catch (e) {
      debugPrint('Error creating fresh authorization URL: $e');
      return null;
    }
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

  /// Initialize the service and check for existing authentication
  Future<void> initialize() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        _client = oauth2.Client(
          oauth2.Credentials(token),
          identifier: _clientId,
          secret: _clientSecret,
        );

        // Load user data from secure storage
        final userData = await _secureStorage.read(key: _userKey);
        if (userData != null) {
          _currentUser = GitHubUser.fromJson(jsonDecode(userData));
          _userController.add(_currentUser);
        }

        _authStateController.add(true);

        // Fetch fresh user data and repositories
        await _fetchUserData();
        await _fetchRepositories();
      } else {
        _authStateController.add(false);
      }
    } catch (e) {
      debugPrint('Error initializing GitHub auth: $e');
      _authStateController.add(false);
    }
  }

  /// Start the OAuth 2.0 authentication flow
  Future<bool> authenticate() async {
    try {
      // Clear any existing grant first
      _currentGrant = null;
      
      // Generate PKCE parameters
      _codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(_codeVerifier!);
      
      debugPrint('Generated code verifier: ${_codeVerifier!.substring(0, 8)}...');
      debugPrint('Generated code challenge: ${codeChallenge.substring(0, 8)}...');
      
      // Create new OAuth client and store it
      _currentGrant = oauth2.AuthorizationCodeGrant(
        _clientId,
        Uri.parse(_authorizationEndpoint),
        Uri.parse(_tokenEndpoint),
        secret: _clientSecret,
      );

      final authUrl = _currentGrant!.getAuthorizationUrl(
        Uri.parse(_redirectUri),
        scopes: ['user:email', 'repo', 'read:user'],
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
      if (_currentGrant == null) {
        debugPrint('No current grant found for callback');
        return false;
      }

      // Exchange authorization code for access token using the stored grant
      _client = await _currentGrant!.handleAuthorizationResponse({
        'code': authorizationCode,
        'redirect_uri': _redirectUri,
      });

      if (_client != null) {
        // Store credentials securely
        await _secureStorage.write(
          key: _tokenKey,
          value: _client!.credentials.toJson(),
        );

        // Fetch user data and repositories
        await _fetchUserData();
        await _fetchRepositories();

        _authStateController.add(true);
        notifyListeners();

        // Clear the grant after successful authentication
        _currentGrant = null;
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error handling OAuth callback: $e');
      return false;
    }
  }

  /// Handle the OAuth callback (simplified for demo)
  Future<bool> _handleCallback(oauth2.AuthorizationCodeGrant grant) async {
    try {
      // In a real app, you'd get the authorization code from the deep link
      // For demo purposes, we'll show instructions to the user
      debugPrint(
        'Please complete authentication in the browser and copy the authorization code',
      );
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

      // Check if we have a current grant, if not create one
      if (_currentGrant == null) {
        debugPrint('No current grant found, creating new one...');
        _currentGrant = oauth2.AuthorizationCodeGrant(
          _clientId,
          Uri.parse(_authorizationEndpoint),
          Uri.parse(_tokenEndpoint),
          secret: _clientSecret,
        );
      }

      debugPrint('Using existing grant for token exchange...');
      
      // Use the stored code verifier for PKCE
      if (_codeVerifier == null) {
        debugPrint('No code verifier found, generating new one...');
        _codeVerifier = _generateCodeVerifier();
      }
      debugPrint('Code verifier: ${_codeVerifier!.substring(0, 8)}...');
      
      // Use custom token exchange that handles GitHub's form-encoded response
      final token = await _exchangeCodeForTokenWithPKCE(authorizationCode, _codeVerifier!);
      
      if (token != null) {
        debugPrint('Successfully obtained access token');
        
        // Create OAuth client with the token
        _client = oauth2.Client(
          oauth2.Credentials(token),
          identifier: _clientId,
          secret: _clientSecret,
        );
        
        // Store credentials securely
        await _secureStorage.write(
          key: _tokenKey,
          value: _client!.credentials.toJson(),
        );

        // Fetch user data
        await _fetchUserData();
        await _fetchRepositories();

        _authStateController.add(true);
        notifyListeners();
        
        // Clear the grant after successful authentication
        _currentGrant = null;
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

  /// Custom token exchange with PKCE support for GitHub
  Future<String?> _exchangeCodeForTokenWithPKCE(String authorizationCode, String codeVerifier) async {
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
          'code_verifier': codeVerifier, // Add PKCE code verifier
        },
      );

      debugPrint('Token exchange response status: ${response.statusCode}');
      debugPrint('Token exchange response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        
        // Parse form-encoded response (GitHub's format)
        final params = Uri.splitQueryString(responseBody);
        final accessToken = params['access_token'];
        
        if (accessToken != null) {
          debugPrint('Access token obtained successfully');
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
    if (_client == null) return null;

    try {
      final response = await _client!.get(Uri.parse('$_apiBaseUrl/user'));

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
    if (_client == null) return [];

    try {
      final response = await _client!.get(
        Uri.parse('$_apiBaseUrl/user/repos?sort=updated&per_page=100'),
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

  /// Fetch public repositories for a specific user
  Future<List<GitHubRepository>> fetchUserRepositories(String username) async {
    if (_client == null) return [];

    try {
      final response = await _client!.get(
        Uri.parse(
          '$_apiBaseUrl/users/$username/repos?sort=updated&per_page=100',
        ),
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

  /// Refresh repositories
  Future<void> refreshRepositories() async {
    await _fetchRepositories();
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    await _fetchUserData();
  }

  /// Logout and clear stored data
  Future<void> logout() async {
    try {
      // Clear secure storage
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);

      // Clear in-memory data
      _client = null;
      _currentGrant = null; // Clear the grant
      _codeVerifier = null; // Clear the code verifier
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

  /// Get repository by name
  GitHubRepository? getRepositoryByName(String name) {
    try {
      return _repositories.firstWhere((repo) => repo.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get repositories by language
  List<GitHubRepository> getRepositoriesByLanguage(String language) {
    return _repositories.where((repo) => repo.language == language).toList();
  }

  /// Get starred repositories
  List<GitHubRepository> getStarredRepositories() {
    return _repositories.where((repo) => repo.stars > 0).toList();
  }

  /// Get private repositories
  List<GitHubRepository> getPrivateRepositories() {
    return _repositories.where((repo) => repo.isPrivate).toList();
  }

  /// Get public repositories
  List<GitHubRepository> getPublicRepositories() {
    return _repositories.where((repo) => !repo.isPrivate).toList();
  }

  /// Search repositories
  List<GitHubRepository> searchRepositories(String query) {
    final lowercaseQuery = query.toLowerCase();
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
