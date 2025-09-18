import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  FirebaseAuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    if (user != null) {
      _loadUserProfile();
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.message}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Create account with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _setLoading(true);
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(displayName);
      
      // Create user profile
      if (credential.user != null) {
        _userProfile = UserProfile(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Create account error: ${e.message}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _setLoading(true);
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create user profile
      if (userCredential.user != null) {
        _userProfile = UserProfile(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? '',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with GitHub (using custom token)
  Future<UserCredential?> signInWithGitHub({
    required String accessToken,
    required String githubUserData,
  }) async {
    try {
      _setLoading(true);
      
      // Create custom token (this would typically be done on your backend)
      // For now, we'll use the access token directly
      final credential = GithubAuthProvider.credential(accessToken);
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Parse GitHub user data and create profile
      if (userCredential.user != null) {
        _userProfile = UserProfile(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? '',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('GitHub sign in error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _user = null;
      _userProfile = null;
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      _setLoading(true);
      
      if (_user != null) {
        // Update Firebase Auth profile
        await _user!.updateDisplayName(profile.displayName);
        if (profile.photoUrl != null) {
          await _user!.updatePhotoURL(profile.photoUrl);
        }
        
        _userProfile = profile;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    try {
      // This would load from Firestore in a real implementation
      // For now, create a basic profile
      _userProfile = UserProfile(
        id: _user!.uid,
        email: _user!.email ?? '',
        displayName: _user!.displayName ?? '',
        photoUrl: _user!.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Load user profile error: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Reset password error: ${e.message}');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      await _user?.delete();
      _user = null;
      _userProfile = null;
    } catch (e) {
      debugPrint('Delete account error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}