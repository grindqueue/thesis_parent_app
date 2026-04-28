import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../../models/models.dart';

class RulesScreen extends StatefulWidget {
  final Child child;

  const RulesScreen({super.key, required this.child});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock installed apps (from child device)
  final List<InstalledApp> _installedApps = [
    InstalledApp(packageName: 'com.zhiliaoapp.musically', appName: 'TikTok', iconUrl: '', category: 'Social'),
    InstalledApp(packageName: 'com.google.android.youtube', appName: 'YouTube', iconUrl: '', category: 'Video'),
    InstalledApp(packageName: 'com.instagram.android', appName: 'Instagram', iconUrl: '', category: 'Social'),
    InstalledApp(packageName: 'com.roblox.client', appName: 'Roblox', iconUrl: '', category: 'Gaming'),
    InstalledApp(packageName: 'com.snapchat.android', appName: 'Snapchat', iconUrl: '', category: 'Social'),
    InstalledApp(packageName: 'com.minecraft', appName: 'Minecraft', iconUrl: '', category: 'Gaming'),
    InstalledApp(packageName: 'com.google.android.apps.maps', appName: 'Maps', iconUrl: '', category: 'Utility'),
    InstalledApp(packageName: 'com.whatsapp', appName: 'WhatsApp', iconUrl: '', category: 'Communication'),
  ];

  // Mock rules
  final List<AppRule> _rules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddRuleSheet(InstalledApp app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddRuleSheet(
        app: app,
        onSave: (rule) {
          setState(() => _rules.add(rule));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Rule created for ${app.appName}')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.child.name}\'s Rules'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(
              fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontFamily: 'Outfit', fontSize: 13),
          tabs: const [
            Tab(text: 'Installed Apps'),
            Tab(text: 'Active Rules'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Installed apps
          _InstalledAppsTab(
            apps: _installedApps,
            rules: _rules,
            onAddRule: _showAddRuleSheet,
          ),
          // Tab 2: Active Rules
          _ActiveRulesTab(rules: _rules, apps: _installedApps),
          // Tab 3: ML Content Categories
          _ContentCategoryTab(childId: widget.child.id),
        ],
      ),
    );
  }
}

// ── Tab 1: Installed Apps ─────────────────────────────────────────
class _InstalledAppsTab extends StatelessWidget {
  final List<InstalledApp> apps;
  final List<AppRule> rules;
  final Function(InstalledApp) onAddRule;

  const _InstalledAppsTab(
      {required this.apps, required this.rules, required this.onAddRule});

  AppRule? _ruleFor(String pkg) {
    try {
      return rules.firstWhere((r) => r.packageName == pkg);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<InstalledApp>>{};
    for (final app in apps) {
      grouped.putIfAbsent(app.category, () => []).add(app);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in grouped.keys) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              category.toUpperCase(),
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2),
            ),
          ),
          ...grouped[category]!.map((app) {
            final rule = _ruleFor(app.packageName);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AppRuleTile(
                app: app,
                rule: rule,
                onTap: () => onAddRule(app),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _AppRuleTile extends StatelessWidget {
  final InstalledApp app;
  final AppRule? rule;
  final VoidCallback onTap;

  const _AppRuleTile(
      {required this.app, this.rule, required this.onTap});

  Color get _categoryColor {
    switch (app.category) {
      case 'Social': return AppColors.danger;
      case 'Gaming': return AppColors.accentPurple;
      case 'Video': return AppColors.accentOrange;
      case 'Communication': return AppColors.primary;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _categoryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _categoryColor.withOpacity(0.3), width: 1),
            ),
            child: Center(
              child: Text(
                app.appName.isNotEmpty ? app.appName[0] : '?',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _categoryColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.appName,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(app.category,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          rule != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(
                      label: rule!.isBlocked ? 'Blocked' : 'Scheduled',
                      color: rule!.isBlocked
                          ? AppColors.danger
                          : AppColors.accent,
                    ),
                    const SizedBox(height: 4),
                    const Text('Tap to edit',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            color: AppColors.textMuted)),
                  ],
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 1),
                  ),
                  child: const Text('+ Add Rule',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
        ],
      ),
    );
  }
}

