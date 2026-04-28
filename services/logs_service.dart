import '../models/models.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class LogsService {
  // ── Get Logs ──────────────────────────────────────────────────────
  /// GET /api/logs
  /// Query: childId?, severity?, eventType?, page?, limit?, dateFrom?, dateTo?
  /// Returns: { logs: [...], total, page, totalPages }
  static Future<LogsResult> getLogs({
    String? childId,
    String? severity,
    String? eventType,
    int page = 1,
    int limit = AppConstants.logsPageSize,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (childId != null) queryParams['childId'] = childId;
    if (severity != null && severity != 'All') {
      queryParams['severity'] = severity.toLowerCase();
    }
    if (eventType != null && eventType != 'All') {
      queryParams['eventType'] = eventType;
    }
    if (dateFrom != null) {
      queryParams['dateFrom'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      queryParams['dateTo'] = dateTo.toIso8601String();
    }

    final response = await ApiService.get('/logs', queryParams: queryParams);

    final list = response['logs'] as List<dynamic>? ?? [];
    return LogsResult(
      logs: list.map((e) => ActivityLog.fromJson(e as Map<String, dynamic>)).toList(),
      total: response['total'] as int? ?? 0,
      page: response['page'] as int? ?? 1,
      totalPages: response['totalPages'] as int? ?? 1,
    );
  }

  // ── Get Logs for Single Child ─────────────────────────────────────
  static Future<LogsResult> getLogsForChild(
    String childId, {
    int page = 1,
  }) async {
    return getLogs(childId: childId, page: page);
  }

  // ── Get Critical Logs ─────────────────────────────────────────────
  static Future<LogsResult> getCriticalLogs({String? childId}) async {
    return getLogs(
      childId: childId,
      severity: AppConstants.severityCritical,
    );
  }

  // ── Get Content Flagged Logs ──────────────────────────────────────
  static Future<LogsResult> getContentFlaggedLogs({String? childId}) async {
    return getLogs(
      childId: childId,
      eventType: AppConstants.eventContentFlagged,
    );
  }

  // ── Get Today's Logs ──────────────────────────────────────────────
  static Future<LogsResult> getTodaysLogs({String? childId}) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getLogs(
      childId: childId,
      dateFrom: startOfDay,
      dateTo: now,
    );
  }
}

// ── Logs Result Model ─────────────────────────────────────────────
class LogsResult {
  final List<ActivityLog> logs;
  final int total;
  final int page;
  final int totalPages;

  LogsResult({
    required this.logs,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;
}
