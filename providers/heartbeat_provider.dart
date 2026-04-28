import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/heartbeat_service.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class HeartbeatProvider extends ChangeNotifier {
  List<DeviceHeartbeat> _heartbeats = [];
  Map<String, List<DateTime>> _pingHistories = {};
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<DeviceHeartbeat>>? _subscription;
  final Set<String> _previouslyOnline = {};

  // ── Getters ───────────────────────────────────────────────────────
  List<DeviceHeartbeat> get heartbeats => List.unmodifiable(_heartbeats);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get onlineCount =>
      _heartbeats.where((h) => h.status == 'online').length;

  DeviceHeartbeat? heartbeatFor(String childId) {
    try {
      return _heartbeats.firstWhere((h) => h.childId == childId);
    } catch (_) {
      return null;
    }
  }

  List<DateTime> pingHistoryFor(String deviceId) =>
      _pingHistories[deviceId] ?? [];

  // ── Start Polling ─────────────────────────────────────────────────
  void startPolling() {
    _subscription?.cancel();
    HeartbeatService.startPolling();

    _subscription = HeartbeatService.stream.listen(
      (heartbeats) {
        _checkOfflineTransitions(heartbeats);
        _heartbeats = heartbeats;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        // Keep last known state; don't crash the stream
      },
    );
  }

  // ── Stop Polling ──────────────────────────────────────────────────
  void stopPolling() {
    _subscription?.cancel();
    _subscription = null;
    HeartbeatService.stopPolling();
  }

  // ── Manual Refresh ────────────────────────────────────────────────
  Future<void> refresh() async {
    _setLoading(true);
    _clearError();
    try {
      final heartbeats = await HeartbeatService.fetchHeartbeats();
      _checkOfflineTransitions(heartbeats);
      _heartbeats = heartbeats;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // ── Load Ping History ─────────────────────────────────────────────
  Future<void> loadPingHistory(String childId, String deviceId) async {
    try {
      final history = await HeartbeatService.getPingHistory(childId);
      _pingHistories[deviceId] = history;
      notifyListeners();
    } catch (_) {
      // Non-critical; keep empty list
    }
  }

  // ── Detect Online ↔ Offline Transitions ───────────────────────────
  void _checkOfflineTransitions(List<DeviceHeartbeat> newHeartbeats) {
    for (final hb in newHeartbeats) {
      final isNowOnline = hb.status == 'online';
      final wasOnline = _previouslyOnline.contains(hb.childId);

      if (wasOnline && !isNowOnline) {
        // Device went offline
        final child = _heartbeats
            .where((h) => h.childId == hb.childId)
            .map((h) => h.childId)
            .firstOrNull;
        NotificationService.notifyDeviceOffline(child ?? 'Your child');
        _previouslyOnline.remove(hb.childId);
      } else if (!wasOnline && isNowOnline) {
        // Device came back online
        NotificationService.notifyDeviceOnline(hb.childId);
        _previouslyOnline.add(hb.childId);
      } else if (isNowOnline) {
        _previouslyOnline.add(hb.childId);
      }
    }
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

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
