import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../child/add_child_screen.dart';
import '../child/child_detail_screen.dart';
import '../logs/logs_screen.dart';
import '../heartbeat/heartbeat_screen.dart';
import '../../models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Mock data — replace with API calls
  final List<Child> _children = [
    Child(
      id: '1',
      name: 'Aisha Bello',
      age: 12,
      parentId: 'p1',
      deviceId: 'device-abc-001',
      nationality: 'Nigerian',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Child(
      id: '2',
      name: 'Emeka Bello',
      age: 9,
      parentId: 'p1',
      deviceId: 'device-xyz-002',
      nationality: 'Nigerian',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  final List<DeviceHeartbeat> _heartbeats = [
    DeviceHeartbeat(
      id: 'hb1',
      childId: '1',
      deviceId: 'device-abc-001',
      status: 'online',
      batteryLevel: 78,
      currentApp: 'YouTube',
      dailyScreenTime: 7560,
      tokensRemaining: 42,
      lastSeen: DateTime.now().subtract(const Duration(seconds: 12)),
    ),
    DeviceHeartbeat(
      id: 'hb2',
      childId: '2',
      deviceId: 'device-xyz-002',
      status: 'offline',
      batteryLevel: 23,
      currentApp: '',
      dailyScreenTime: 3600,
      tokensRemaining: 90,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 47)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(children: _children, heartbeats: _heartbeats),
      const LogsScreen(),
      const HeartbeatScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddChildScreen()));
                setState(() {}); // Refresh after adding
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Child',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600)),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: AppColors.cardBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(
              fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle:
              const TextStyle(fontFamily: 'Outfit', fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined),
                activeIcon: Icon(Icons.list_alt_rounded),
                label: 'Activity'),
            BottomNavigationBarItem(
                icon: Icon(Icons.monitor_heart_outlined),
                activeIcon: Icon(Icons.monitor_heart_rounded),
                label: 'Heartbeat'),
          ],
        ),
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final List<Child> children;
  final List<DeviceHeartbeat> heartbeats;

  const _HomeTab({required this.children, required this.heartbeats});

  DeviceHeartbeat? _heartbeatFor(String childId) {
    try {
      return heartbeats.firstWhere((h) => h.childId == childId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = heartbeats.where((h) => h.status == 'online').length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const AppLogo(size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Guardian',
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3)),
                            Text('${children.length} children monitored',
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: AppColors.textSecondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                          child: _SummaryTile(
                        label: 'Online Now',
                        value: '$online',
                        icon: Icons.wifi_rounded,
                        color: AppColors.accent,
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryTile(
                        label: 'Alerts Today',
                        value: '3',
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.warning,
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryTile(
                        label: 'Rules Active',
                        value: '8',
                        icon: Icons.policy_rounded,
                        color: AppColors.accentPurple,
                      )),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const SectionHeader(
                    title: 'Your Children',
                    subtitle: 'Tap a profile to manage rules & settings',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final child = children[i];
                  final hb = _heartbeatFor(child.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ChildCard(child: child, heartbeat: hb),
                  );
                },
                childCount: children.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderColor: color.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final Child child;
  final DeviceHeartbeat? heartbeat;

  const _ChildCard({required this.child, this.heartbeat});

  @override
  Widget build(BuildContext context) {
    final isOnline = heartbeat?.status == 'online';
    final statusColor = isOnline ? AppColors.accent : AppColors.textMuted;

    return GlassCard(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ChildDetailScreen(child: child, heartbeat: heartbeat))),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.accentPurple.withOpacity(0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(child.name,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const Spacer(),
                    StatusBadge(
                      label: isOnline ? 'Online' : 'Offline',
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Age ${child.age} · ${child.nationality}',
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: AppColors.textMuted)),
                if (heartbeat != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MiniStat(
                          icon: Icons.timer_outlined,
                          label: heartbeat!.screenTimeFormatted,
                          color: AppColors.accentOrange),
                      const SizedBox(width: 14),
                      _MiniStat(
                          icon: Icons.token_outlined,
                          label: '${heartbeat!.tokensRemaining} tokens',
                          color: AppColors.primary),
                      const SizedBox(width: 14),
                      _MiniStat(
                          icon: Icons.battery_std_outlined,
                          label: '${heartbeat!.batteryLevel}%',
                          color: heartbeat!.batteryLevel > 20
                              ? AppColors.accent
                              : AppColors.danger),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniStat(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color)),
      ],
    );
  }
}
