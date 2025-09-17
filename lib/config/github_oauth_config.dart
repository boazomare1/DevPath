class GitHubOAuthConfig {
  // GitHub OAuth App Configuration
  // To set up your GitHub OAuth App:
  // 1. Go to https://github.com/settings/developers
  // 2. Click "New OAuth App"
  // 3. Fill in the details:
  //    - Application name: DevPath
  //    - Homepage URL: https://your-domain.com (or localhost for development)
  //    - Authorization callback URL: devpath://oauth/callback
  // 4. Copy the Client ID and Client Secret herejj

  static const String clientId = 'Ov23liUw25rI3TkTlt69';
  static const String clientSecret = '4a906bc86f6df6868015a902ceca7faf42c01b0d';
  static const String redirectUri = 'devpath://oauth/callback';

  // GitHub API Configuration
  static const String authorizationEndpoint =
      'https://github.com/login/oauth/authorize';
  static const String tokenEndpoint =
      'https://github.com/login/oauth/access_token';
  static const String apiBaseUrl = 'https://api.github.com';

  // OAuth Scopes
  static const List<String> scopes = [
    'user:email', // Read user email
    'read:user', // Read user profile
    'repo', // Read and write access to repositories
  ];

  // Deep Link Configuration
  static const String deepLinkScheme = 'devpath';
  static const String deepLinkHost = 'oauth';
  static const String deepLinkPath = '/callback';

  // Development Configuration
  static const bool isDevelopment = true;
  static const String developmentRedirectUri =
      'http://localhost:8080/oauth/callback';

  // Get the appropriate redirect URI based on environment
  static String get redirectUriForEnvironment {
    if (isDevelopment) {
      return developmentRedirectUri;
    }
    return redirectUri;
  }

  // Validate configuration
  static bool get isConfigured {
    return clientId != 'YOUR_GITHUB_CLIENT_ID' &&
        clientSecret != 'YOUR_GITHUB_CLIENT_SECRET';
  }

  // Get authorization URL
  static String getAuthorizationUrl() {
    final params = {
      'client_id': clientId,
      'redirect_uri': redirectUriForEnvironment,
      'scope': scopes.join(' '),
      'state': _generateState(),
    };

    final queryString = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    return '$authorizationEndpoint?$queryString';
  }

  // Generate a random state parameter for security
  static String _generateState() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000) % 1000000;
    return 'devpath_${timestamp}_$random';
  }
}
