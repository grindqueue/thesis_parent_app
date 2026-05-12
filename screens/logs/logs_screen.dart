import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/models.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All', 'Critical', 'Warning', 'Info', 'Blocked', 'Content',
  ];

  // Mock data
  final List<ActivityLog> _logs = [
    ActivityLog(
      id: '1', childId: '1', childName: 'Aisha', appName: 'TikTok',
      eventType: 'app_blocked', description: 'TikTok access denied outside allowed hours (Schedule: 15:00–20:00)',
      severity: 'warning', metadata: {}, timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ActivityLog(
      id: '2', childId: '1', childName: 'Aisha', appName: 'YouTube',
      eventType: 'content_flagged', description: 'ML engine flagged video: potential violence content detected (confidence: 94%)',
      severity: 'critical', metadata: {'confidence': 0.94, 'category': 'Violence'}, timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    ActivityLog(
      id: '3', childId: '2', childName: 'Emeka', appName: 'Roblox',
      eventType: 'app_accessed', description: 'Roblox session started within allowed schedule',
      severity: 'info', metadata: {}, timestamp: DateTime.now().subtract(const Duration(minutes: 34)),
    ),
    ActivityLog(
      id: '4', childId: '1', childName: 'Aisha', appName: 'Instagram',
      eventType: 'policy_enforced', description: 'Token bucket depleted — Instagram access suspended until token refill',
      severity: 'warning', metadata: {'tokensUsed': 60, 'tokensLimit': 60}, timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ActivityLog(
      id: '5', childId: '2', childName: 'Emeka', appName: 'Snapchat',
      eventType: 'app_blocked', description: 'Snapchat is blocked by parent policy',
      severity: 'info', metadata: {}, timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ActivityLog(
      id: '6', childId: '1', childName: 'Aisha', appName: 'Browser',
      eventType: 'content_flagged', description: 'Adult content detected and blocked on visited URL',
      severity: 'critical', metadata: {'url': '[redacted]', 'category': 'Adult Content'}, timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ActivityLog(
      id: '7', childId: '1', childName: 'Aisha', appName: 'WhatsApp',
      eventType: 'app_accessed', description: 'WhatsApp session within permitted hours',
      severity: 'info', metadata: {}, timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  List<ActivityLog> get _filtered {
    if (_selectedFilter == 'All') return _logs;
    if (_selectedFilter == 'Critical') {
      return _logs.where((l) => l.severity == 'critical').toList();
    }
    if (_selectedFilter == 'Warning') {
      return _logs.where((l) => l.severity == 'warning').toList();
    }
    if (_selectedFilter == 'Info') {
      return _logs.where((l) => l.severity == 'info').toList();
    }
    if (_selectedFilter == 'Blocked') {
      return _logs.where((l) => l.eventType == 'app_blocked').toList();
    }
    if (_selectedFilter == 'Content') {
      return _logs.where((l) => l.eventType == 'content_flagged').toList();
    }
    return _logs;
  }

  @override
  Widget build(BuildContext context) {
    final criticalCount = _logs.where((l) => l.severity == 'critical').length;

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
                            Text('Activity Logs',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            Text('${_logs.length} events recorded today',
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      if (criticalCount > 0)
                        StatusBadge(
                          label: '$criticalCount Critical',
                          color: AppColors.danger,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final f = _filters[i];
                        final selected = _selectedFilter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.inputFill,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: _filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          children: const [
                            Icon(Icons.inbox_outlined,
                                size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text('No logs for this filter',
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 16,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LogTile(log: _filtered[i]),
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final ActivityLog log;

  const _LogTile({required this.log});

  Color get _severityColor {
    switch (log.severity) {
      case 'critical': return AppColors.danger;
      case 'warning': return AppColors.warning;
      default: return AppColors.accent;
    }
  }

  IconData get _eventIcon {
    switch (log.eventType) {
      case 'app_blocked': return Icons.block_rounded;
      case 'content_flagged': return Icons.flag_rounded;
      case 'policy_enforced': return Icons.gavel_rounded;
      case 'app_accessed': return Icons.open_in_new_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(log.timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: _severityColor.withOpacity(0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _severityColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_eventIcon, color: _severityColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.appName,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      _timeAgo,
                      style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.description,
                  style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(label: log.childName, color: AppColors.primary),
                    const SizedBox(width: 6),
                    StatusBadge(
                      label: log.severity.toUpperCase(),
                      color: _severityColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
