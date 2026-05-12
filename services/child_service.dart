import 'dart:io';
import '../models/models.dart';
import 'api_service.dart';

class ChildService {
  // ── Register Child ──────────────────────────────────────────────────────
  /// POST /auth/child/signup
  /// Multipart: field = 'nationalId'
  /// Body: { name, age, parentId, deviceId }
  /// Returns: { child }
  static Future<Child> registerChild({
    required String name,
    required int age,
    required String parentId,
    required String deviceId,
    required File nationalIdFile,
  }) async {
    final response = await ApiService.uploadFile(
      '/auth/child/signup',
      nationalIdFile,
      'nationalId',
      fields: {
        'name': name,
        'age': age.toString(),
        'parentId': parentId,
        'deviceId': deviceId,
      },
    );
    return Child.fromJson(response['child'] as Map<String, dynamic>);
  }

  // ── Get All Children ──────────────────────────────────────────────
  /// GET /api/children
  /// Returns: { children: [...] }
  static Future<List<Child>> getChildren({required String parentId}) async {
    final response = await ApiService.get('/api/v1/children/$parentId');
    final list = response['children'] as List<dynamic>? ?? [];
    return list
        .map((e) => Child.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Get Single Child ──────────────────────────────────────────────
  /// GET /api/v1/child/:childId
  static Future<Child> getChild(String childId) async {
    final response = await ApiService.get('/api/v1/child/$childId');
    return Child.fromJson(response['childDetails'] as Map<String, dynamic>);
  }

  // ── Update Child ──────────────────────────────────────────────────
  /// PATCH /api/children/:id
  /// Body: partial child fields
  static Future<Child> updateChild(
    String childId, {
    String? name,
    int? age,
    String? nationality,
    String? deviceId,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (age != null) body['age'] = age;
    if (nationality != null) body['nationality'] = nationality;
    if (deviceId != null) body['deviceId'] = deviceId;

    final response = await ApiService.patch('/children/$childId', body);
    return Child.fromJson(response['child'] as Map<String, dynamic>);
  }

  // ── Delete Child ──────────────────────────────────────────────────
  /// DELETE /api/children/:id
  static Future<void> deleteChild(String childId) async {
    await ApiService.delete('/children/$childId');
  }

  // ── Get Installed Apps (from child device) ────────────────────────
  /// GET /api/devices/:deviceId/apps
  /// Returns: { apps: [...] }
  static Future<List<InstalledApp>> getInstalledApps(String deviceId) async {
    final response = await ApiService.get('/devices/$deviceId/apps');
    final list = response['apps'] as List<dynamic>? ?? [];
    return list
        .map((e) => InstalledApp.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Emergency Lock Device ─────────────────────────────────────────
  /// POST /api/devices/:deviceId/lock
  /// Body: { locked: true/false }
  static Future<void> setDeviceLock(String deviceId,
      {required bool locked}) async {
    await ApiService.post(
      '/devices/$deviceId/lock',
      {'locked': locked},
    );
  }
}
