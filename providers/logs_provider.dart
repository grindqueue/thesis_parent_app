import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/logs_service.dart';
import '../services/api_service.dart';

class LogsProvider extends ChangeNotifier {
  List<ActivityLog> _logs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasNextPage = false;
  int _currentPage = 1;
  int _totalLogs = 0;
  String? _errorMessage;

  // Active filters
  String _filterSeverity = 'All';
  String _filterEventType = 'All';
  String? _filterChildId;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;

  // ── Getters ───────────────────────────────────────────────────────
  List<ActivityLog> get logs => List.unmodifiable(_logs);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _hasNextPage;
  int get totalLogs => _totalLogs;
  String? get errorMessage => _errorMessage;
  String get filterSeverity => _filterSeverity;
  String get filterEventType => _filterEventType;

  int get criticalCount =>
      _logs.where((l) => l.severity == 'critical').length;

  // ── Load (first page) ─────────────────────────────────────────────
  Future<void> loadLogs({String? childId}) async {
    _filterChildId = childId;
    _currentPage = 1;
    _setLoading(true);
    _clearError();
    try {
      final result = await LogsService.getLogs(
        childId: childId ?? _filterChildId,
        severity: _filterSeverity == 'All' ? null : _filterSeverity,
        eventType: _filterEventType == 'All' ? null : _filterEventType,
        page: 1,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
      );
      _logs = result.logs;
      _hasNextPage = result.hasNextPage;
      _totalLogs = result.total;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // ── Load More (pagination) ────────────────────────────────────────
  Future<void> loadMore() async {
    if (!_hasNextPage || _isLoadingMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final result = await LogsService.getLogs(
        childId: _filterChildId,
        severity: _filterSeverity == 'All' ? null : _filterSeverity,
        eventType: _filterEventType == 'All' ? null : _filterEventType,
        page: _currentPage + 1,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
      );
      _logs.addAll(result.logs);
      _currentPage++;
      _hasNextPage = result.hasNextPage;
      _totalLogs = result.total;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Apply Severity Filter ─────────────────────────────────────────
  Future<void> setFilterSeverity(String severity) async {
    if (_filterSeverity == severity) return;
    _filterSeverity = severity;
    await loadLogs(childId: _filterChildId);
  }

  // ── Apply Event Type Filter ───────────────────────────────────────
  Future<void> setFilterEventType(String eventType) async {
    if (_filterEventType == eventType) return;
    _filterEventType = eventType;
    await loadLogs(childId: _filterChildId);
  }

  // ── Apply Date Range Filter ───────────────────────────────────────
  Future<void> setDateRange(DateTime? from, DateTime? to) async {
    _filterDateFrom = from;
    _filterDateTo = to;
    await loadLogs(childId: _filterChildId);
  }

  // ── Clear Filters ─────────────────────────────────────────────────
  Future<void> clearFilters() async {
    _filterSeverity = 'All';
    _filterEventType = 'All';
    _filterDateFrom = null;
    _filterDateTo = null;
    await loadLogs(childId: _filterChildId);
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
