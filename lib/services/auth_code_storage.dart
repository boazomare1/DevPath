import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCodeStorage {
  static const String _authCodeKey = 'pending_github_auth_code';
  static const String _authStateKey = 'pending_github_auth_state';

  /// Store the pending auth code from deep link
  static Future<void> storePendingAuthCode(String code, String? state) async {
    debugPrint('💾 Storing auth code: $code');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authCodeKey, code);
    if (state != null) {
      await prefs.setString(_authStateKey, state);
    }
    debugPrint('✅ Auth code stored successfully');
  }

  /// Get and clear the pending auth code
  static Future<String?> getAndClearPendingAuthCode() async {
    debugPrint('🔍 Retrieving auth code from storage...');
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_authCodeKey);
    debugPrint('📋 Retrieved code: $code');
    if (code != null) {
      await prefs.remove(_authCodeKey);
      await prefs.remove(_authStateKey);
      debugPrint('🗑️ Auth code cleared from storage');
    }
    return code;
  }

  /// Check if there's a pending auth code
  static Future<bool> hasPendingAuthCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_authCodeKey);
  }
}
