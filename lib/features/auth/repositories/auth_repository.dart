// ============================================================
// Auth Repository
// ============================================================
// Handles authentication API calls: login, signup, and Google sign-in.
// ============================================================

import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _api = ApiClient.instance;

  // ---- LOGIN ----
  Future<AuthResult> login(String email, String password) async {
    final response = await _api.post('/api/auth/login', {
      'email': email,
      'password': password,
    }, auth: false);

    final data = response['data'] as Map<String, dynamic>;
    final result = AuthResult.fromJson(data);
    _api.setToken(result.token);
    return result;
  }

  // ---- SIGNUP ----
  Future<AuthResult> signup(Map<String, dynamic> userData) async {
    final response = await _api.post('/api/auth/signup', userData, auth: false);
    final data = response['data'] as Map<String, dynamic>;
    final result = AuthResult.fromJson(data);
    if (result.token.isNotEmpty) {
      _api.setToken(result.token);
    }
    return result;
  }

  // ---- GOOGLE SIGN-IN ----
  // termsVersion / termsLanguage are sent only when Google is used from the
  // signup screen with the Terms & Conditions checkbox ticked (a plain Google
  // login sends no consent).
  Future<AuthResult> googleSignIn(
    String idToken, {
    String role = 'CUSTOMER',
    String? termsVersion,
    String? termsLanguage,
  }) async {
    final response = await _api.post('/api/auth/google', {
      'idToken': idToken,
      'role': role,
      if (termsVersion != null && termsVersion.isNotEmpty) 'termsVersion': termsVersion,
      if (termsLanguage != null && termsLanguage.isNotEmpty) 'termsLanguage': termsLanguage,
    }, auth: false);
    final data = response['data'] as Map<String, dynamic>;
    final result = AuthResult.fromJson(data);
    if (result.token.isNotEmpty) {
      _api.setToken(result.token);
    }
    return result;
  }

  // ---- TERMS & CONDITIONS ----
  /// Records that the signed-in user accepted [version] (the version that was
  /// actually displayed). The backend rejects an outdated version with 409, so
  /// the caller can show the latest terms and ask again.
  Future<void> acceptTerms({required String version, required String language}) async {
    await _api.post('/api/terms/accept', {
      'version': version,
      'language': language,
    });
  }

  // ---- LOGOUT ----
  Future<void> logout() async {
    try {
      await _api.post('/api/auth/logout', {});
    } catch (_) {
      // Ignore logout errors - just clear token
    }
    _api.setToken(null);
  }
}