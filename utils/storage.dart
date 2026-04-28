import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class AppStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Token ─────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Parent Session ────────────────────────────────────────────────
  static Future<void> saveParentData(String jsonString) async {
    await _storage.write(key: AppConstants.parentKey, value: jsonString);
  }

  static Future<String?> getParentData() async {
    return await _storage.read(key: AppConstants.parentKey);
  }

  static Future<void> deleteParentData() async {
    await _storage.delete(key: AppConstants.parentKey);
  }

  // ── Clear All (Logout) ────────────────────────────────────────────
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ── Generic Key-Value ─────────────────────────────────────────────
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
