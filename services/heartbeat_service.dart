import 'dart:async';
import '../models/models.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class HeartbeatService {
  static Timer? _pollTimer;
  static final StreamController<List<DeviceHeartbeat>> _controller =
      StreamController<List<DeviceHeartbeat>>.broadcast();

  /// Stream that emits the latest heartbeats on every poll
  static Stream<List<DeviceHeartbeat>> get stream => _controller.stream;

  // ── Fetch Heartbeats (single call) ────────────────────────────────
  /// GET /api/heartbeat
  /// Query: parentId
  /// Returns: { heartbeats: [...] }
  static Future<List<DeviceHeartbeat>> fetchHeartbeats() async {
    final response = await ApiService.get('/heartbeat');
    final list = response['heartbeats'] as List<dynamic>? ?? [];
    return list
        .map((e) => DeviceHeartbeat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Fetch Single Child Heartbeat ──────────────────────────────────
  /// GET /api/heartbeat/:childId
  static Future<DeviceHeartbeat?> fetchChildHeartbeat(String childId) async {
    try {
      final response = await ApiService.get('/heartbeat/$childId');
      return DeviceHeartbeat.fromJson(
          response['heartbeat'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Start Polling ─────────────────────────────────────────────────
  /// Polls the API every [AppConstants.heartbeatPollInterval] seconds
  /// and emits results into [stream]
  static void startPolling() {
    stopPolling(); // cancel any existing timer

    // Immediate first fetch
    _poll();

    _pollTimer = Timer.periodic(
      Duration(seconds: AppConstants.heartbeatPollInterval),
      (_) => _poll(),
    );
  }

  static Future<void> _poll() async {
    try {
      final heartbeats = await fetchHeartbeats();
      if (!_controller.isClosed) {
        _controller.add(heartbeats);
      }
    } catch (_) {
      // Silently fail on poll error; UI handles stale state
    }
  }

  // ── Stop Polling ──────────────────────────────────────────────────
  static void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Dispose ───────────────────────────────────────────────────────
  static void dispose() {
    stopPolling();
    _controller.close();
  }

  // ── Check if Device is Online ─────────────────────────────────────
  static bool isDeviceOnline(DeviceHeartbeat heartbeat) {
    final diff = DateTime.now().difference(heartbeat.lastSeen);
    return diff.inSeconds < AppConstants.deviceOfflineThreshold;
  }

  // ── Get Ping History for Child ────────────────────────────────────
  /// GET /api/heartbeat/:childId/history?limit=10
  static Future<List<DateTime>> getPingHistory(
    String childId, {
    int limit = 10,
  }) async {
    final response = await ApiService.get(
      '/heartbeat/$childId/history',
      queryParams: {'limit': limit.toString()},
    );
    final list = response['pings'] as List<dynamic>? ?? [];
    return list
        .map((e) => DateTime.tryParse(e.toString()) ?? DateTime.now())
        .toList();
  }
}
