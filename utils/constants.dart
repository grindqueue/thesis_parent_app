class AppConstants {
  // ── API ───────────────────────────────────────────────────────────
  static const String baseUrl = 'https://your-api-url.com/api';
  // Change to http://10.0.2.2:5000/api for Android emulator local dev
  // Change to http://localhost:5000/api for iOS simulator local dev

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // ── Auth ──────────────────────────────────────────────────────────
  static const String tokenKey = 'guardian_jwt_token';
  static const String parentKey = 'guardian_parent_data';
  static const int otpLength = 6;
  static const int otpResendCooldown = 60; // seconds

  // ── Heartbeat ─────────────────────────────────────────────────────
  static const int heartbeatPollInterval = 30; // seconds
  static const int deviceOfflineThreshold = 120; // seconds before marked offline

  // ── Token Bucket ─────────────────────────────────────────────────
  static const int defaultDailyTokenLimit = 60; // minutes
  static const int defaultTokenRefillRate = 10; // minutes per hour
  static const int minTokenLimit = 10;
  static const int maxTokenLimit = 240;
  static const int minRefillRate = 1;
  static const int maxRefillRate = 60;

  // ── Logs ──────────────────────────────────────────────────────────
  static const int logsPageSize = 20;

  // ── Upload ────────────────────────────────────────────────────────
  static const int maxImageSizeMb = 5;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];

  // ── Schedule Days ────────────────────────────────────────────────
  static const List<String> scheduleDays = [
    'Everyday',
    'Weekdays',
    'Weekends',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // ── ML Content Categories ─────────────────────────────────────────
  static const List<String> contentCategories = [
    'Violence & Gore',
    'Adult Content',
    'Gambling',
    'Drug & Alcohol',
    'Hate Speech',
    'Weapons',
    'Horror',
    'Explicit Language',
    'Cyberbullying Detection',
    'Extremism',
  ];

  // ── Nationality List ──────────────────────────────────────────────
  static const List<String> nationalities = [
    'Nigerian',
    'Ghanaian',
    'Kenyan',
    'South African',
    'Ugandan',
    'Tanzanian',
    'Rwandan',
    'Ethiopian',
    'American',
    'British',
    'Canadian',
    'Australian',
    'Other',
  ];

  // ── Event Types ───────────────────────────────────────────────────
  static const String eventAppBlocked = 'app_blocked';
  static const String eventAppAccessed = 'app_accessed';
  static const String eventContentFlagged = 'content_flagged';
  static const String eventPolicyEnforced = 'policy_enforced';

  // ── Severity Levels ───────────────────────────────────────────────
  static const String severityInfo = 'info';
  static const String severityWarning = 'warning';
  static const String severityCritical = 'critical';

  // ── Device Status ─────────────────────────────────────────────────
  static const String statusOnline = 'online';
  static const String statusOffline = 'offline';
  static const String statusRestricted = 'restricted';
}
