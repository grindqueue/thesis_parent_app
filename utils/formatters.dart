import 'package:flutter/material.dart';

class AppFormatters {
  // ── Screen Time ───────────────────────────────────────────────────
  /// Converts total seconds into "Xh Ym" or "Ym" string
  static String screenTime(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  // ── Last Seen ─────────────────────────────────────────────────────
  /// Returns human-friendly time difference (e.g. "Just now", "3m ago")
  static String lastSeen(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  // ── Date ─────────────────────────────────────────────────────────
  /// Returns "12 Jan 2025"
  static String date(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  /// Returns "12 Jan 2025, 14:30"
  static String dateTime(DateTime dt) {
    return '${date(dt)}, ${timeOfDay(TimeOfDay.fromDateTime(dt))}';
  }

  // ── Time ──────────────────────────────────────────────────────────
  /// Formats TimeOfDay to "14:30"
  static String timeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Formats hour + minute ints to "14:30"
  static String hourMinute(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  // ── Token Bucket ─────────────────────────────────────────────────
  /// Formats token percentage for display (e.g. "42 / 60 tokens")
  static String tokenUsage(int remaining, int limit) {
    return '$remaining / $limit tokens';
  }

  /// Returns percentage 0.0–1.0 of tokens remaining
  static double tokenFraction(int remaining, int limit) {
    if (limit <= 0) return 0.0;
    return (remaining / limit).clamp(0.0, 1.0);
  }

  // ── Battery ───────────────────────────────────────────────────────
  static String battery(int level) => '$level%';

  // ── Event Type Labels ─────────────────────────────────────────────
  static String eventTypeLabel(String eventType) {
    switch (eventType) {
      case 'app_blocked': return 'App Blocked';
      case 'app_accessed': return 'App Accessed';
      case 'content_flagged': return 'Content Flagged';
      case 'policy_enforced': return 'Policy Enforced';
      default: return eventType.replaceAll('_', ' ');
    }
  }

  // ── Confidence Score ──────────────────────────────────────────────
  static String confidence(double score) {
    return '${(score * 100).toStringAsFixed(0)}%';
  }
}
