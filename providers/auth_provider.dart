import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  Parent? _parent;
  String? _errorMessage;
  bool _isLoading = false;

  // ── Getters ───────────────────────────────────────────────────────
  AuthStatus get status => _status;
  Parent? get parent => _parent;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Initialize (called on splash screen) ─────────────────────────
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final loggedIn = await AuthService.isLoggedIn();
      if (loggedIn) {
        _parent = await AuthService.getStoredParent();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }

  // ── Register ──────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await AuthService.register(name: name, email: email, password: password);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login ─────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await AuthService.login(email: email, password: password);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Verify OTP (Signup) ───────────────────────────────────────────
  Future<bool> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _parent = await AuthService.verifySignupOtp(email: email, otp: otp);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Verify OTP (Login) ────────────────────────────────────────────
  Future<bool> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _parent = await AuthService.verifyLoginOtp(email: email, otp: otp);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────────
  Future<bool> resendOtp({required String email}) async {
    _clearError();
    try {
      await AuthService.resendOtp(email: email);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────
  Future<void> logout() async {
    await AuthService.logout();
    _parent = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
