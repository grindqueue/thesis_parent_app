import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/rules_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class RulesProvider extends ChangeNotifier {
  // Rules keyed by childId
  final Map<String, List<AppRule>> _rulesMap = {};
  // Content filters keyed by childId
  final Map<String, Map<String, bool>> _filtersMap = {};

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  List<AppRule> rulesFor(String childId) =>
      List.unmodifiable(_rulesMap[childId] ?? []);

  Map<String, bool> filtersFor(String childId) =>
      Map.unmodifiable(_filtersMap[childId] ?? _defaultFilters());

  AppRule? ruleForApp(String childId, String packageName) {
    try {
      return (_rulesMap[childId] ?? [])
          .firstWhere((r) => r.packageName == packageName);
    } catch (_) {
      return null;
    }
  }

  // ── Load Rules ────────────────────────────────────────────────────
  Future<void> loadRules(String childId) async {
    _setLoading(true);
    _clearError();
    try {
      _rulesMap[childId] = await RulesService.getRules(childId);
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // ── Create Rule ───────────────────────────────────────────────────
  Future<bool> createRule({
    required String childId,
    required String appName,
    required String packageName,
    required bool isBlocked,
    List<TimeWindow>? allowedWindows,
    int? dailyTokenLimit,
    int? tokenRatePerHour,
    List<String>? contentCategories,
  }) async {
    _isSubmitting = true;
    _clearError();
    notifyListeners();
    try {
      final rule = await RulesService.createRule(
        childId: childId,
        appName: appName,
        packageName: packageName,
        isBlocked: isBlocked,
        allowedWindows: allowedWindows,
        dailyTokenLimit: dailyTokenLimit,
        tokenRatePerHour: tokenRatePerHour,
        contentCategories: contentCategories,
      );

      _rulesMap[childId] ??= [];
      _rulesMap[childId]!.add(rule);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Update Rule ───────────────────────────────────────────────────
  Future<bool> updateRule(
    String childId,
    String ruleId, {
    bool? isBlocked,
    List<TimeWindow>? allowedWindows,
    int? dailyTokenLimit,
    int? tokenRatePerHour,
    List<String>? contentCategories,
  }) async {
    _isSubmitting = true;
    _clearError();
    notifyListeners();
    try {
      final updated = await RulesService.updateRule(
        ruleId,
        isBlocked: isBlocked,
        allowedWindows: allowedWindows,
        dailyTokenLimit: dailyTokenLimit,
        tokenRatePerHour: tokenRatePerHour,
        contentCategories: contentCategories,
      );

      final list = _rulesMap[childId] ?? [];
      final idx = list.indexWhere((r) => r.id == ruleId);
      if (idx != -1) list[idx] = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Delete Rule ───────────────────────────────────────────────────
  Future<bool> deleteRule(String childId, String ruleId) async {
    _clearError();
    try {
      await RulesService.deleteRule(ruleId);
      _rulesMap[childId]?.removeWhere((r) => r.id == ruleId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ── Load Content Filters ──────────────────────────────────────────
  Future<void> loadContentFilters(String childId) async {
    try {
      final filters = await RulesService.getContentFilters(childId);
      _filtersMap[childId] = filters.isNotEmpty ? filters : _defaultFilters();
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    }
  }

  // ── Update Content Filter ─────────────────────────────────────────
  Future<bool> toggleContentFilter(
    String childId,
    String category,
    bool value,
  ) async {
    _filtersMap[childId] ??= _defaultFilters();
    _filtersMap[childId]![category] = value;
    notifyListeners(); // optimistic update

    try {
      await RulesService.setContentFilters(
        childId: childId,
        categories: _filtersMap[childId]!,
      );
      return true;
    } on ApiException catch (e) {
      // Revert on failure
      _filtersMap[childId]![category] = !value;
      _setError(e.message);
      notifyListeners();
      return false;
    }
  }

  // ── Default Filters ───────────────────────────────────────────────
  static Map<String, bool> _defaultFilters() {
    return {
      for (final cat in AppConstants.contentCategories) cat: false,
    };
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

  void _clearError() => _errorMessage = null;
}
