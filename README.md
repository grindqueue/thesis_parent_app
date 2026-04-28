# Guardian — Parental Control Companion App

Flutter companion application for the thesis:
**"Design and Implementation of an OS-Integrated Parental Control Overlay Using Policy-Based Access Control and Machine-Learning-Assisted Content Analysis"**

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── theme/
│   └── app_theme.dart                 # Colors, typography, ThemeData
├── models/
│   └── models.dart                    # Parent, Child, AppRule, ActivityLog, DeviceHeartbeat, InstalledApp
├── widgets/
│   └── shared_widgets.dart            # GlassCard, StatusBadge, PrimaryButton, OtpInputRow, AppLogo
└── screens/
    ├── auth/
    │   ├── signin_screen.dart          # Parent login
    │   ├── signup_screen.dart          # Parent registration
    │   └── otp_verification_screen.dart # Email OTP (signup + login)
    ├── dashboard/
    │   └── dashboard_screen.dart       # Home: child list + summary stats
    ├── child/
    │   ├── add_child_screen.dart       # Register child + national ID photo upload
    │   └── child_detail_screen.dart    # Child profile + controls
    ├── rules/
    │   └── rules_screen.dart           # App rules (3 tabs: apps / active rules / ML categories)
    ├── logs/
    │   └── logs_screen.dart            # Activity log with severity filters
    └── heartbeat/
        └── heartbeat_screen.dart       # Device status + ping history + auto-refresh
```

---

## Algorithms Reflected in UI

### 1. Time-Based Schedule Algorithm
- **Screen**: `rules_screen.dart` → Add Rule Sheet → "Time-Based Schedule" section
- **Fields**: Day selector (Everyday / Weekdays / specific days), Start Time, End Time
- **API binding**: `POST /api/rules` with `allowedWindows: [{ day, start: {hour, minute}, end: {hour, minute} }]`

### 2. Token Bucket Algorithm
- **Screen**: `rules_screen.dart` → Add Rule Sheet → "Token Bucket Limit" toggle
- **Fields**: Daily Token Limit (slider: 10–240 min), Refill Rate (slider: 1–60 min/hr)
- **Heartbeat**: `tokensRemaining` field shown on dashboard + heartbeat + child detail cards
- **API binding**: `PATCH /api/rules/:id` with `dailyTokenLimit` and `tokenRatePerHour`

### 3. Policy-Based Access Control (PBAC)
- **Screen**: `rules_screen.dart` → "Active Rules" tab
- **Screen**: `child_detail_screen.dart` → Emergency Lock + Content Filter Settings
- **PBAC fields**: `isBlocked`, `allowedWindows`, `contentCategories`
- **API binding**: `GET /api/rules?childId=xxx` and `POST /api/rules`

### 4. ML-Assisted Content Analysis
- **Screen**: `rules_screen.dart` → "Categories" tab
- **Categories**: Violence, Adult Content, Gambling, Drug & Alcohol, Hate Speech, Weapons, Horror, Explicit Language, Cyberbullying, Extremism
- **Logs**: `content_flagged` events show confidence scores from the ML model
- **API binding**: `PATCH /api/rules/content-filter` with `{ childId, categories: { "Violence": true, ... } }`

---

## API Integration Points

Every `TODO:` comment in the code marks an API call to wire up. Summary:

| Screen | Method | Endpoint |
|--------|--------|----------|
| Sign Up | POST | `/api/auth/register` |
| Sign In | POST | `/api/auth/login` |
| OTP Verify | POST | `/api/auth/verify-otp` |
| Resend OTP | POST | `/api/auth/resend-otp` |
| Add Child | POST | `/api/children` |
| Upload NID | POST | `/api/upload/national-id` |
| Get Children | GET | `/api/children?parentId=xxx` |
| Edit Child | PATCH | `/api/children/:id` |
| Get Installed Apps | GET | `/api/devices/:deviceId/apps` |
| Create Rule | POST | `/api/rules` |
| Get Rules | GET | `/api/rules?childId=xxx` |
| Update Rule | PATCH | `/api/rules/:id` |
| Content Filters | PATCH | `/api/rules/content-filter` |
| Activity Logs | GET | `/api/logs?childId=xxx` |
| Heartbeat | GET | `/api/heartbeat?parentId=xxx` |
| Emergency Lock | POST | `/api/devices/:deviceId/lock` |

---

## Dependencies to Install

```bash
flutter pub get
```

Key packages:
- `image_picker` — national ID photo capture/upload
- `google_fonts` — Outfit font family
- `fl_chart` — screen time charts
- `flutter_local_notifications` — heartbeat alerts when device goes offline
- `flutter_secure_storage` — JWT token storage
- `provider` — state management
- `http` / `dio` — REST API calls

---

## Design System

- **Theme**: Deep navy dark mode (`#0A0E1A` background)
- **Font**: Outfit (Google Fonts)
- **Accent colors**: Blue (`#4F8EF7`), Teal (`#00D4AA`), Orange (`#FF7A45`), Purple (`#9B59F5`)
- **Cards**: `GlassCard` widget with subtle border + shadow
- **Status**: `StatusBadge` with glow dot

---

## Notes for Thesis Integration

- The **child app** (installed on the child's device) should POST heartbeats to `/api/heartbeat` every 30 seconds with: `status`, `batteryLevel`, `currentApp`, `dailyScreenTime`, `tokensRemaining`, `deviceId`
- The **OS overlay** enforces rules; the companion app (this Flutter app) only manages policies via the backend
- ML confidence scores (from content analysis) are surfaced in the `ActivityLog.metadata` field and displayed in the logs screen
