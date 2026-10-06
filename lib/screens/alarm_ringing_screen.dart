import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/alarm_model.dart';
import '../../services/alarm_service.dart';
import '../../theme/app_theme.dart';
import 'missions/math_mission_screen.dart';
import 'missions/shake_mission_screen.dart';
import 'missions/barcode_mission_screen.dart';
import 'missions/photo_mission_screen.dart';
import 'missions/voice_mission_screen.dart';
import 'missions/memory_mission_screen.dart';
import 'missions/typing_mission_screen.dart';
import 'missions/step_mission_screen.dart';
import 'motivation_screen.dart';

class AlarmRingingScreen extends StatefulWidget {
  final AlarmModel alarm;

  const AlarmRingingScreen({super.key, required this.alarm});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onMissionSuccess() {
    final alarmService = AlarmService();
    alarmService.dismissAlarm();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MotivationScreen()),
      );
    }
  }

  void _startMission() {
    Widget missionScreen;
    switch (widget.alarm.missionType) {
      case MissionType.none:
        _onMissionSuccess();
        return;
      case MissionType.photo:
        missionScreen = PhotoMissionScreen(alarm: widget.alarm, onCompleted: _onMissionSuccess);
        break;
      case MissionType.barcode:
        missionScreen = BarcodeMissionScreen(alarm: widget.alarm, onCompleted: _onMissionSuccess);
        break;
      case MissionType.math:
        missionScreen = MathMissionScreen(alarm: widget.alarm, onCompleted: _onMissionSuccess);
        break;
      case MissionType.shake:
        missionScreen = ShakeMissionScreen(alarm: widget.alarm, onCompleted: _onMissionSuccess);
        break;
      case MissionType.voice:
        missionScreen = VoiceMissionScreen(alarm: widget.alarm, onCompleted: _onMissionSuccess);
        break;
      case MissionType.memory:
        missionScreen = MemoryMissionScreen(alarm: widget.alarm, onCompleted: _onMissionSuccess);
        break;
      case MissionType.typing:
        missionScreen = TypingMissionScreen(alarm: widget.alarm, onCompleted: _onMissionSuccess);
        break;
      case MissionType.step:
        missionScreen = StepMissionScreen(alarm: widget.alarm, onCompleted: _onMissionSuccess);
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => missionScreen),
    );
  }

  void _snooze() async {
    final alarmService = AlarmService();
    final success = await alarmService.snoozeAlarm();
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm').format(now);
    final amPm = DateFormat('a').format(now);
    final daysStr = widget.alarm.repeatSummary;

    final canSnooze = widget.alarm.snoozeEnabled &&
        (widget.alarm.maxSnoozeCount == 999 ||
            widget.alarm.currentSnoozeCount < widget.alarm.maxSnoozeCount);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0C1017),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Time to wake up!',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      amPm,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  daysStr,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(flex: 2),

                // Concentric Glowing Rings around Clock Icon (matching Screen 3)
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF131D33),
                      border: Border.all(color: const Color(0xFF1E3A8A).withAlpha(150), width: 14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withAlpha(60),
                          blurRadius: 50,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1D4ED8),
                        ),
                        child: const Icon(
                          Icons.alarm_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Challenge Mission Card (matching Screen 3 mockup)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF262C36)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complete the mission to stop',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.extension_rounded,
                              color: Color(0xFF60A5FA),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.alarm.missionName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Complete your challenge to prove you are awake.',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Primary Start Mission Button (Solid Blue Pill matching mockup)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _startMission,
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text(
                      'Start Mission',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Snooze Text Button
                if (canSnooze)
                  TextButton(
                    onPressed: _snooze,
                    child: Text(
                      'Snooze (${widget.alarm.snoozeDurationMinutes} min)',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Snooze limit reached',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
