import '../models/models.dart';
import 'api_service.dart';

class RulesService {
  // ── Get Rules for Child ───────────────────────────────────────────
  /// GET /api/rules?childId=xxx
  /// Returns: { rules: [...] }
  static Future<List<AppRule>> getRules(String childId) async {
    final response = await ApiService.get(
      '/rules',
      queryParams: {'childId': childId},
    );
    final list = response['rules'] as List<dynamic>? ?? [];
    return list
        .map((e) => AppRule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Get Single Rule ───────────────────────────────────────────────
  /// GET /api/rules/:id
  static Future<AppRule> getRule(String ruleId) async {
    final response = await ApiService.get('/rules/$ruleId');
    return AppRule.fromJson(response['rule'] as Map<String, dynamic>);
  }

  // ── Create Rule ───────────────────────────────────────────────────
  /// POST /api/rules
  /// Body: {
  ///   childId, appName, packageName, isBlocked,
  ///   allowedWindows: [{ day, start: {hour,minute}, end: {hour,minute} }],
  ///   dailyTokenLimit, tokenRatePerHour,
  ///   contentCategories: [...]
  /// }
  static Future<AppRule> createRule({
    required String childId,
    required String appName,
    required String packageName,
    required bool isBlocked,
    List<TimeWindow>? allowedWindows,
    int? dailyTokenLimit,
    int? tokenRatePerHour,
    List<String>? contentCategories,
  }) async {
    final body = <String, dynamic>{
      'childId': childId,
      'appName': appName,
      'packageName': packageName,
      'isBlocked': isBlocked,
      'allowedWindows':
          (allowedWindows ?? []).map((w) => w.toJson()).toList(),
      'contentCategories': contentCategories ?? [],
    };
    if (dailyTokenLimit != null) body['dailyTokenLimit'] = dailyTokenLimit;
    if (tokenRatePerHour != null) body['tokenRatePerHour'] = tokenRatePerHour;

    final response = await ApiService.post('/rules', body);
    return AppRule.fromJson(response['rule'] as Map<String, dynamic>);
  }

  // ── Update Rule ───────────────────────────────────────────────────
  /// PATCH /api/rules/:id
  static Future<AppRule> updateRule(
    String ruleId, {
    bool? isBlocked,
    List<TimeWindow>? allowedWindows,
    int? dailyTokenLimit,
    int? tokenRatePerHour,
    List<String>? contentCategories,
  }) async {
    final body = <String, dynamic>{};
    if (isBlocked != null) body['isBlocked'] = isBlocked;
    if (allowedWindows != null) {
      body['allowedWindows'] = allowedWindows.map((w) => w.toJson()).toList();
    }
    if (dailyTokenLimit != null) body['dailyTokenLimit'] = dailyTokenLimit;
    if (tokenRatePerHour != null) body['tokenRatePerHour'] = tokenRatePerHour;
    if (contentCategories != null) body['contentCategories'] = contentCategories;

    final response = await ApiService.patch('/rules/$ruleId', body);
    return AppRule.fromJson(response['rule'] as Map<String, dynamic>);
  }

  // ── Delete Rule ───────────────────────────────────────────────────
  /// DELETE /api/rules/:id
  static Future<void> deleteRule(String ruleId) async {
    await ApiService.delete('/rules/$ruleId');
  }

  // ── Set Content Filters (ML Categories) ──────────────────────────
  /// PATCH /api/rules/content-filter
  /// Body: { childId, categories: { "Violence & Gore": true, ... } }
  static Future<void> setContentFilters({
    required String childId,
    required Map<String, bool> categories,
  }) async {
    await ApiService.patch('/rules/content-filter', {
      'childId': childId,
      'categories': categories,
    });
  }

  // ── Get Content Filters ───────────────────────────────────────────
  /// GET /api/rules/content-filter?childId=xxx
  static Future<Map<String, bool>> getContentFilters(String childId) async {
    final response = await ApiService.get(
      '/rules/content-filter',
      queryParams: {'childId': childId},
    );
    final raw = response['categories'] as Map<String, dynamic>? ?? {};
    return raw.map((k, v) => MapEntry(k, v as bool));
  }
}
