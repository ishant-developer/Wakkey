import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../theme/app_theme.dart';
import 'alarm_edit_screen.dart';
import 'alarm_ringing_screen.dart';
import 'wake_up_check_screen.dart';
import 'missions_catalog_screen.dart';
import 'sleep_dashboard_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'missions/math_mission_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  StreamSubscription<AlarmModel>? _alarmSub;
  StreamSubscription<AlarmModel>? _wakeCheckSub;

  @override
  void initState() {
    super.initState();
    final alarmService = Provider.of<AlarmService>(context, listen: false);

    _alarmSub = alarmService.onAlarmTrigger.listen((alarm) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AlarmRingingScreen(alarm: alarm),
            fullscreenDialog: true,
          ),
        );
      }
    });

    _wakeCheckSub = alarmService.onWakeUpCheckTrigger.listen((alarm) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WakeUpCheckScreen(onAwakeConfirmed: () {}),
            fullscreenDialog: true,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _alarmSub?.cancel();
    _wakeCheckSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildAlarmsHomeTab(),
          const MissionsCatalogScreen(),
          const SleepDashboardScreen(),
          const StatsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF10141D),
          border: Border(top: BorderSide(color: Color(0xFF1E2530), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentTab,
          onDestinationSelected: (idx) => setState(() => _currentTab = idx),
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: const Color(0xFF2563EB).withAlpha(50),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF2979FF)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.emoji_events_rounded, color: Color(0xFF2979FF)),
              label: 'Missions',
            ),
            NavigationDestination(
              icon: Icon(Icons.nightlight_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.nightlight_round, color: Color(0xFF2979FF)),
              label: 'Sleep',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF2979FF)),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmsHomeTab() {
    final alarmService = Provider.of<AlarmService>(context);
    final alarms = alarmService.alarms;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header: Good Morning, Ishant 👑 + Settings Gear (matching Screen 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good Morning,',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ishant 👑',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Better mornings. Bigger goals.',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withAlpha(200),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 24),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Today's Mission Banner Card (matching Screen 2)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MathMissionScreen(
                    alarm: alarms.isNotEmpty ? alarms.first : AlarmModel(id: '0', hour: 6, minute: 0),
                    onCompleted: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131F37),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1E3A8A).withAlpha(120)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.track_changes_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Mission',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Solve a simple math problem',
                          style: TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF93C5FD)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Alarms Section Header with circular (+) button (matching Screen 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alarms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlarmEditScreen()),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alarms List Cards (matching Screen 2 design)
          if (alarms.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: const Text('No alarms. Tap + to create one.', style: TextStyle(color: AppTheme.textMuted)),
            )
          else
            ...alarms.map((alarm) => _buildAlarmCard(alarm, alarmService)),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(AlarmModel alarm, AlarmService alarmService) {
    // Pick theme badge icon based on label / hour
    IconData badgeIcon = Icons.wb_sunny_rounded;
    Color iconColor = const Color(0xFFF59E0B);
    Color badgeBg = const Color(0xFF78350F).withAlpha(100);

    if (alarm.label.toLowerCase().contains('gym') || alarm.missionType == MissionType.step) {
      badgeIcon = Icons.fitness_center_rounded;
      iconColor = const Color(0xFF10B981);
      badgeBg = const Color(0xFF064E3B).withAlpha(100);
    } else if (alarm.hour >= 20 || alarm.hour < 5 || alarm.label.toLowerCase().contains('night')) {
      badgeIcon = Icons.nightlight_round;
      iconColor = const Color(0xFF38BDF8);
      badgeBg = const Color(0xFF0C4A6E).withAlpha(100);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: alarm.isEnabled ? const Color(0xFF262C36) : const Color(0xFF1C2128),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AlarmEditScreen(alarm: alarm)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon badge (Yellow sun / Blue moon / Green dumbbell)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(badgeIcon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),

                // Time, Repeat days, Label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alarm.timeFormatted,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: alarm.isEnabled ? Colors.white : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${alarm.repeatSummary} • ${alarm.label}',
                        style: TextStyle(
                          color: alarm.isEnabled ? AppTheme.textSecondary : AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Toggle Switch (matching blue switch from mockup)
                Switch(
                  value: alarm.isEnabled,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF2563EB),
                  inactiveThumbColor: AppTheme.textMuted,
                  inactiveTrackColor: const Color(0xFF21262D),
                  onChanged: (val) => alarmService.toggleAlarm(alarm.id, val),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
