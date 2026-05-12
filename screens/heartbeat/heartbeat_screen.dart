import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/models.dart';

class HeartbeatScreen extends StatefulWidget {
  const HeartbeatScreen({super.key});

  @override
  State<HeartbeatScreen> createState() => _HeartbeatScreenState();
}

class _HeartbeatScreenState extends State<HeartbeatScreen>
    with TickerProviderStateMixin {
  late Timer _refreshTimer;
  bool _autoRefresh = true;
  int _countdown = 30;
  late AnimationController _pulseController;

  // Mock heartbeats
  List<DeviceHeartbeat> _heartbeats = [
    DeviceHeartbeat(
      id: 'hb1', childId: '1', deviceId: 'device-abc-001',
      status: 'online', batteryLevel: 78, currentApp: 'YouTube',
      dailyScreenTime: 7560, tokensRemaining: 42,
      lastSeen: DateTime.now().subtract(const Duration(seconds: 8)),
    ),
    DeviceHeartbeat(
      id: 'hb2', childId: '2', deviceId: 'device-xyz-002',
      status: 'offline', batteryLevel: 23, currentApp: '',
      dailyScreenTime: 3600, tokensRemaining: 90,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 47)),
    ),
  ];

  final Map<String, String> _childNames = {
    '1': 'Aisha Bello',
    '2': 'Emeka Bello',
  };

  // Heartbeat history (last 10 pings per device)
  final Map<String, List<DateTime>> _pingHistory = {
    'hb1': List.generate(10, (i) =>
        DateTime.now().subtract(Duration(seconds: i * 30))),
    'hb2': List.generate(10, (i) =>
        DateTime.now().subtract(Duration(minutes: 47 + i))),
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_autoRefresh) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _refresh();
            _countdown = 30;
          }
        });
      }
    });
  }

  void _refresh() {
    // TODO: Call GET /api/heartbeat?parentId=xxx
    setState(() {
      _heartbeats = _heartbeats.map((h) {
        if (h.status == 'online') {
          return DeviceHeartbeat(
            id: h.id, childId: h.childId, deviceId: h.deviceId,
            status: h.status, batteryLevel: h.batteryLevel,
            currentApp: h.currentApp, dailyScreenTime: h.dailyScreenTime + 30,
            tokensRemaining: h.tokensRemaining,
            lastSeen: DateTime.now(),
          );
        }
        return h;
      }).toList();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onlineCount = _heartbeats.where((h) => h.status == 'online').length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Device Heartbeat',
                                style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            Text('Real-time device status monitoring',
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      // Auto-refresh toggle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text('Auto',
                                  style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                              const SizedBox(width: 4),
                              Switch.adaptive(
                                value: _autoRefresh,
                                onChanged: (v) =>
                                    setState(() => _autoRefresh = v),
                                activeColor: AppColors.accent,
                                activeTrackColor:
                                    AppColors.accent.withOpacity(0.3),
                                inactiveTrackColor: AppColors.inputFill,
                              ),
                            ],
                          ),
                          if (_autoRefresh)
                            Text('Refresh in ${_countdown}s',
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status overview
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          borderColor: AppColors.accent.withOpacity(0.3),
                          child: Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (_, __) => Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(
                                        0.5 + _pulseController.value * 0.5),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(
                                            _pulseController.value * 0.8),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$onlineCount Online',
                                      style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accent)),
                                  Text('of ${_heartbeats.length} devices',
                                      style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 11,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _refresh,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.refresh_rounded,
                                  color: AppColors.primary, size: 18),
                              SizedBox(width: 6),
                              Text('Refresh',
                                  style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _HeartbeatCard(
                    heartbeat: _heartbeats[i],
                    childName:
                        _childNames[_heartbeats[i].childId] ?? 'Unknown',
                    pingHistory: _pingHistory[_heartbeats[i].id] ?? [],
                    pulseController: _pulseController,
                  ),
                ),
                childCount: _heartbeats.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _HeartbeatCard extends StatelessWidget {
  final DeviceHeartbeat heartbeat;
  final String childName;
  final List<DateTime> pingHistory;
  final AnimationController pulseController;

  const _HeartbeatCard({
    required this.heartbeat,
    required this.childName,
    required this.pingHistory,
    required this.pulseController,
  });

  Color get _statusColor {
    switch (heartbeat.status) {
      case 'online': return AppColors.accent;
      case 'restricted': return AppColors.warning;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = heartbeat.status == 'online';

    return GlassCard(
      borderColor: _statusColor.withOpacity(0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Avatar + pulse
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accentPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        childName[0],
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: AnimatedBuilder(
                        animation: pulseController,
                        builder: (_, __) => Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.card, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(
                                    pulseController.value * 0.9),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(childName,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(heartbeat.deviceId,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              StatusBadge(
                label: heartbeat.status.toUpperCase(),
                color: _statusColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Last seen
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _statusColor.withOpacity(0.15), width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  isOnline
                      ? Icons.monitor_heart_rounded
                      : Icons.heart_broken_outlined,
                  color: _statusColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last Heartbeat',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            color: AppColors.textMuted)),
                    Text(
                      heartbeat.lastSeenFormatted,
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _statusColor),
                    ),
                  ],
                ),
                const Spacer(),
                if (isOnline && heartbeat.currentApp.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Using',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              color: AppColors.textMuted)),
                      Text(
                        heartbeat.currentApp,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stats grid
          Row(
            children: [
              _HeartStat(
                label: 'Screen Time',
                value: heartbeat.screenTimeFormatted,
                icon: Icons.timer_outlined,
                color: AppColors.accentOrange,
              ),
              const SizedBox(width: 10),
              _HeartStat(
                label: 'Tokens Left',
                value: '${heartbeat.tokensRemaining}',
                icon: Icons.token_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _HeartStat(
                label: 'Battery',
                value: '${heartbeat.batteryLevel}%',
                icon: Icons.battery_std_rounded,
                color: heartbeat.batteryLevel > 20
                    ? AppColors.accent
                    : AppColors.danger,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Ping history bar
          Text('Recent Pings (last 10)',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(10, (i) {
              final hasping = i < pingHistory.length;
              final isRecent = hasping &&
                  DateTime.now()
                          .difference(pingHistory[i])
                          .inMinutes <
                      5;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: hasping
                          ? (isRecent
                              ? AppColors.accent
                              : AppColors.accent.withOpacity(0.4))
                          : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HeartStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HeartStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
