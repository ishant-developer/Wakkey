import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/alarm_service.dart';
import '../../theme/app_theme.dart';

class WakeUpCheckScreen extends StatefulWidget {
  final VoidCallback onAwakeConfirmed;

  const WakeUpCheckScreen({super.key, required this.onAwakeConfirmed});

  @override
  State<WakeUpCheckScreen> createState() => _WakeUpCheckScreenState();
}

class _WakeUpCheckScreenState extends State<WakeUpCheckScreen> {
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        // Failed wake-up check! Sound alarm!
        final alarmService = AlarmService();
        final alarm = alarmService.activeWakeUpCheckAlarm;
        if (alarm != null) {
          alarmService.triggerAlarm(alarm);
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withAlpha(30),
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: const Icon(
                  Icons.shield_moon_rounded,
                  size: 72,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Are You Still Awake?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Wakkey Wake-Up Guard: Confirm you did not fall back asleep. Otherwise, the alarm will ring again!',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Countdown badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Text(
                  'Auto-alarm in $_secondsLeft seconds',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warning,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final alarmService = AlarmService();
                    alarmService.confirmWakeUpCheck();
                    widget.onAwakeConfirmed();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 24),
                  label: const Text(
                    'I\'M WIDE AWAKE!',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
