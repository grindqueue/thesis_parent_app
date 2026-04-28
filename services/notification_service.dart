import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/models.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ── Notification IDs ──────────────────────────────────────────────
  static const int _deviceOfflineId = 1001;
  static const int _contentFlaggedId = 1002;
  static const int _tokenDepletedId = 1003;

  // ── Initialize ────────────────────────────────────────────────────
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  // ── Request Permissions ───────────────────────────────────────────
  static Future<bool?> requestPermission() async {
    return await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ── Device Offline Alert ──────────────────────────────────────────
  static Future<void> notifyDeviceOffline(String childName) async {
    await _plugin.show(
      _deviceOfflineId,
      '⚠️ Device Offline',
      '$childName\'s device has gone offline.',
      _buildDetails(
        channelId: 'device_status',
        channelName: 'Device Status',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  // ── Device Back Online ────────────────────────────────────────────
  static Future<void> notifyDeviceOnline(String childName) async {
    await _plugin.show(
      _deviceOfflineId,
      '✅ Device Online',
      '$childName\'s device is back online.',
      _buildDetails(
        channelId: 'device_status',
        channelName: 'Device Status',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
  }

  // ── Content Flagged Alert ─────────────────────────────────────────
  static Future<void> notifyContentFlagged({
    required String childName,
    required String appName,
    required String category,
    double? confidence,
  }) async {
    final confidenceStr =
        confidence != null ? ' (${(confidence * 100).toStringAsFixed(0)}%)' : '';
    await _plugin.show(
      _contentFlaggedId,
      '🚨 Content Flagged on $appName',
      '$childName: $category content detected$confidenceStr.',
      _buildDetails(
        channelId: 'content_alerts',
        channelName: 'Content Alerts',
        importance: Importance.max,
        priority: Priority.max,
      ),
    );
  }

  // ── Token Depleted Alert ──────────────────────────────────────────
  static Future<void> notifyTokenDepleted({
    required String childName,
    required String appName,
  }) async {
    await _plugin.show(
      _tokenDepletedId,
      '🪙 Screen Time Limit Reached',
      '$childName\'s $appName access has been paused — daily token limit reached.',
      _buildDetails(
        channelId: 'policy_alerts',
        channelName: 'Policy Alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  // ── Alert from Activity Log ───────────────────────────────────────
  static Future<void> notifyFromLog(ActivityLog log) async {
    if (log.severity == 'critical') {
      if (log.eventType == 'content_flagged') {
        final confidence = log.metadata['confidence'] as double?;
        final category = log.metadata['category'] as String? ?? 'Harmful';
        await notifyContentFlagged(
          childName: log.childName,
          appName: log.appName,
          category: category,
          confidence: confidence,
        );
      } else {
        await _plugin.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          '🚨 Critical Alert — ${log.appName}',
          log.description,
          _buildDetails(
            channelId: 'policy_alerts',
            channelName: 'Policy Alerts',
            importance: Importance.max,
            priority: Priority.max,
          ),
        );
      }
    }
  }

  // ── Cancel All ────────────────────────────────────────────────────
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Builder Helper ────────────────────────────────────────────────
  static NotificationDetails _buildDetails({
    required String channelId,
    required String channelName,
    required Importance importance,
    required Priority priority,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority: priority,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
