import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../rules/rules_screen.dart';
import '../../models/models.dart';

class ChildDetailScreen extends StatelessWidget {
  final Child child;
  final DeviceHeartbeat? heartbeat;

  const ChildDetailScreen({super.key, required this.child, this.heartbeat});

  @override
  Widget build(BuildContext context) {
    final isOnline = heartbeat?.status == 'online';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(child.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Edit child
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
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
                          child.name[0].toUpperCase(),
                          style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(child.name,
                              style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('Age ${child.age} · ${child.nationality}',
                              style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          StatusBadge(
                            label: isOnline ? 'Online' : 'Offline',
                            color: isOnline
                                ? AppColors.accent
                                : AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats row
              if (heartbeat != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Screen Time',
                        value: heartbeat!.screenTimeFormatted,
                        icon: Icons.timer_outlined,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Tokens Left',
                        value: '${heartbeat!.tokensRemaining}',
                        icon: Icons.token_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Battery',
                        value: '${heartbeat!.batteryLevel}%',
                        icon: Icons.battery_charging_full_rounded,
                        color: heartbeat!.batteryLevel > 20
                            ? AppColors.accent
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (heartbeat!.currentApp.isNotEmpty)
                  GlassCard(
                    borderColor: AppColors.accentOrange.withOpacity(0.3),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.open_in_new_rounded,
                              color: AppColors.accentOrange, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Currently Using',
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    color: AppColors.textMuted)),
                            Text(heartbeat!.currentApp,
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              // Device info
              const SectionHeader(title: 'Device Info'),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.phone_android_rounded,
                      label: 'Device ID',
                      value: child.deviceId,
                    ),
                    const Divider(
                        color: AppColors.divider, height: 24, thickness: 1),
                    InfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Last Heartbeat',
                      value: heartbeat?.lastSeenFormatted ?? 'Never',
                      iconColor: isOnline ? AppColors.accent : AppColors.textMuted,
                    ),
                    const Divider(
                        color: AppColors.divider, height: 24, thickness: 1),
                    InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Registered On',
                      value:
                          '${child.createdAt.day}/${child.createdAt.month}/${child.createdAt.year}',
                      iconColor: AppColors.accentPurple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              const SectionHeader(title: 'Controls'),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.policy_rounded,
                label: 'App Rules & Schedules',
                subtitle: 'Manage PBAC policies and time-based access',
                color: AppColors.primary,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RulesScreen(child: child))),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.block_rounded,
                label: 'Emergency Lock',
                subtitle: 'Immediately restrict all app access',
                color: AppColors.danger,
                onTap: () => _showEmergencyLockDialog(context),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.screen_lock_portrait_rounded,
                label: 'Content Filter Settings',
                subtitle: 'ML-powered content category blocking',
                color: AppColors.accentPurple,
                onTap: () {
                  // TODO: Navigate to content filter screen
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyLockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Emergency Lock',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text(
            'This will immediately block all apps on ${child.name}\'s device. Are you sure?',
            style: const TextStyle(
                fontFamily: 'Outfit', color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style:
                    TextStyle(color: AppColors.textSecondary, fontFamily: 'Outfit')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: API call to lock device
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Lock Device',
                style: TextStyle(fontFamily: 'Outfit', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
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
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