// ── Tab 2: Active Rules ───────────────────────────────────────────
class _ActiveRulesTab extends StatelessWidget {
  final List<AppRule> rules;
  final List<InstalledApp> apps;

  const _ActiveRulesTab({required this.rules, required this.apps});

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.policy_outlined, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text('No rules yet',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('Add rules from the Installed Apps tab.',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rules.length,
      itemBuilder: (_, i) {
        final rule = rules[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(rule.appName,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const Spacer(),
                    StatusBadge(
                      label: rule.isBlocked ? 'Blocked' : 'Scheduled',
                      color: rule.isBlocked
                          ? AppColors.danger
                          : AppColors.accent,
                    ),
                  ],
                ),
                if (!rule.isBlocked && rule.allowedWindows.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...rule.allowedWindows.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              '${w.day}: ${w.start.formatted} – ${w.end.formatted}',
                              style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )),
                ],
                if (rule.dailyTokenLimit != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.token_outlined,
                          size: 14, color: AppColors.accentOrange),
                      const SizedBox(width: 6),
                      Text(
                        'Token limit: ${rule.dailyTokenLimit}/day · Refill: ${rule.tokenRatePerHour}/hr',
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Tab 3: Content Categories (ML) ───────────────────────────────
class _ContentCategoryTab extends StatefulWidget {
  final String childId;
  const _ContentCategoryTab({required this.childId});

  @override
  State<_ContentCategoryTab> createState() => _ContentCategoryTabState();
}

class _ContentCategoryTabState extends State<_ContentCategoryTab> {
  final Map<String, bool> _categories = {
    'Violence & Gore': true,
    'Adult Content': true,
    'Gambling': true,
    'Drug & Alcohol': true,
    'Hate Speech': true,
    'Weapons': false,
    'Horror': false,
    'Explicit Language': false,
    'Cyberbullying Detection': true,
    'Extremism': true,
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          borderColor: AppColors.accentPurple.withOpacity(0.3),
          child: Row(
            children: const [
              Icon(Icons.psychology_rounded,
                  color: AppColors.accentPurple, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ML-powered content analysis runs on device to detect and block harmful content in real-time.',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(
          title: 'Content Filters',
          subtitle: 'Toggle categories to block',
        ),
        const SizedBox(height: 12),
        ..._categories.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    _CategoryIcon(name: entry.key),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary),
                      ),
                    ),
                    Switch.adaptive(
                      value: entry.value,
                      onChanged: (v) {
                        setState(() => _categories[entry.key] = v);
                        // TODO: PATCH /api/rules/content-filter
                      },
                      activeColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withOpacity(0.3),
                      inactiveTrackColor: AppColors.inputFill,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String name;
  const _CategoryIcon({required this.name});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    if (name.contains('Violence')) {
      icon = Icons.warning_rounded; color = AppColors.danger;
    } else if (name.contains('Adult')) {
      icon = Icons.block_rounded; color = AppColors.accentOrange;
    } else if (name.contains('Gambl')) {
      icon = Icons.casino_outlined; color = AppColors.warning;
    } else if (name.contains('Drug')) {
      icon = Icons.medication_outlined; color = AppColors.accentPurple;
    } else if (name.contains('Hate')) {
      icon = Icons.record_voice_over_rounded; color = AppColors.danger;
    } else if (name.contains('Weapon')) {
      icon = Icons.gavel_rounded; color = AppColors.accentOrange;
    } else if (name.contains('Horror')) {
      icon = Icons.sentiment_very_dissatisfied_rounded; color = AppColors.accentPurple;
    } else if (name.contains('Language')) {
      icon = Icons.comment_bank_outlined; color = AppColors.warning;
    } else if (name.contains('Cyber')) {
      icon = Icons.shield_outlined; color = AppColors.primary;
    } else {
      icon = Icons.remove_circle_outline_rounded; color = AppColors.danger;
    }
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

// ── Add Rule Bottom Sheet ────────────────────────────────────────
class _AddRuleSheet extends StatefulWidget {
  final InstalledApp app;
  final Function(AppRule) onSave;

  const _AddRuleSheet({required this.app, required this.onSave});

  @override
  State<_AddRuleSheet> createState() => _AddRuleSheetState();
}

class _AddRuleSheetState extends State<_AddRuleSheet> {
  bool _isBlocked = false;
  String _selectedDay = 'Everyday';
  TimeOfDay _startTime = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);
  int _tokenLimit = 60; // mins expressed as tokens
  int _tokenRate = 10;
  bool _useTokenBucket = false;
  final List<String> _days = [
    'Everyday', 'Weekdays', 'Weekends',
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(widget.app.appName,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Block toggle
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderColor: _isBlocked
                  ? AppColors.danger.withOpacity(0.4)
                  : AppColors.cardBorder,
              child: Row(
                children: [
                  const Icon(Icons.block_rounded,
                      color: AppColors.danger, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Block App Completely',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  Switch.adaptive(
                    value: _isBlocked,
                    onChanged: (v) => setState(() => _isBlocked = v),
                    activeColor: AppColors.danger,
                    activeTrackColor: AppColors.danger.withOpacity(0.3),
                    inactiveTrackColor: AppColors.inputFill,
                  ),
                ],
              ),
            ),
            if (!_isBlocked) ...[
              const SizedBox(height: 20),
              // Time-based schedule
              const Text('Time-Based Schedule',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text(
                'Set when this app is allowed to run (time-based schedule algorithm)',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDay,
                items: _days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDay = v!),
                decoration: const InputDecoration(labelText: 'Applies On'),
                dropdownColor: AppColors.card,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.textPrimary,
                    fontSize: 15),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: 'Allow From',
                      time: _startTime,
                      onChanged: (t) => setState(() => _startTime = t),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePicker(
                      label: 'Allow Until',
                      time: _endTime,
                      onChanged: (t) => setState(() => _endTime = t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Token bucket
              GlassCard(
                borderColor: _useTokenBucket
                    ? AppColors.accentOrange.withOpacity(0.4)
                    : AppColors.cardBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.token_outlined,
                            color: AppColors.accentOrange, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Token Bucket Limit',
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ),
                        Switch.adaptive(
                          value: _useTokenBucket,
                          onChanged: (v) =>
                              setState(() => _useTokenBucket = v),
                          activeColor: AppColors.accentOrange,
                          activeTrackColor:
                              AppColors.accentOrange.withOpacity(0.3),
                          inactiveTrackColor: AppColors.inputFill,
                        ),
                      ],
                    ),
                    if (_useTokenBucket) ...[
                      const SizedBox(height: 14),
                      Text('Daily Token Limit: $_tokenLimit minutes',
                          style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                      Slider(
                        value: _tokenLimit.toDouble(),
                        min: 10,
                        max: 240,
                        divisions: 23,
                        activeColor: AppColors.accentOrange,
                        inactiveColor: AppColors.cardBorder,
                        onChanged: (v) =>
                            setState(() => _tokenLimit = v.round()),
                      ),
                      Text('Refill Rate: $_tokenRate min/hr',
                          style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                      Slider(
                        value: _tokenRate.toDouble(),
                        min: 1,
                        max: 60,
                        activeColor: AppColors.accentOrange,
                        inactiveColor: AppColors.cardBorder,
                        onChanged: (v) =>
                            setState(() => _tokenRate = v.round()),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save Rule',
              onPressed: () {
                // Build AppRule
                final rule = AppRule(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  childId: '',
                  appName: widget.app.appName,
                  packageName: widget.app.packageName,
                  isBlocked: _isBlocked,
                  allowedWindows: _isBlocked
                      ? []
                      : [
                          TimeWindow(
                            day: _selectedDay,
                            start: TimeOfDayJson(
                                hour: _startTime.hour,
                                minute: _startTime.minute),
                            end: TimeOfDayJson(
                                hour: _endTime.hour,
                                minute: _endTime.minute),
                          ),
                        ],
                  dailyTokenLimit:
                      _useTokenBucket ? _tokenLimit : null,
                  tokenRatePerHour:
                      _useTokenBucket ? _tokenRate : null,
                  contentCategories: [],
                  createdAt: DateTime.now(),
                );
                widget.onSave(rule);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final Function(TimeOfDay) onChanged;

  const _TimePicker(
      {required this.label, required this.time, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                surface: AppColors.card,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  time.format(context),
                  style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
