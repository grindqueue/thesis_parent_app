// ── Parent Model ──────────────────────────────────────────────────
class Parent {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final List<String> childIds;
  final DateTime createdAt;

  Parent({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    required this.childIds,
    required this.createdAt,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        isVerified: json['isVerified'] ?? false,
        childIds: List<String>.from(json['childIds'] ?? []),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'isVerified': isVerified,
        'childIds': childIds,
      };
}

// ── Child Model ───────────────────────────────────────────────────
class Child {
  final String id;
  final String name;
  final int age;
  final String parentId;
  final String deviceId;
  final String nationality;
  final DateTime createdAt;

  Child({
    required this.id,
    required this.name,
    required this.age,
    required this.parentId,
    required this.deviceId,
    required this.nationality,
    required this.createdAt,
  });

  factory Child.fromJson(Map<String, dynamic> json) => Child(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        age: json['age'] ?? 0,
        parentId: json['parentId'] ?? '',
        deviceId: json['deviceId'] ?? '',
        nationality: json['nationality'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'parentId': parentId,
        'deviceId': deviceId,
        'nationality': nationality,
      };
}

// ── App Rule (PBAC + Time-based Schedule) ────────────────────────
class AppRule {
  final String id;
  final String childId;
  final String appName;
  final String packageName;
  final bool isBlocked;
  final List<TimeWindow> allowedWindows;
  final int? dailyTokenLimit; // Token bucket: max tokens per day
  final int? tokenRatePerHour; // Token bucket: refill rate
  final List<String> contentCategories; // ML content categories
  final DateTime createdAt;

  AppRule({
    required this.id,
    required this.childId,
    required this.appName,
    required this.packageName,
    required this.isBlocked,
    required this.allowedWindows,
    this.dailyTokenLimit,
    this.tokenRatePerHour,
    required this.contentCategories,
    required this.createdAt,
  });

  factory AppRule.fromJson(Map<String, dynamic> json) => AppRule(
        id: json['_id'] ?? '',
        childId: json['childId'] ?? '',
        appName: json['appName'] ?? '',
        packageName: json['packageName'] ?? '',
        isBlocked: json['isBlocked'] ?? false,
        allowedWindows: (json['allowedWindows'] as List? ?? [])
            .map((w) => TimeWindow.fromJson(w))
            .toList(),
        dailyTokenLimit: json['dailyTokenLimit'],
        tokenRatePerHour: json['tokenRatePerHour'],
        contentCategories: List<String>.from(json['contentCategories'] ?? []),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class TimeWindow {
  final String day; // 'Monday', 'Tuesday' ... or 'Weekdays', 'Weekends', 'Everyday'
  final TimeOfDayJson start;
  final TimeOfDayJson end;

  TimeWindow({required this.day, required this.start, required this.end});

  factory TimeWindow.fromJson(Map<String, dynamic> json) => TimeWindow(
        day: json['day'] ?? 'Everyday',
        start: TimeOfDayJson.fromJson(json['start'] ?? {}),
        end: TimeOfDayJson.fromJson(json['end'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'start': start.toJson(),
        'end': end.toJson(),
      };
}

class TimeOfDayJson {
  final int hour;
  final int minute;

  TimeOfDayJson({required this.hour, required this.minute});

  factory TimeOfDayJson.fromJson(Map<String, dynamic> json) =>
      TimeOfDayJson(hour: json['hour'] ?? 0, minute: json['minute'] ?? 0);

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};

  String get formatted =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

// ── Activity Log ──────────────────────────────────────────────────
class ActivityLog {
  final String id;
  final String childId;
  final String childName;
  final String appName;
  final String eventType; // 'app_blocked', 'app_accessed', 'content_flagged', 'policy_enforced'
  final String description;
  final String severity; // 'info', 'warning', 'critical'
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.childId,
    required this.childName,
    required this.appName,
    required this.eventType,
    required this.description,
    required this.severity,
    required this.metadata,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        id: json['_id'] ?? '',
        childId: json['childId'] ?? '',
        childName: json['childName'] ?? '',
        appName: json['appName'] ?? '',
        eventType: json['eventType'] ?? '',
        description: json['description'] ?? '',
        severity: json['severity'] ?? 'info',
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      );
}

// ── Device Heartbeat ──────────────────────────────────────────────
class DeviceHeartbeat {
  final String id;
  final String childId;
  final String deviceId;
  final String status; // 'online', 'offline', 'restricted'
  final int batteryLevel;
  final String currentApp;
  final int dailyScreenTime; // seconds
  final int tokensRemaining;
  final DateTime lastSeen;

  DeviceHeartbeat({
    required this.id,
    required this.childId,
    required this.deviceId,
    required this.status,
    required this.batteryLevel,
    required this.currentApp,
    required this.dailyScreenTime,
    required this.tokensRemaining,
    required this.lastSeen,
  });

  factory DeviceHeartbeat.fromJson(Map<String, dynamic> json) => DeviceHeartbeat(
        id: json['_id'] ?? '',
        childId: json['childId'] ?? '',
        deviceId: json['deviceId'] ?? '',
        status: json['status'] ?? 'offline',
        batteryLevel: json['batteryLevel'] ?? 0,
        currentApp: json['currentApp'] ?? '',
        dailyScreenTime: json['dailyScreenTime'] ?? 0,
        tokensRemaining: json['tokensRemaining'] ?? 0,
        lastSeen: DateTime.tryParse(json['lastSeen'] ?? '') ?? DateTime.now(),
      );

  String get lastSeenFormatted {
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get screenTimeFormatted {
    final h = dailyScreenTime ~/ 3600;
    final m = (dailyScreenTime % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}

// ── Installed App (from child's device) ──────────────────────────
class InstalledApp {
  final String packageName;
  final String appName;
  final String iconUrl;
  final String category;

  InstalledApp({
    required this.packageName,
    required this.appName,
    required this.iconUrl,
    required this.category,
  });

  factory InstalledApp.fromJson(Map<String, dynamic> json) => InstalledApp(
        packageName: json['packageName'] ?? '',
        appName: json['appName'] ?? '',
        iconUrl: json['iconUrl'] ?? '',
        category: json['category'] ?? 'Other',
      );
}
