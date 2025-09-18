# GitHub OAuth Setup Instructions

This guide will help you set up GitHub OAuth authentication for the DevPath app.

## Prerequisites

- A GitHub account
- Flutter development environment set up
- The DevPath app running

## Step 1: Create a GitHub OAuth App

1. **Go to GitHub Developer Settings**
   - Visit: https://github.com/settings/developers
   - Click "New OAuth App"

2. **Fill in the OAuth App Details**
   - **Application name**: `DevPath`
   - **Homepage URL**: 
     - For development: `http://localhost:8080`
     - For production: `https://your-domain.com`
   - **Application description**: `A developer skill tracking app`
   - **Authorization callback URL**: `https://httpbin.org/anything`

3. **Create the OAuth App**
   - Click "Register application"
   - You'll be redirected to the app settings page

## Step 2: Get Your OAuth Credentials

1. **Copy the Client ID**
   - On the OAuth app page, copy the "Client ID"

2. **Generate a Client Secret**
   - Click "Generate a new client secret"
   - Copy the generated secret (you won't be able to see it again)

## Step 3: Configure the App

1. **Update the Configuration File**
   - Open `lib/config/github_oauth_config.dart`
   - Replace `YOUR_GITHUB_CLIENT_ID` with your actual Client ID
   - Replace `YOUR_GITHUB_CLIENT_SECRET` with your actual Client Secret

2. **Update the Auth Service**
   - Open `lib/services/github_auth_service.dart`
   - Replace the placeholder values with your actual credentials

## Step 4: Test the Integration

1. **Run the App**
   ```bash
   flutter run
   ```

2. **Navigate to GitHub Tab**
   - Open the app and go to the "GitHub" tab
   - You should see the GitHub authentication screen

3. **Test Authentication**
   - Click "Connect with GitHub"
   - You'll be redirected to GitHub for authorization
   - After authorization, you'll be redirected back to the app

## Step 5: Deep Link Configuration (Optional)

For a production app, you'll want to set up proper deep linking:

### Android Configuration

1. **Update `android/app/src/main/AndroidManifest.xml`**
   ```xml
   <activity
       android:name=".MainActivity"
       android:exported="true"
       android:launchMode="singleTop"
       android:theme="@style/LaunchTheme">
       <!-- ... existing intent filters ... -->
       <intent-filter android:autoVerify="true">
           <action android:name="android.intent.action.VIEW" />
           <category android:name="android.intent.category.DEFAULT" />
           <category android:name="android.intent.category.BROWSABLE" />
           <data android:scheme="devpath" />
       </intent-filter>
   </activity>
   ```

### iOS Configuration

1. **Update `ios/Runner/Info.plist`**
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>devpath</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>devpath</string>
           </array>
       </dict>
   </array>
   ```

## Features Included

### ✅ Authentication
- OAuth 2.0 flow with GitHub
- Secure token storage using Flutter Secure Storage
- Automatic token refresh
- Logout functionality

### ✅ User Data
- Fetch and display user profile
- Show user statistics (repos, followers, following)
- Display user avatar and bio

### ✅ Repository Management
- Fetch all user repositories (public and private)
- Display repository details (stars, forks, language, etc.)
- Filter repositories by visibility (public/private)
- Search repositories by name, description, or language

### ✅ Security
- Tokens stored securely using Flutter Secure Storage
- Encrypted storage on Android and iOS
- Automatic token cleanup on logout

## Troubleshooting

### Common Issues

1. **"Invalid client" error**
   - Check that your Client ID and Secret are correct
   - Ensure the callback URL matches exactly

2. **"Redirect URI mismatch" error**
   - Verify the callback URL in your GitHub OAuth app settings
   - Make sure it matches `devpath://oauth/callback`

3. **Token storage issues**
   - Check that Flutter Secure Storage is properly configured
   - Ensure the app has proper permissions

4. **Repository fetching fails**
   - Verify that the OAuth app has the correct scopes
   - Check that the user has granted repository access

### Debug Mode

To enable debug logging, add this to your `main.dart`:

```dart
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    // Enable debug logging
    debugPrint('Debug mode enabled');
  }
  
  await StorageService.init();
  runApp(const DevPathApp());
}
```

## Security Notes

- Never commit your Client Secret to version control
- Use environment variables for production
- Regularly rotate your Client Secret
- Monitor your OAuth app usage in GitHub

## Next Steps

After setting up OAuth, you can:

1. **Add more GitHub features**:
   - Fetch commit history
   - Display repository languages
   - Show contribution graphs
   - Track pull requests and issues

2. **Integrate with skill tracking**:
   - Link repositories to specific skills
   - Track project completion
   - Monitor coding activity

3. **Add team features**:
   - Share progress with team members
   - Compare skills across team
   - Set team goals and milestones

## Support

If you encounter any issues:

1. Check the GitHub OAuth documentation
2. Review the Flutter Secure Storage documentation
3. Check the app logs for error messages
4. Verify your OAuth app configuration

Happy coding! 🚀