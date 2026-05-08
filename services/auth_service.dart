import 'dart:convert';
import '../models/models.dart';
import '../utils/storage.dart';
import 'api_service.dart';

class AuthService {
  // ── Register ──────────────────────────────────────────────────────
  /// POST /auth/parent/signup
  /// Body: { name, email, password, confirmPassword }
  /// Returns: { message } — OTP sent to email
  static Future<String> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await ApiService.post(
      '/auth/parent/signup',
      {'name': name, 'email': email, 'password': password, 'confirmPassword': confirmPassword},
      auth: false,
    );
    return response['message'] ?? 'OTP sent to your email.';
  }

  // ── Login ─────────────────────────────────────────────────────────
  /// POST /auth/parent/signin
  /// Body: { email, password }
  /// Returns: { message } — OTP sent to email for login confirmation
  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/auth/parent/signin',
      {'email': email, 'password': password},
      auth: false,
    );
    return response['message'] ?? 'Verification code sent.';
  }

  // ── Verify OTP (Signup) ───────────────────────────────────────────
  /// POST /auth/parent/verify-otp
  /// Body: { email, otp }
  /// Returns: { token, parent }
  static Future<Parent> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    final response = await ApiService.post(
      '/auth/parent/verify-otp',
      {'email': email, 'otp': otp},
      auth: false,
    );

    final token = response['token'] as String?;
    if (token == null) throw ApiException(message: 'Invalid server response.');

    await AppStorage.saveToken(token);
    final parent = Parent.fromJson(response['parent'] as Map<String, dynamic>);
    await AppStorage.saveParentData(jsonEncode(response['parent']));
    return parent;
  }

  // ── Verify OTP (Login) ────────────────────────────────────────────
  /// POST /auth/parent/verify-otp
  /// Body: { email, otp }
  /// Returns: { token, parent }
  static Future<Parent> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    final response = await ApiService.post(
      '/auth/parent/verify-otp',
      {'email': email, 'otp': otp},
      auth: false,
    );

    final token = response['token'] as String?;
    if (token == null) throw ApiException(message: 'Invalid server response.');

    await AppStorage.saveToken(token);
    final parent = Parent.fromJson(response['parent'] as Map<String, dynamic>);
    await AppStorage.saveParentData(jsonEncode(response['parent']));
    return parent;
  }

  // ── Resend OTP ────────────────────────────────────────────────────
  /// POST /parent/resend-otp
  /// Body: { email }
  static Future<String> resendOtp({required String email}) async {
    final response = await ApiService.post(
      '/parent/resend-otp',
      {'email': email},
      auth: false,
    );
    return response['message'] ?? 'Code resent.';
  }

  // ── Token Verification ─────────────────────────────────────────────
  /// GET /parent/verify-token
  /// Returns: { valid: true }
  static Future<bool> verifyToken() async {
    final response = await ApiService.get('/parent/verify-token');
    return response['valid'] == true;
  }

  // ── Get Stored Parent ─────────────────────────────────────────────
  static Future<Parent?> getStoredParent() async {
    final data = await AppStorage.getParentData();
    if (data == null) return null;
    try {
      return Parent.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (_) {
      // Clear locally even if API fails
    } finally {
      await AppStorage.clearAll();
    }
  }

  // ── Is Logged In ──────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    return await AppStorage.hasToken();
  }
}
